#!/usr/bin/env python3
"""
find-go-refs.py
Busca recursivamente por referências à linguagem Go nos arquivos .md do projeto.
Classifica cada ocorrência como: PROVÁVEL_GO | FALSO_POSITIVO | REVISAR
"""

import os
import re
import sys
from pathlib import Path

# ── Padrões que indicam referência à linguagem Go ────────────────────────────
GO_PATTERNS = [
    r'\bgolang\b',
    r'\bgo\.mod\b',
    r'\bgo\.sum\b',
    r'\bgolangci',
    r'\bgolang-migrate\b',
    r'\bgolang-jwt\b',
    r'\bgovulncheck\b',
    r'\bgosec\b',
    r'\bmockgen\b',
    r'\.go\b',                      # arquivos .go
    r'\bfrom golang:',              # Docker FROM golang:
    r'\bgo install\b',
    r'\bgo build\b',
    r'\bgo test\b',
    r'\bgo run\b',
    r'\bgo get\b',
    r'\bfmt\.Sprintf\b',
    r'\bfmt\.Println\b',
    r'\bfmt\.Errorf\b',
    r'\bsync\.Mutex\b',
    r'\bcontext\.Context\b',
    r'\bgolangci-lint\b',
    r'golang\.org/',
    r'\bgo-version\b',
    r'language:go\b',
    r'\bgoroutine',
    r'go\.uber\.org',
    r'\bswaggo\b',
    r'go install github\.com',
]

# ── Padrões que são claramente falsos positivos ───────────────────────────────
FALSE_POSITIVE_PATTERNS = [
    r'\bgo to\b',           # "go to step X"
    r'\bgo back\b',
    r'\bgood\b',
    r'\bgoal\b',
    r'\bgoes\b',
    r'\bgoing\b',
    r'\bgone\b',
    r'\bgot\b',
    r'\btherefore\b',
    r'cargo',
    r'ergo',
    r'logo',
    r'\bago\b',
    r'algorithm',
    r'django',
]

# ── Arquivos/diretórios a ignorar ─────────────────────────────────────────────
IGNORE_PATHS = [
    'CHANGELOG.md',     # histórico intencional
    '.git',
    'node_modules',
    'vendor',
]

COLORS = {
    'RED':    '\033[91m',
    'YELLOW': '\033[93m',
    'GREEN':  '\033[92m',
    'CYAN':   '\033[96m',
    'RESET':  '\033[0m',
    'BOLD':   '\033[1m',
    'DIM':    '\033[2m',
}


def colorize(text, color):
    return f"{COLORS[color]}{text}{COLORS['RESET']}"


def is_go_ref(line):
    line_lower = line.lower()
    for pattern in GO_PATTERNS:
        if re.search(pattern, line, re.IGNORECASE):
            return True
    return False


def is_false_positive(line):
    for pattern in FALSE_POSITIVE_PATTERNS:
        if re.search(pattern, line, re.IGNORECASE):
            # Double-check: if a strong Go pattern is also present, it's still Go
            for go_pat in GO_PATTERNS:
                if re.search(go_pat, line, re.IGNORECASE):
                    return False
            return True
    return False


def classify(line):
    if is_go_ref(line):
        return 'GO'
    if is_false_positive(line):
        return 'FALSE_POSITIVE'
    # Has 'go' but doesn't match strong patterns - needs manual review
    if re.search(r'\bgo\b', line, re.IGNORECASE):
        return 'REVISAR'
    return 'FALSE_POSITIVE'


def should_ignore(path):
    for ignore in IGNORE_PATHS:
        if ignore in str(path):
            return True
    return False


def search_files(root):
    root = Path(root)
    results = {
        'GO': [],
        'REVISAR': [],
        'FALSE_POSITIVE': [],
    }

    for md_file in sorted(root.rglob('*.md')):
        if should_ignore(md_file):
            continue

        rel_path = md_file.relative_to(root)

        try:
            lines = md_file.read_text(encoding='utf-8').splitlines()
        except Exception as e:
            print(f"  [ERRO] {rel_path}: {e}")
            continue

        for i, line in enumerate(lines, start=1):
            if not re.search(r'\bgo\b', line, re.IGNORECASE):
                continue

            category = classify(line)
            if category == 'FALSE_POSITIVE':
                continue  # Não reportar falsos positivos

            # Contexto: 1 linha antes e depois
            ctx_before = lines[i - 2].strip() if i >= 2 else ''
            ctx_after  = lines[i].strip() if i < len(lines) else ''

            results[category].append({
                'file': str(rel_path),
                'line': i,
                'text': line.strip(),
                'ctx_before': ctx_before,
                'ctx_after': ctx_after,
            })

    return results


def print_results(results):
    total_go     = len(results['GO'])
    total_review = len(results['REVISAR'])

    print()
    print(colorize('═' * 70, 'BOLD'))
    print(colorize('  RELATÓRIO DE REFERÊNCIAS A GO', 'BOLD'))
    print(colorize('═' * 70, 'BOLD'))
    print()

    # ── Referências Go confirmadas ────────────────────────────────────────────
    if results['GO']:
        print(colorize(f'🔴  REFERÊNCIAS GO CONFIRMADAS ({total_go})', 'RED'))
        print(colorize('─' * 70, 'DIM'))
        current_file = None
        for item in results['GO']:
            if item['file'] != current_file:
                current_file = item['file']
                print(f"\n  {colorize(current_file, 'CYAN')}")
            line_ref = f"L{item['line']}"
            print(f"    {colorize(line_ref, 'BOLD')}  {colorize(item['text'], 'RED')}")
        print()
    else:
        print(colorize('✅  Nenhuma referência Go confirmada encontrada.', 'GREEN'))
        print()

    # ── Linhas para revisão manual ────────────────────────────────────────────
    if results['REVISAR']:
        print(colorize(f'🟡  PARA REVISÃO MANUAL ({total_review})', 'YELLOW'))
        print(colorize('─' * 70, 'DIM'))
        current_file = None
        for item in results['REVISAR']:
            if item['file'] != current_file:
                current_file = item['file']
                print(f"\n  {colorize(current_file, 'CYAN')}")
            line_ref = f"L{item['line']}"
            print(f"    {colorize(line_ref, 'BOLD')}  {item['text']}")
            if item['ctx_before']:
                print(f"           {colorize(item['ctx_before'], 'DIM')}")
        print()

    # ── Sumário ───────────────────────────────────────────────────────────────
    print(colorize('─' * 70, 'DIM'))
    print(f"  Go confirmados : {colorize(str(total_go), 'RED' if total_go else 'GREEN')}")
    print(f"  Para revisar   : {colorize(str(total_review), 'YELLOW' if total_review else 'GREEN')}")
    print(colorize('═' * 70, 'BOLD'))
    print()


if __name__ == '__main__':
    root = sys.argv[1] if len(sys.argv) > 1 else '.'
    results = search_files(root)
    print_results(results)

    # Exit code: 0 se limpo, 1 se há ocorrências Go
    sys.exit(1 if results['GO'] or results['REVISAR'] else 0)
