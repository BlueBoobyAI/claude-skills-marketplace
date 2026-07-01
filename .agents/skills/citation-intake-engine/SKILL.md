---
name: "citation-intake-engine"
description: "Extract structured brand intelligence from unstructured web sources. Activates when users want to research a brand, extract intelligence, scrape brand copy, gather brand data, or build a brand dossier."
license: MIT
metadata:
  tier: "STANDARD"
  category: "Market Intelligence / Data Extraction"
---

# Citation Intake Engine

## Purpose

Extract structured brand intelligence from unstructured web sources. Feeds the brand-profile-decoder by gathering raw material from:

- **llms.txt** (structured brand data, if available)
- **About page** (brand story, founder narrative, mission/values)
- **10-20 product descriptions** (sampled across price tiers low/medium/high)
- **5-10 customer reviews** (sourced from product pages, testimonial sections, or third-party review sites)
- **Social media bios** (LinkedIn, Instagram, X/Twitter)
- **FAQ section** (common questions reveal customer pain points and brand positioning)

Every extracted claim is tagged with its source URL for evidence anchoring. No claim leaves this engine without a verifiable source.

## When to Use

This skill activates when the user says anything like:

- "research {store}"
- "extract intelligence on {brand}"
- "gather brand data for {domain}"
- "build a brand dossier on redblossomtea.com"
- "scrape brand copy from {url}"
- "analyze {competitor} for market intelligence"
- "what does {brand}'s website tell us about their positioning"
- "intake {domain} for brand profile"
- "pull reviews and product data from {store}"

It does NOT handle brand voice analysis or persona generation -- that is the brand-profile-decoder's job. This skill only gathers raw material.

## Process

### Phase 1: Discover

1. **Try llms.txt first (fast path).** Fetch `https://{domain}/llms.txt`. If it returns structured content (brand description, product list, pricing), extract everything and mark as high-confidence.
2. **Fall back to llms.txt fallback variants** if bare llms.txt is 404: `https://{domain}/llms-full.txt`, `https://{domain}/.well-known/llms.txt`.
3. **Try sitemap.xml** if llms.txt variants all 404. Fetch `https://{domain}/sitemap.xml` to discover page layout (About, product pages, FAQ paths).
4. **Fetch the homepage** as the last discovery step. Extract all internal links, categorize them (about, products, blog, FAQ, reviews, contact).
5. **If all discovery fails**, report the domain as unreachable and recommend the user supply known page paths.

### Phase 2: Extract Pages

For each discovered or inferred page type:

| Source Type | Min Count | Sampling Strategy |
|-------------|-----------|-------------------|
| About page | 1 | The primary `/pages/about` or `/about` URL |
| Product pages | 10-20 | Sample across low/medium/high price tiers. Use sitemap if available, or collection pages. |
| Reviews | 5-10 | Product page review sections, `/pages/reviews`, `/testimonials`, or third-party (Trustpilot, Google) via web search |
| FAQ | 1 | `/pages/faq`, `/faq`, or `/support` |
| Social bios | 1-3 per platform | LinkedIn, Instagram, X/Twitter via web search with site:linkedin.com + brand name |

Extraction rules:
- For product pages: extract title, price, description, key features/selling points, ingredients/materials, dimensions.
- For reviews: extract the review text, rating, reviewer name (if public), date (if available), and which product it's for.
- For About pages: extract founding story, mission statement, team size, location, year founded.
- For FAQs: extract question + answer pairs verbatim.

### Phase 3: Structure Output

Aggregate all extracted intelligence into a structured JSON document. Tag every claim with `source` (the exact URL it came from). Run the output through the structured schema validator (Python3 script).

Validation checks:
- Every `claims[].source` is a non-empty string starting with `http` or `https`.
- Product sampling covers at least 3 distinct price tiers within the store's range.
- At least 3 source types are represented (About + Products + one more).
- If llms.txt was available, flag it in `sources_checked` with a `"fast_path": true` marker.

### Phase 4: Handoff

Pass the structured output directly to brand-profile-decoder if it's the next step in the pipeline. Otherwise, save to a temporary file and present the summary to the user.

## Output Schema

```json
{
  "domain": "redblossomtea.com",
  "sources_checked": ["llms.txt", "/pages/about", "/products/*", "/pages/faq"],
  "sources_found": ["/pages/about", "/products/*", "/pages/faq"],
  "fast_path_via_llms": false,
  "intelligence": {
    "brand_voice": {
      "claims": [
        {"text": "family-owned since 1985", "source": "https://redblossomtea.com/pages/about"},
        {"text": "specializes in premium Chinese and Taiwanese teas", "source": "https://redblossomtea.com/pages/about"},
        {"text": "second-generation, woman-owned business in San Francisco", "source": "https://redblossomtea.com/pages/about"}
      ],
      "confidence": "HIGH",
      "notes": "Consistent voice across About page and product descriptions"
    },
    "product_taxonomy": {
      "categories": ["oolong", "green", "black", "puerh", "white", "gift-sets"],
      "pricing_logic": "premium",
      "price_range": {"low": 8.00, "mid": 24.00, "high": 120.00},
      "source_products": 14,
      "top_selling_signals": ["Dragon Pearl Jasmine Supreme appears first on multiple collection pages"]
    },
    "customer_sentiment": {
      "positive_ratio": 0.88,
      "common_phrases": ["high quality", "beautiful packaging", "authentic", "arrived fresh", "great for gifting"],
      "common_complaints": ["pricey", "limited selection", "shipping is slow to east coast"],
      "source_reviews": 8,
      "avg_rating": 4.6
    },
    "competition_signals": [
      {"text": "positions against generic tea brands with 'direct from source' narrative", "source": "https://redblossomtea.com/pages/about"},
      {"text": "FAQ compares freshness window to grocery store tea", "source": "https://redblossomtea.com/pages/faq"}
    ],
    "faq_insights": {
      "question_count": 12,
      "top_pain_points_addressed": ["How long does tea stay fresh?", "Do you ship internationally?", "What is the return policy?"],
      "source": "https://redblossomtea.com/pages/faq"
    },
    "social_presence": {
      "linkedin": {"bio": "San Francisco's premier Chinese tea company since 1985", "found": true, "source": "https://linkedin.com/company/redblossomtea"},
      "instagram": null,
      "twitter": null
    },
    "gaps": [
      "No Instagram bio found",
      "No X/Twitter bio found",
      "Only 8 reviews extracted (target was 10); supplement via web search next pass"
    ]
  }
}
```

## Success Criteria

1. **At least 3 source types are found** (About + Products + at least one of: Reviews, FAQ, Social, llms.txt).
2. **Every claim has a source URL** -- no orphaned intelligence.
3. **Product sampling covers low/medium/high price tiers** -- verify by comparing extracted prices against the full catalog price range.
4. **llms.txt is checked first** -- record whether it was found (fast path) or not.
5. **Output is directly consumable by brand-profile-decoder** -- same JSON contract, no reformatting needed.
6. **If fewer than 3 source types found**, list the missing ones in `gaps` and recommend manual research to fill them.

## Tools Used

- **WebFetch**: Primary extraction tool. Fetch each page individually (About, product pages, FAQ, reviews). For product pages, batch fetch in parallel across price tiers. For llms.txt, single fast fetch.
- **web_search (Tavily)**: Find social media profiles (site:linkedin.com "Red Blossom Tea Company"), third-party review pages (site:trustpilot.com "Red Blossom Tea"), and alternative sources when primary pages 404.
- **Playwright**: When WebFetch fails due to JavaScript rendering (single-page apps, dynamic content stores). Navigate to the page, wait for content to render, extract text. Use for social media profile pages.
- **Python3**: Output validation -- run the structured JSON through a schema checker that verifies source coverage, price tier distribution, and required fields.

## Example Interaction

```
User: "research harney.com for a brand dossier"

Skill:
1. Fetch https://harney.com/llms.txt -- 404, fallback variants also 404. Mark llms as not found, note as gap.
2. Fetch https://harney.com/sitemap.xml -- discover pages: /pages/about-us, /collections/black-tea, /collections/green-tea, /collections/gift-sets, /pages/faq, /pages/reviews
3. Fetch About page: extract founding year (1983), founder (John Harney), location (Millerton, NY), mission ("fine teas for everyone").
4. Fetch 12 products across tiers:
   - Low ($8-12): English Breakfast, Earl Grey Supreme
   - Medium ($15-25): Paris, Hot Cinnamon Spice
   - High ($30+): Aged Puerh, Dragon Pearl gift set
5. Fetch FAQ: 15 Q&A pairs about shipping, steeping, storage.
6. Fetch reviews page: 10 customer reviews, avg rating 4.5.
7. Search web for social: LinkedIn bio "family-owned tea company since 1983". X bio "Tea company. Est. 1983."
8. Validate output with Python3 schema checker -- passes (4 source types, 12 products across 3 tiers, all claims sourced).
9. Present structured JSON and offer to feed it to brand-profile-decoder.

User: "yes, feed it to brand-profile-decoder"

10. Pass the JSON directly to brand-profile-decoder with a note that llms.txt was missing (gap for next pass).
```

## Installation

```bash
skills-god.sh ensure citation-intake-engine
```
