---
name: stakeholder-360
description: Multi-stakeholder assessment engine that maps stakeholder groups for any product/tool/project, spawns Sigil's 5 expert lenses per stakeholder, synthesizes paradigm-level improvement opportunities, and iterates on low-confidence findings until resolved.
triggers:
  - stakeholder 360
  - map stakeholders
  - paradigm improvement
  - stakeholder assessment
  - find the paradigm shift
  - what would 10x this
  - stakeholder analysis
  - assess the stakeholders
  - stakeholder map
  - opportunity analysis
  - what are we missing
  - blind spot analysis
allowed-tools:
  - Bash
  - Read
  - Write
  - Agent
  - AskUserQuestion
  - WebSearch
  - Grep
  - mcp__aeo-platform__web_search
  - mcp__reddit-mcp__get_subreddit_info
  - mcp__reddit-mcp__get_subreddit_top_posts
  - mcp__reddit-mcp__get_subreddit_hot_posts
  - mcp__reddit-mcp__get_post_content
  - mcp__reddit-mcp__get_post_comments
---

# Stakeholder 360

Multi-stakeholder assessment engine. Uses Sigil's 5 expert lenses (Engineering, Security, UX, CEO/Strategy, QA) against every stakeholder group of a product, tool, or project — then synthesizes paradigm-level improvement opportunities. Low-confidence findings trigger an iteration loop until confidence reaches threshold.

**How this differs from the general Sigil review:** The general Sigil skill reviews a single artifact (code, README, skill) through 5 lenses. This skill maps the *entire stakeholder ecosystem* of a product and applies the 5 lenses to each stakeholder group individually — producing paradigm improvements, not artifact certificates.

---

## When to Invoke

- Before building a product — understand who you're building for and what they actually need
- When a product isn't gaining traction — find the stakeholder gap you're missing
- Before a major pivot or strategy change — validate against all stakeholder perspectives
- After competitor research — identify paradigm-level improvements incumbents can't copy
- When someone says "we need a 10x improvement" — this is the process that finds it
- Any time you need a systematic blind spot analysis

---

## Pipeline

### Step 0 — Define the target

Ask the user to specify what is being assessed:

- **Product** (e.g., "Sigil certification authority")
- **Tool or skill** (e.g., "our reddit-research skill")
- **Project** (e.g., "AEO Sky marketplace")
- **Company or initiative** (e.g., "Alice's RBT content flywheel")
- **Idea** (e.g., "a marketplace for AI skills")

If the user's message already contains the target, extract it and proceed. If ambiguous, ask one clarifying question.

---

### Step 1 — Map stakeholder groups

Use the user's input + general knowledge + optional web research to identify all stakeholder groups. For each, document:

| Stakeholder | Relationship to target | What they need | Current workaround | Pain severity |
|-------------|----------------------|----------------|-------------------|---------------|
| ... | ... | ... | ... | HIGH/MEDIUM/LOW |

**Default stakeholder archetypes to check** (not all apply to every target):

- **End users** — the people who directly interact with the product
- **Buyers / decision makers** — the people who pay (may differ from users)
- **Contributors / authors** — people who create content, skills, or extensions
- **Integrators / platform operators** — marketplaces, hosting platforms, API consumers
- **Enterprise / compliance** — procurement, security teams, legal
- **Competitors** — incumbents in the same space
- **Newcomers / beginners** — people who would use it if they could figure out how
- **Agency / service providers** — people who build on top of or resell the product
- **Open source community** — maintainers, contributors, fork authors
- **Regulators / standards bodies** — if applicable (HIPAA, PCI-DSS, GDPR, AI Act)
- **Indirect beneficiaries** — people whose work improves even though they don't use the product directly (e.g., a CEO whose engineering team ships faster)

**Output:** A stakeholder map with 3-8 groups. Fewer than 3 = too narrow. More than 8 = too granular (merge similar groups).

---

### Step 2 — For each stakeholder group, spawn the 5 Sigil expert lenses

For every stakeholder group, spawn parallel agents — one per Sigil lens. Each receives:
1. The product definition
2. The stakeholder profile (who they are, what they need, their current workaround)
3. Their specific lens instructions
4. The citation discipline: ✅ ⚠️ ❌ markers on every claim

**All agents spawn concurrently across all stakeholder groups.** If you have 5 groups × 5 lenses = 25 agents, they all run in parallel (bounded by platform capacity).

**Lens 1 — Engineering**
```
You are the Engineering lens for the [product name] stakeholder assessment.
Stakeholder: [group name]
Their need: [what they need]
Current workaround: [how they solve this today]

Evaluate:
- Technical feasibility of serving this stakeholder well
- Integration complexity — what would they need to install, configure, or learn?
- Reliability — would this work reliably for them, or fail silently?
- Scale — does the current architecture support [N] users like this?
- Data flow — what data crosses boundaries, and is the engineering clean?

Output: 3-5 findings (positive or negative) with evidence markers.
```

**Lens 2 — Security**
```
You are the Security lens for the [product name] stakeholder assessment.
Stakeholder: [group name]

Evaluate:
- Attack surface expansion — does serving this stakeholder introduce new vectors?
- Data exposure — what does this stakeholder see, touch, or leak?
- Trust boundary — does this stakeholder need more trust than they warrant?
- Compliance — are there regulations this stakeholder brings that aren't handled?
- Secret handling — does the flow expose tokens, keys, or credentials?

Output: 3-5 findings with evidence markers.
```

**Lens 3 — UX**
```
You are the UX lens for the [product name] stakeholder assessment.
Stakeholder: [group name]

Evaluate:
- Onboarding friction — what does this stakeholder have to do before they get value?
- Mental model fit — does the product's concept map to how this stakeholder thinks?
- Error handling — what happens when things go wrong? Is the failure mode disclosed?
- Accessibility — can this stakeholder use it regardless of ability, language, or tech level?
- First-use-to-value time — minutes? hours? days?

Output: 3-5 findings with evidence markers.
```

**Lens 4 — CEO/Strategy**
```
You are the CEO/Strategy lens for the [product name] stakeholder assessment.
Stakeholder: [group name]

Evaluate:
- Willingness to pay — does this stakeholder perceive enough value to pay?
- Acquisition cost — how hard is it to reach and convince this stakeholder?
- Retention — once they try it, do they stay?
- Competitive moat — does serving this stakeholder make the product harder to copy?
- Opportunity cost — what else could we build instead of serving this stakeholder?
- Network effects — does serving this stakeholder make the product more valuable for others?

Output: 3-5 findings with evidence markers.
```

**Lens 5 — QA**
```
You are the QA lens for the [product name] stakeholder assessment.
Stakeholder: [group name]

Evaluate:
- Edge case of this stakeholder — what makes them different from other groups?
- Failure mode with this stakeholder — what breaks first?
- Support burden — will this stakeholder generate tickets? Misunderstandings?
- State explosion — does serving this stakeholder multiply the number of states the system must handle?
- Degradation — does serving this stakeholder make the experience worse for others?

Output: 3-5 findings with evidence markers.
```

---

### Step 3 — Synthesize across stakeholders

After all agents return (all stakeholder groups × 5 lenses), aggregate:

1. **Stakeholder correlation matrix** — which findings repeat across multiple groups?

   | Finding | Appears in (groups) | Appears in (lenses) | Pattern type |
   |---------|---------------------|---------------------|--------------|
   | Users can't verify quality | Skill Authors, Beginners, Enterprise | Engineering, CEO/Strategy, QA | Structural gap |
   | No cross-marketplace trust | Enterprise, Marketplace Ops | Security, QA | Missing protocol |

2. **Gap clusters** — group related findings into themes:
   - **Onboarding gap** — too many steps before first value
   - **Trust gap** — no way to verify claims
   - **Compatibility gap** — doesn't work with existing workflows
   - **Discovery gap** — stakeholders can't find each other
   - **Economics gap** — no one pays, no one builds

3. **Evidence quality assessment** — for each theme:
   - ✅ = mostly verified findings (agents cited sources)
   - ⚠️ = mix of verified and plausible
   - ❌ = mostly speculative — needs more research

---

### Step 4 — Identify paradigm-level improvements

For each gap cluster, ask:

**"What would a paradigm shift look like?"**

A paradigm shift is NOT:
- A feature addition ("add search" or "add ratings")
- A minor optimization ("make it faster")

A paradigm shift IS:
- A structural change that makes an entire gap cluster irrelevant
- Something incumbents can't easily copy (or it breaks their business model)
- A new abstraction layer that changes the competitive landscape

**For each candidate paradigm, evaluate:**
1. **Which stakeholders benefit** — who wins and who loses?
2. **Defensibility** — why can't competitors copy this in 6 months?
3. **Network effects** — does this get more valuable as more people use it?
4. **Revenue path** — can this be monetized?
5. **Implementation scope** — 1 week? 1 month? 3 months?

**Select the single best paradigm shift** — the one that:
- Covers the most gap clusters (high leverage)
- Is defensible against all identified competitors
- Has clear next steps

---

### Step 5 — Iteration loop on low confidence

After synthesis, check every finding and theme:

| Evidence quality | Action |
|-----------------|--------|
| All findings ✅ verified | Proceed to report. No iteration needed. |
| Any finding ⚠️ plausible | Mark as "needs verification" in report. Flag for iteration. |
| Any finding ❌ uncertain | **MUST iterate.** This is unresolved. |
| Any theme >50% unverified | **MUST iterate.** Run a targeted research pass. |

**Iteration pass:**

For findings marked for iteration:

1. **Identify what's missing** — what specific data would verify or refute the finding?
2. **Run targeted research:**
   - Use `mcp__aeo-platform__web_search` for competitor/product research
   - Use `mcp__reddit-mcp__*` tools for community sentiment
   - Use `WebSearch` for general internet research
   - Use `Agent` to deep-read a specific source
3. **Re-assess** — does the new data confirm, challenge, or change the finding?
4. **Update evidence markers** — ⚠️ → ✅ or ❌ based on new evidence
5. **If still ❌** — run another iteration. Max 3 iterations per finding.
6. **After 3 iterations still ❌** — mark as "INDETERMINATE" and flag for human investigation.

---

### Step 6 — Report

Output the final assessment:

```
═══ STAKEHOLDER 360: [Product Name] ═══

## Stakeholder Map
1. [Group] — [needs summary]
2. [Group] — [needs summary]
...

## Stakeholder × Lens Matrix
| Stakeholder | Engineering | Security | UX | CEO/Strategy | QA |
|------------|-------------|----------|-----|--------------|-----|
| Group 1    | PASS/FAIL   | ...      | ... | ...          | ... |
| Group 2    | ...         | ...      | ... | ...          | ... |

## Gap Clusters (sorted by leverage)
1. **[Cluster name]** — appears in [N] groups × [M] lenses
   - Findings: ...
   - Evidence quality: ✅/⚠️/❌
   - Paradigm shift: ...

2. **[Cluster name]** — ...

## Paradigm Improvement

### Recommendation: [Name of paradigm]

**What it is:** One-paragraph description.

**Which gaps it closes:**
- Gap 1: why this makes it irrelevant
- Gap 2: why this makes it irrelevant

**Defensibility:**
- Competitor A cannot copy because...
- Competitor B would break their model if they tried...

**Network effects:**
- More users → more X → more value
- Each new stakeholder group Y makes it Z for existing groups

**Build scope:** [Estimate]
- Phase 1: ...
- Phase 2: ...
- Phase 3: ...

**Risk if we don't build it:**
- Risk 1
- Risk 2

## Iteration Summary
- Iterations run: [N]
- Findings verified: [N]
- Findings resolved from ⚠️/❌ to ✅: [N]
- Indeterminate (3rd iteration exhausted): [N]
```



---

## Reference

This skill uses the same 5-lens system as the general Sigil certification skill (`skills/sigil/SKILL.md`), but applies it per-stakeholder-group rather than per-artifact.

Companion skills:
- **sigil** (`skills/sigil/SKILL.md`) — general purpose certification for single artifacts
- **reddit-research** (`skills/reddit-research/SKILL.md`) — Reddit MCP engine for the iteration loop research pass
- **readme-doctor** (`skills/readme-doctor/SKILL.md`) — README audit + rewrite for communicating findings

The iteration loop (Step 5) borrows from the adversarial verify gate in the sigil skill — the same "challenge and verify" logic, expanded for stakeholder research.
