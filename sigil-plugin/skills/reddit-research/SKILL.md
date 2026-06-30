---
name: reddit-research
description: Multi-subreddit research engine using Reddit MCP tools (not WebFetch). Searches subreddits, reads top/hot/new posts and comments, and synthesizes findings into structured reports. Never falls back to WebFetch for Reddit URLs.
triggers:
  - "research this on reddit"
  - "what is reddit saying about"
  - "find reddit discussions about"
  - "search reddit for"
  - "check reddit for"
  - "reddit pulse check"
  - "what are people saying on reddit"
  - "top reddit threads about"
  - "reddit sentiment on"
  - "reddit research"
  - "crowdsource this on reddit"
  - "survey reddit"
  - "reddit mcp"
allowed-tools:
  - mcp__reddit-mcp__get_subreddit_hot_posts
  - mcp__reddit-mcp__get_subreddit_top_posts
  - mcp__reddit-mcp__get_subreddit_new_posts
  - mcp__reddit-mcp__get_subreddit_rising_posts
  - mcp__reddit-mcp__get_subreddit_info
  - mcp__reddit-mcp__get_post_content
  - mcp__reddit-mcp__get_post_comments
  - mcp__reddit-mcp__get_frontpage_posts
  - Bash
  - Read
  - Write
  - Agent
  - WebSearch
---

# Reddit Research

Multi-subreddit research engine powered by Reddit MCP tools. Unlike WebFetch (which is blocked for Reddit URLs), this skill uses native Reddit MCP tools — it works reliably in every session.

**Why this exists:** WebFetch consistently fails on Reddit URLs ("Unable to fetch from www.reddit.com"). The `mcp__reddit-mcp__*` tools provide structured access to subreddits, posts, and comments. This skill wraps them in a repeatable research pipeline.

---

## When to Invoke

- Before making product/market decisions — Reddit is the best unfiltered signal on user sentiment
- Researching competitor reception, complaints, and feature requests
- Finding content ideas for blog posts or social proof citations
- Validating whether a problem is real vs. manufactured
- Any time someone says "check what people are saying about X"
- Before coding: research existing solutions, complaints, and feature requests

---

## Pipeline

### Step 1 — Determine research scope

Ask clarifying questions if the scope is vague:

- **Topic**: What exactly are we researching? (competitor, product category, problem space)
- **Target subreddits**: Specific ones named, or auto-detect from topic?
- **Depth**: Quick pulse check (top 10 hot posts) or deep dive (across 3+ subreddits, with comments)?
- **Output**: Raw data dump, synthesized report, or Sigil assessment?

Default to **Medium depth** unless specified:
- Quick: 1 subreddit, 10 hot posts, titles + scores only
- Medium: 2-3 subreddits, 10 top posts each, top comment threads
- Deep: 3-5 subreddits, 20 posts each (hot + top + new), full comment trees

---

### Step 2 — Gather subreddit data

Use Reddit MCP tools to pull data. NEVER use WebFetch for Reddit URLs.

**For subreddit discovery:**
```
1. Identify relevant subreddits from topic keywords:
   - Product/tool name → r/<product> or r/<tool>
   - Category → r/<category> (e.g., r/SaaS, r/devops)
   - Problem space → r/<problem> (e.g., r/ADHD_programmers)
   
2. Use get_subreddit_info() to validate:
   - Subscriber count (signal quality)
   - Description (relevance check)
   - Skip if dead (<100 subscribers)
```

**For post collection:**
```
3. Use get_subreddit_top_posts() for "evergreen best of" (specify time filter)
4. Use get_subreddit_hot_posts() for current pulse
5. Use get_subreddit_new_posts() for emerging discussions
6. Use get_post_content() for deep-reading individual posts + comments
```

---

### Step 3 — Read posts and comments

For each interesting post (score > 50, or topic-relevant, or from author with authority signals):

```
get_post_content(post_id=<id>, comment_limit=10, comment_depth=3)
```

Extract:
- **Title + content**: What is the post about?
- **Score + comment count**: engagement signal
- **Top comments**: the consensus, counter-arguments, and "actually..."
- **Author context**: throwaway account or established voice?

---

### Step 4 — Synthesize findings

After collecting data, structure the output:

**For a "what is Reddit saying about X" report:**

```
═══ REDDIT RESEARCH: [Topic] ═══

## Subreddits surveyed
- r/example (N subscribers) — N posts reviewed

## Key themes (ordered by frequency)
1. Theme 1 — appears in N posts — details
2. Theme 2 — appears in N posts — details

## Sentiment breakdown
- Positive: N posts — representative quotes
- Negative: N posts — representative complaints
- Neutral: N posts — informational/discussion

## Top posts by engagement
1. [Score N] "Title" — key takeaway
2. [Score N] "Title" — key takeaway

## Verbatim quotes (most insightful)
- "..." [source post, score]
- "..." [source post, score]

## Novel insights
- Things that surprised me
- Contradictions to conventional wisdom
- Underserved needs mentioned repeatedly

## Limitations
- What I didn't find (signal in silence)
- Subreddits I couldn't search
- Confidence level of each theme
```

**For a Sigil assessment on Reddit data (if user asks for it):**
Run the 5 lenses: Engineering, Security, UX, CEO/Strategy, QA — but with a note that evidence quality is ⚠️ (Reddit is noisy signal). Generate verdict within those limitations.

---

### Step 5 — Follow-up

Offer to:
- Deep-dive into specific posts or subreddits
- Cross-reference findings with other sources (web search, social proof weave)
- Monitor a subreddit for new posts on the topic
- Generate content from the findings (blog post, social media thread, social proof)
- Run a Sigil assessment on the synthesized findings

---

## Tool Reference

| Reddit MCP Tool | When to Use |
|----------------|-------------|
| `get_subreddit_hot_posts` | Current pulse — what's trending right now |
| `get_subreddit_top_posts` | Best of all time/month/week — signal-to-noise highest |
| `get_subreddit_new_posts` | Emerging discussions — lowest engagement but newest content |
| `get_subreddit_rising_posts` | About to trend — early signal |
| `get_subreddit_info` | Validate subreddit quality before diving in |
| `get_post_content` | Deep read — post body + comment tree |
| `get_post_comments` | Just the comments (when post body isn't needed) |
| `get_frontpage_posts` | Broad landscape — what's generally popular |

## Anti-patterns

❌ **Never use WebFetch for Reddit URLs** — it fails every time. Use the Reddit MCP tools instead.
❌ **Don't boil the ocean** — 3 subreddits at medium depth gives good signal. Going wider yields diminishing returns.
❌ **Don't cite Reddit as sole evidence** — Reddit is self-selecting. Add caveats like "r/ClaudeCode sentiment leans negative because users with problems post more."
❌ **Don't skip subreddit info** — a 50-subscriber subreddit gives different signal quality than a 50K one.
❌ **Don't read only top posts** — new posts catch emerging complaints that top posts miss.
