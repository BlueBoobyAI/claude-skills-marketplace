# Sigil Engineering Workflow Skills

**Sigil-certified** engineering workflow skills — language-agnostic, security-gated, self-testing replacements for common ad-hoc coding patterns.

Part of the [Sigil Project](https://github.com/BlueBoobyAI/sigil) ecosystem of certified Claude Code skills.

## Skills Included

### 1. Plan Execute

**Purpose:** Verified, risk-assessed implementation planning with automatic language detection and parallel execution.

**Activates when you say:**
- "Plan this feature implementation"
- "Plan this with security review"
- "Assess the risk of this implementation"

**What it does:**
- Detects your project's language and toolchain automatically
- Classifies risk (low/medium/high) with justification
- For medium+ risk: runs parallel engineering + security mini-reviews
- Generates structured plan with file list, dependencies, and risks
- Optional parallel execution with ensemble comparison

### 2. Test Doctor

**Purpose:** Language-agnostic test fixing with root-cause analysis and regression snapshots.

**Activates when you say:**
- "Fix the failing tests"
- "Why are the tests failing?"
- "Run the tests and fix any issues"

**What it does:**
- Auto-detects test framework (pytest, jest, cargo test, go test, rspec, and more)
- Snapshots passing tests before any changes
- Clusters failures by root cause (not by file)
- Fixes one cause cluster at a time with verification
- Proves zero regressions by re-running pre-fix passing tests

### 3. Safe Commit

**Purpose:** Security-gated git workflow — never pushes secrets, merge conflicts, or untracked files.

**Activates when you say:**
- "Commit these changes"
- "Push my changes safely"
- "Save my progress to git"

**What it does:**
- Reviews working tree with grouped change categories
- Runs secret scanning before every staging operation
- Stages files individually with user review (never `git add .`)
- Generates accurate commit messages from staged diff
- Retries push with exponential backoff (3 attempts)
- Detects merge conflicts and resolves interactively

### 4. Review Apply

**Purpose:** Systematic PR feedback implementation with TDD for bugs and cross-file dependency tracing.

**Activates when you say:**
- "Apply this PR review feedback"
- "Implement the code review suggestions"
- "Address the review comments"

**What it does:**
- Classifies each comment: BUG/SECURITY/DESIGN/STYLE/DOC
- For bugs: writes a failing test first, then fixes the code
- Traces cross-file callers before modifying shared symbols
- Applies changes by priority (security first, docs last)
- Verifies no regressions after all changes

### 5. Solution Ensemble

**Purpose:** Multi-agent solution generation with 5-dimension evaluation including security.

**Activates when you say:**
- "Generate multiple approaches to this problem"
- "Compare approaches for this task"
- "What are different ways to implement this?"

**What it does:**
- Spawns 3 parallel solution agents for independent approaches
- Scores each on 5 weighted dimensions (correctness 40%, performance 20%, maintainability 20%, security 10%, clarity 10%)
- Flags fundamental disagreements for human judgment
- Recommends best fit or requests user input on conflicts

## Installation

Add this marketplace to your Claude Code:

```bash
claude plugin marketplace add mhattingpete/claude-skills-marketplace
claude plugin install sigil-engineering-workflow
```

## Requirements

- Claude Code CLI
- Git (for safe-commit skill)
- Standard development tools for your language (auto-detected)

## Security

Safe Commit runs `scripts/detect-secrets.sh` before every git operation. It scans for:
- Shopify API tokens (`shpat_`, `shpss_`, `shpca_`)
- Stripe keys (`sk_live_`, `sk_test_`, `whsec_`, `rk_live_`)
- GitHub tokens (`ghp_`, `ghs_`)
- AWS access keys (`AKIA...`)
- OpenAI/Anthropic API keys (`sk-proj-`, `sk-or-v1-`)
- Private keys (`-----BEGIN ... PRIVATE KEY-----`)

## Quality

This plugin self-tests its own integrity:
- Plugin version matches VERSION file (single source of truth)
- All skill/agent files exist
- No skill contains `git add .`
- Secret scanner is executable

Run: `bash scripts/self-test.sh`

## Version

1.0.0

## Author

[Sigil Project](https://github.com/BlueBoobyAI/sigil)
