# bee-default Changelog

## [2.1.0] - 2026-03-06

### Added

- **`bee:opencode-review` skill** - External code review via OpenCode CLI, sends diff to a second AI model (e.g., Qwen3-Max) for independent review
- **`docs/opencode-instructions.md`** - Comprehensive review instructions sent to the external model (TypeScript, PHP/Laravel focus)
- **Step 7.6 in `requesting-code-review`** - OpenCode integrated as advisory external reviewer alongside CodeRabbit
- Input parameters `skip_opencode` and `opencode_model` in `requesting-code-review` skill
- Output metrics `opencode_status`, `opencode_model`, `opencode_issues` in review reports
- OpenCode section in visual HTML review report

### Changed

- Skill count: 26 to 27
- Marketplace version: 2.0.0 to 2.1.0
- Updated CLAUDE.md, README.md with new skill counts and Code Review documentation

---

## [1.12.2](https://github.com/luanrodrigues/ia-frmwrk/releases/tag/bee-default@1.12.2)

- Refactor: Replace codereview binaries and overhaul diff visualization.
- Chore: Remove codereview tooling and all related assets.

Contributors: @fred

[Compare changes](https://github.com/luanrodrigues/ia-frmwrk/compare/bee-default@1.12.1...bee-default@1.12.2)

---

## [1.12.1](https://github.com/luanrodrigues/ia-frmwrk/releases/tag/bee-default@1.12.1)

- Fixes:
  - Add fill-rule to logo SVG for correct rendering in visual-explainer.

Contributors: @fred

[Compare changes](https://github.com/luanrodrigues/ia-frmwrk/compare/bee-default@1.12.0...bee-default@1.12.1)

---

## [1.12.1](https://github.com/luanrodrigues/ia-frmwrk/releases/tag/bee-default@1.12.1)

- Fixes:
  - Add fill-rule to logo SVG for correct rendering

Contributors: @fred

[Compare changes](https://github.com/luanrodrigues/ia-frmwrk/compare/bee-default@1.12.0...bee-default@1.12.1)

---

## [1.12.1](https://github.com/luanrodrigues/ia-frmwrk/releases/tag/bee-default@1.12.1)

- Fixes:
  - Add fill-rule to logo SVG for correct rendering.

Contributors: @fred

[Compare changes](https://github.com/luanrodrigues/ia-frmwrk/compare/bee-default@1.12.0...bee-default@1.12.1)

---

## [1.12.0](https://github.com/luanrodrigues/ia-frmwrk/releases/tag/bee-default@1.12.0)

- Features:
  - Introduce mandatory Lerian design system in visual explainer.

Contributors: @fred

[Compare changes](https://github.com/luanrodrigues/ia-frmwrk/compare/bee-default@1.11.1...bee-default@1.12.0)

---

## [1.11.1](https://github.com/luanrodrigues/ia-frmwrk/releases/tag/bee-default@1.11.1)

- **Fixes:**
  - Corrected Resolve* examples and checklist after code review.

Contributors: @jeff, @jefferson.comff

[Compare changes](https://github.com/luanrodrigues/ia-frmwrk/compare/bee-default@1.11.0...bee-default@1.11.1)

---

## [1.11.1](https://github.com/luanrodrigues/ia-frmwrk/releases/tag/bee-default@1.11.1)

- **Fixes:**
  - Corrected `Resolve*` examples and checklist following code review.

Contributors: @jeff, @jefferson.comff

[Compare changes](https://github.com/luanrodrigues/ia-frmwrk/compare/bee-default@1.11.0...bee-default@1.11.1)

---

## [1.11.1](https://github.com/luanrodrigues/ia-frmwrk/releases/tag/bee-default@1.11.1)

- **Improvements:**
  - Updated tenant-manager function names to align with the Resolve* interface for better consistency and clarity.

- **Fixes:**
  - Corrected Resolve* examples and checklist following a code review to ensure accuracy and adherence to standards.

Contributors: @jeff, @jefferson.comff

[Compare changes](https://github.com/luanrodrigues/ia-frmwrk/compare/bee-default@1.11.0...bee-default@1.11.1)

---

## [1.11.1](https://github.com/luanrodrigues/ia-frmwrk/releases/tag/bee-default@1.11.1)

- **Fixes:**
  - Corrected Resolve* examples and checklist after code review.

- **Improvements:**
  - Updated function names in tenant-manager to align with the Resolve* interface.

Contributors: @jeff, @jefferson.comff

[Compare changes](https://github.com/luanrodrigues/ia-frmwrk/compare/bee-default@1.11.0...bee-default@1.11.1)

---

## [1.11.1](https://github.com/luanrodrigues/ia-frmwrk/releases/tag/bee-default@1.11.1)

- Improvements:
  - Update tenant-manager function names to Resolve* interface for consistency.
  - Correct Resolve* examples and checklist after code review for better clarity.

Contributors: @jeff, @jefferson.comff

[Compare changes](https://github.com/luanrodrigues/ia-frmwrk/compare/bee-default@1.11.0...bee-default@1.11.1)

---

## [1.11.0](https://github.com/luanrodrigues/ia-frmwrk/releases/tag/bee-default@1.11.0)

- **Features:**
  - Added CLAUDE.md compliance sections to all 25 default skills.

- **Fixes:**
  - Applied lexical salience guidelines across skills.
  - Added missing CLAUDE.md required sections across all 6 plugins.

Contributors: @jeff, @jefferson.comff

[Compare changes](https://github.com/luanrodrigues/ia-frmwrk/compare/bee-default@1.10.0...bee-default@1.11.0)

---

## [1.11.0](https://github.com/luanrodrigues/ia-frmwrk/releases/tag/bee-default@1.11.0)

- **Features:**
  - Added CLAUDE.md compliance sections to all 25 default skills.

- **Fixes:**
  - Applied lexical salience guidelines across skills.
  - Added missing CLAUDE.md required sections across all 6 plugins.

Contributors: @jeff, @jefferson.comff

[Compare changes](https://github.com/luanrodrigues/ia-frmwrk/compare/bee-default@1.10.0...bee-default@1.11.0)

---

## [1.11.0](https://github.com/luanrodrigues/ia-frmwrk/releases/tag/bee-default@1.11.0)

- **Features:**
  - Added CLAUDE.md compliance sections to all 25 default skills.

- **Fixes:**
  - Applied lexical salience guidelines across skills.
  - Added missing CLAUDE.md required sections across all 6 plugins.

Contributors: @jeff, @jefferson.comff

[Compare changes](https://github.com/luanrodrigues/ia-frmwrk/compare/bee-default@1.10.0...bee-default@1.11.0)

---

## [1.10.0](https://github.com/luanrodrigues/ia-frmwrk/releases/tag/bee-default@1.10.0)

- **Features**
  - Add visual HTML reports to code review and production readiness audit.

- **Contributors**
  - @jefferson.comff
  - @lucasc.bedatty

[Compare changes](https://github.com/luanrodrigues/ia-frmwrk/compare/bee-default@1.9.0...bee-default@1.10.0)

---

## [1.10.0](https://github.com/luanrodrigues/ia-frmwrk/releases/tag/bee-default@1.10.0)

- **Features:**
  - Add visual HTML reports to code review and production readiness audit.

- **Contributors:**
  - @jefferson.comff
  - @lucasc.bedatty

[Compare changes](https://github.com/luanrodrigues/ia-frmwrk/compare/bee-default@1.9.0...bee-default@1.10.0)

---

## [1.9.0](https://github.com/luanrodrigues/ia-frmwrk/releases/tag/bee-default@1.9.0)

- **Features**
  - Add consequences-reviewer to parallel code review

Contributors: @fred

[Compare changes](https://github.com/luanrodrigues/ia-frmwrk/compare/bee-default@1.8.0...bee-default@1.9.0)

---

## [1.9.0](https://github.com/luanrodrigues/ia-frmwrk/releases/tag/bee-default@1.9.0)

- **Features**
  - Add consequences-reviewer to parallel code review

Contributors: @fred

[Compare changes](https://github.com/luanrodrigues/ia-frmwrk/compare/bee-default@1.8.0...bee-default@1.9.0)

---

## [1.9.0](https://github.com/luanrodrigues/ia-frmwrk/releases/tag/bee-default@1.9.0)

- **Features**
  - Add consequences-reviewer to parallel code review.

Contributors: @fred

[Compare changes](https://github.com/luanrodrigues/ia-frmwrk/compare/bee-default@1.8.0...bee-default@1.9.0)

---

## [1.8.0](https://github.com/luanrodrigues/ia-frmwrk/releases/tag/bee-default@1.8.0)

- Integrate visual-explainer with bee:md-to-html command

Contributors: @fred

[Compare changes](https://github.com/luanrodrigues/ia-frmwrk/compare/bee-default@1.7.1...bee-default@1.8.0)

---

## [1.8.0](https://github.com/luanrodrigues/ia-frmwrk/releases/tag/bee-default@1.8.0)

- Integrate visual-explainer with bee:md-to-html command

Contributors: @fred

[Compare changes](https://github.com/luanrodrigues/ia-frmwrk/compare/bee-default@1.7.1...bee-default@1.8.0)

---

## [1.7.1](https://github.com/luanrodrigues/ia-frmwrk/releases/tag/bee-default@1.7.1)

- Fixes:
  - Align multi-tenant standards with midaz dual-pool architecture.
  - Rename poolmanager to tenantmanager across standards.

Contributors: @jeff, @jefferson.comff

[Compare changes](https://github.com/luanrodrigues/ia-frmwrk/compare/bee-default@1.7.0...bee-default@1.7.1)

---

## [1.7.1](https://github.com/luanrodrigues/ia-frmwrk/releases/tag/bee-default@1.7.1)

- Fixes:
  - Align multi-tenant standards with midaz dual-pool architecture.
  - Rename poolmanager to tenantmanager across standards.

Contributors: @jeff, @jefferson.comff,

[Compare changes](https://github.com/luanrodrigues/ia-frmwrk/compare/bee-default@1.7.0...bee-default@1.7.1)

---

## [1.7.1](https://github.com/luanrodrigues/ia-frmwrk/releases/tag/bee-default@1.7.1)

- Fixes:
  - Align multi-tenant standards with midaz dual-pool architecture.
  - Rename poolmanager to tenantmanager across standards.

Contributors: @jeff, @jefferson.comff

[Compare changes](https://github.com/luanrodrigues/ia-frmwrk/compare/bee-default@1.7.0...bee-default@1.7.1)

---

## [1.7.0](https://github.com/luanrodrigues/ia-frmwrk/releases/tag/bee-default@1.7.0)

- Added GPT Changelog workflow.
- Created initial CHANGELOG files for teams header.

Contributors: @gui.rodrigues

[Compare changes](https://github.com/luanrodrigues/ia-frmwrk/compare/bee-default@1.6.2...bee-default@1.7.0)

