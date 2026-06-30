# Sigil Engineering Workflow Skills

**Multi-agent engineering tools that are security-gated, language-aware, and verified by a 5-panel certification authority.**

Part of the [Sigil Project](https://github.com/BlueBoobyAI/sigil) — an open certification authority for Claude Code skills.

---

## The honest story

Before building this, we did something most plugin authors don't: we audited the most popular engineering workflow plugin on the marketplace, line by line, through 5 independent expert lenses.

What we found wasn't malicious. It was worse: it was *the state of the art*.

The existing tools were thin prompt wrappers. They hardcoded `make test` — as if every project on earth uses Make. They used `git add .` — staging every file, including your `.env` with production API keys. When a push failed, they exited 1. No retry. No recovery. No security scan before touching git.

These tools exist because developers *need* this workflow. But the tools weren't built to the standard developers deserve. So we rebuilt them.

Every skill in this plugin is:
- **Language-agnostic** — detects your framework, never assumes Make/Python/Jest
- **Security-gated** — scans for secrets before every destructive operation
- **Self-testing** — the plugin verifies its own integrity (7 checks, all passing)
- **Sigil-certified** — passes the same 5-panel review we use on all our skills

Here's what we fixed and why it matters.

---

## What was wrong, and what we did about it

| The old way | The Sigil way |
|---|---|
| Skills are single-prompt wrappers with zero architectural depth | Each skill is a multi-agent protocol with orchestration, verification, and recovery |
| Hardcoded `make test` — fails silently on non-Make projects | Auto-detects 12+ frameworks (pytest, jest, cargo, go test, rspec, cmake, and more) |
| `git add .` stages your secrets alongside your code | Secret scanner runs before every git operation; never use `git add .` |
| Zero tests for the plugin itself — ship and pray | `self-test.sh` validates plugin integrity every deploy |
| Users discover skills by luck or word of mouth | `help` and `version` commands make every skill findable |
| Version says 1.1.0 in README, 1.2.0 in plugin.json — nobody notices until something breaks | Single `VERSION` file, enforced by self-test on every run |
| Push fails and the command exits 1 — you retry manually, it fails again, you give up | Retry 3 times with exponential backoff (2s → 4s → 8s); only fail when all retries exhaust |

These seven fixes aren't aspirational. They're in the code, tested, and verified.

---

## The skills

### 1. Plan Execute

**Activates when you say:** *"Plan this feature implementation"*, *"Plan this with security review"*

**Positive story:** A senior developer messages "We need to add Stripe checkout. Plan it." The skill detects the project is Python/Django, classifies risk as high (payment processing), spawns parallel engineering + security reviews, and returns a structured plan with file list, dependency tree, and security surface analysis. The review catches a PCI compliance issue before a single line is written.

**Negative story (old way):** A junior dev types the same request. The old skill assumes Makefile + pytest (this project uses Django + unittest). The generated plan references nonexistent test files and misses the PCI boundary entirely. Two sprints later, the security team blocks the release.

**What it does:**
- Detects your project's language and toolchain automatically (probes build files, never assumes)
- Classifies risk with justification — low/medium/high based on scope and data sensitivity
- For medium+ risk: runs parallel engineering + security mini-reviews before generating the plan
- Generates structured plan with file list, dependencies, milestones, and risks
- Optional: parallel execution with ensemble comparison across 2 implementation agents

### 2. Test Doctor

**Activates when you say:** *"Fix the failing tests"*, *"Why are the tests failing?"*

**Positive story:** CI is red — 14 tests failed across 6 files. The skill runs the test suite, snapshots the 149 passing tests, clusters failures by root cause (not by file), and discovers all 14 failures trace to a single broken mock. It fixes the mock, re-runs all 149 previously-passing tests, and proves zero regressions. Total time: 2 minutes. Green CI.

**Negative story (old way):** A developer reads 14 test failures one at a time. They fix the mock in file A. File B's tests still fail because they also depend on the mock — the developer didn't know. They fix file B. File C's tests are actually a different issue (stale fixture cache). They fix file C. An hour later, the build is green but the developer shipped a subtle mock-side-effect bug that the 149 passing tests didn't cover because they were never re-run.

**What it does:**
- Auto-detects test framework (pytest, jest, cargo test, go test, rspec, cmake test, and more)
- Snapshots passing tests before any changes — proves zero regressions
- Clusters failures by root cause type, not by file — fix the source, not the symptoms
- Fixes one cause cluster at a time with per-fix verification
- Re-runs pre-fix passing test suite to prove nothing regressed

### 3. Safe Commit

**Activates when you say:** *"Commit these changes"*, *"Push my changes safely"*

**Positive story:** You've been working on a feature for 3 hours. You type "commit these changes." The skill reads `git status --porcelain`, shows you each file grouped by change type (modified/staged/untracked), and asks which to stage. Before staging, it runs `detect-secrets.sh` and catches a Shopify API token you accidentally left in a config file. The commit proceeds safely. When pushing, the remote is slow — first attempt fails. The skill retries after 2 seconds (no), 4 seconds (no), 8 seconds (yes). You never saw the error.

**Negative story (old way):** You type "commit my changes." The old skill runs `git add .` — staging your code alongside the `.env` file with `SK_LIVE_...` that was edited during testing. The commit goes through. The secret is in git history. You discover it 3 months later during an audit. Rotating that key costs the team a production outage.

**What it does:**
- Reviews working tree with grouped change categories (never `git add .`)
- Runs secret scanning before every staging operation — 13 secret patterns including Shopify, Stripe, GitHub, AWS, OpenAI, and private keys
- Stages each file with your review before committing
- Generates accurate commit messages from staged diff content (not filename heuristics)
- Retries push with exponential backoff (2s → 4s → 8s, up to 3 attempts)
- Detects merge conflicts early and resolves interactively

### 4. Review Apply

**Activates when you say:** *"Apply this PR review feedback"*, *"Implement the code review suggestions"*

**Positive story:** Your PR gets a review with 12 comments: 1 security issue, 2 bugs, 4 design suggestions, 3 style nits, 2 documentation requests. The skill classifies every comment by type, prioritizes the security fix first, then — for the two bugs — writes a failing test for each *before* touching the code. After fixing all 12 comments, it re-runs the test suite and confirms zero regressions. The diff shows exactly what changed, grouped by comment type.

**Negative story (old way):** A developer reads PR comments in order. Comment 5 suggests renaming a shared interface method. The developer renames it — unknowingly breaking 3 callers in other files. The test suite catches the breakage, but the developer has now wasted 20 minutes debugging a rename conflict that should have been caught before the edit.

**What it does:**
- Classifies each comment: BUG / SECURITY / DESIGN / STYLE / DOC
- For bugs: writes a failing test first, then fixes the code (test-driven debugging)
- Traces cross-file callers with grep before modifying shared symbols — prevents rename-induced breaks
- Applies changes by priority order: security first, then bugs, then design, style, docs last
- Re-runs test suite after all changes — proves nothing regressed

### 5. Solution Ensemble

**Activates when you say:** *"Generate multiple approaches to this problem"*, *"Compare approaches"*

**Positive story:** You need to decide between Redis, in-memory caching, or a database-level solution for rate limiting. The skill spawns 3 independent solution agents — each builds a full approach without seeing the others. Then it scores all 3 on 5 weighted dimensions: correctness (40%), performance (20%), maintainability (20%), security (10%), clarity (10%). The Redis solution wins, but the ensemble report flags that it requires infrastructure your staging environment doesn't have — something a single-agent approach would have missed.

**Negative story (old way):** A developer asks for "different approaches to caching." A single LLM session generates 3 options — but option 2 is just option 1 with different words, and option 3 is the worst of both. The developer spends 30 minutes evaluating options that aren't actually different. The security dimension (what about token caching and TTL attacks?) is never considered.

**What it does:**
- Spawns 3 parallel solution agents — each builds an independent approach in isolation
- Scores each on 5 weighted dimensions: correctness (40%), performance (20%), maintainability (20%), security (10%), clarity (10%)
- Flags fundamental disagreements between surviving solutions — alerts you when agents disagree
- Each solution includes a risk section alongside the proposed approach

---

## The infrastructure

### Agents
- **plan-executor** (Sonnet) — Detects language, probes build files, never hardcodes tools
- **secret-scanner** (Haiku) — Fast staged-file security pattern matching, detection only, no fixes

### Scripts
- `scripts/self-test.sh` — 7 integrity checks, runs in under 2 seconds
- `scripts/detect-secrets.sh` — Pure-bash scan for 13 secret patterns, zero dependencies
- `scripts/version.sh` — Single source of truth enforcement, validates semver

## Requirements

- Claude Code CLI
- Git (for safe-commit skill)
- Standard development tools for your language (auto-detected — nothing extra to configure)

## Security

Safe Commit runs `scripts/detect-secrets.sh` before every git operation. It scans for 13 secret patterns: Shopify (`shpat_`, `shpss_`, `shpca_`), Stripe (`sk_live_`, `whsec_`, `rk_live_`), GitHub (`ghp_`, `ghs_`), AWS (`AKIA`), OpenAI (`sk-proj-`), Anthropic (`sk-or-v1-`), and private key headers.

This is not comprehensive security — it's the 80% that catches 95% of accidental commits. Layer it with gitleaks in CI for full coverage.

## Quality

The plugin tests its own integrity on every version update:

```
$ bash scripts/self-test.sh
═══ sigil-engineering-workflow self-test ═══

CHECK 1: PASS — Required files exist
CHECK 2: PASS — All SKILL.md files exist
CHECK 3: PASS — All AGENT.md files exist
CHECK 4: PASS — No skill uses 'git add .'
CHECK 5: PASS — plugin.json version matches VERSION
CHECK 6: PASS — VERSION is valid semver
CHECK 7: PASS — Scripts are executable

═══ Results: 7 passed, 0 failed ═══
```

## Installation

```bash
claude plugin marketplace add mhattingpete/claude-skills-marketplace
claude plugin install sigil-engineering-workflow
```

Or from source:
```bash
git clone git@github.com:BlueBoobyAI/claude-skills-marketplace.git
cd claude-skills-marketplace
claude plugin install sigil-engineering-workflow-plugin
```

## Version

1.0.0

---

**Built by the [Sigil Project](https://github.com/BlueBoobyAI/sigil).** We certify Claude Code skills so you don't have to audit them yourself.

*Also available on [AEO Sky](https://github.com/BlueBoobyAI/aeo-sky-marketplace).*
