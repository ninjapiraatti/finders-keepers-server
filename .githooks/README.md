# Git Hooks

This directory contains git hooks for the Finders Keepers server project.

## Available Hooks

### Pre-commit Hook
- **Purpose**: Runs security audit before each commit
- **Tool**: `cargo audit`
- **Action**: Blocks commits if security vulnerabilities are found

## Setup

To install the git hooks, run:

```bash
./setup-hooks.sh
```

## Manual Installation

If you prefer to install manually:

```bash
cp .githooks/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

## Bypassing Hooks

If you need to skip the pre-commit hook temporarily:

```bash
git commit --no-verify
```

**Note**: Only use `--no-verify` when absolutely necessary, as it bypasses important security checks.

## Requirements

The pre-commit hook requires:
- `cargo-audit` (automatically installed if missing)

## Troubleshooting

### cargo-audit Installation Issues
If `cargo-audit` fails to install, try:
```bash
cargo install --force cargo-audit
```

### Hook Not Running
Ensure the hook is executable:
```bash
chmod +x .git/hooks/pre-commit
```
