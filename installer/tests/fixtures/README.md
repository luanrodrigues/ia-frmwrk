# Test Fixtures

These fixtures intentionally use various formats (including legacy `bee:` shorthand)
to test the adapter transformation logic for different AI platforms.

**Important:** Do NOT normalize these to production format. They exist to verify that
transformers correctly convert different input patterns to platform-specific formats.

## Fixture Files

- `skills/sample-skill/SKILL.md` - Tests skill transformation (uses bee: shorthand)
- `agents/sample-agent.md` - Tests agent transformation
- `commands/sample-command.md` - Tests command transformation

See `installer/bee_installer/adapters/` for transformation implementation.
