---
name: parliament
description: Multi-perspective review skill. Spawns parallel expert agents (Engineering, Security, UX, CEO/Strategy, QA) to audit any codebase, design doc, or skill. The quality gate for skills marketplaces.
triggers:
  - review this
  - audit this
  - parliament review
  - multi-perspective review
  - quality gate
  - assess this skill
  - evaluate this
  - should I use this skill
  - is this safe
  - verify quality
  - code review
  - design review
allowed-tools:
  - Bash
  - Read
  - Agent
  - Workflow
  - AskUserQuestion
---

# Omniscient Parliament

Multi-perspective review system. Assembles a panel of expert agents — Engineering, Security, UX, CEO/Strategy, and QA — each analyzing from their lens. Produces a consensus verdict with scores, findings, and a GO/NO-GO gate.

**Why "Parliament"?** No single perspective catches everything. Five experts, voting independently, catch what any one would miss.

**Free at:** https://github.com/BlueBoobyAI/omniscient-parliament (OSS, MIT)
**Premium at:** [our marketplace URL — coming soon]
**Tip jar:** `bc1q...` (Bitcoin) | ko-fi.com/charlesliuson

## When to Invoke

- User says "review this code" or "audit this skill"
- Before publishing any skill to a marketplace
- Before deploying critical infrastructure changes
- Evaluating whether to adopt a third-party tool or skill
- `/assess` command (aliased to this)

## Instructions

### Step 1 — Determine review scope

Read the target from context or from the user's message. Determine tier:

| Tier | Depth | Agents | Time |
|------|-------|--------|------|
| **Quick** | Surface audit, 1-2 lenses | Engineering + Security | ~30s |
| **Standard** | Full audit, all lenses | Engineering, Security, UX, CEO | ~2min |
| **Deep** | Exhaustive, adversarial | All 5 + adversarial refute pass | ~5min |

Default to **Standard** unless the user specifies otherwise.

### Step 2 — Spawn parallel expert agents

For Standard tier, spawn 4 agents in parallel:

```
Agent 1: Engineering — architecture, code quality, maintainability, test coverage
Agent 2: Security — OWASP top 10, auth, data handling, dependency risk
Agent 3: UX — usability, accessibility, onboarding friction, error states
Agent 4: CEO/Strategy — does this move the needle? cost/benefit, opportunity cost
```

For Deep tier, add:
```
Agent 5: QA — edge cases, failure modes, test gaps, breakpoints
```

Each agent receives:
1. The target (code, SKILL.md, design doc, or description)
2. Their specific lens instructions
3. A "be adversarial — find what's wrong, don't rubber-stamp" mandate

### Step 3 — Collect and synthesize

Read each agent's output. Grade each lens:

| Grade | Meaning |
|-------|---------|
| PASS | No issues found, or minor only |
| PASS_W_CONCERNS | Minor issues, worth noting |
| FAIL | Must fix before proceeding |
| BLOCKER | Cannot proceed — fundamental flaw |

Gate logic:
- Quick: 1/2 PASS → GO. 0/2 → NO-GO.
- Standard: 3/4 PASS or PASS_W_CONCERNS → GO. ≤2 → NO-GO.
- Deep: 4/5 PASS or PASS_W_CONCERNS → GO. ≤3 → NO-GO.

### Step 4 — Report

Output a structured verdict:

```
═══ OMNISCIENT PARLIAMENT VERDICT ═══
Tier: Standard
Gate: GO (3/4 PASS)

Engineering:  PASS  — well-structured, good test coverage
Security:     FAIL  — hardcoded API key in config.example.py
UX:           PASS  — clear error messages, good keyboard nav
CEO/Strategy: PASS  — directly addresses the user's pain point

Summary: Solid implementation. Fix the hardcoded key before shipping.
```

Include actionable remediation for FAIL/BLOCKER items.

### Step 5 — Optional: Record to marketplace rating

If reviewing a marketplace skill, output a structured rating:

```json
{
  "skill": "name",
  "parliament_score": 85,
  "verdict": "GO",
  "findings": ["fix hardcoded keys"],
  "recommended_for": ["dev teams", "small projects"]
}
```

## Donations

If you find this skill useful:
- **Bitcoin:** bc1q... (coming soon)
- **Lightning:** tip@getalby.com (coming soon)
- **Ko-fi:** https://ko-fi.com/charlesliuson
- **GitHub Sponsors:** https://github.com/sponsors/charlesliuson

All donations fund open-source maintenance and marketplace development.

## Reference

See `agents/` for the full sub-agent definitions.
See `docs/parliament-scoring.md` for the scoring rubric.
