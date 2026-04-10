# Instagram Profile Analyzer Skill

## Purpose
Analyze an Instagram profile and return structured data for lead scoring.
Used by influencer-leadgen as a sub-skill.

## Input
- Instagram profile URL or username

## Steps
1. Launch Instagram (if not open)
2. Navigate to profile:
   - If on Instagram: tap Search, type username, tap result
   - If URL: open in Chrome, it redirects to app
3. `get_screen_text()` -> extract all visible info

## Data Points to Extract

### From profile header:
- username (handle)
- display_name
- bio_text
- follower_count (parse "12.5K" -> 12500)
- following_count
- post_count
- is_verified (blue check)
- is_business (contact buttons visible)
- has_email (email in bio)
- has_website (link in bio)
- profile_category (if business: "Fitness Trainer", "Restaurant", etc)

### From recent posts (scroll grid):
- last_post_date (how recent)
- avg_likes (sample 3-6 visible posts)
- avg_comments (sample 3-6 visible posts)
- content_type: photos / reels / mix
- aesthetic: professional / casual / raw

### Calculated:
- engagement_rate = (avg_likes + avg_comments) / followers * 100
- follower_ratio = followers / following
- activity_score: daily / weekly / monthly poster
- lead_score: A / B / C / SKIP

## Lead Scoring Matrix

| Score | Followers | Engagement | Ratio | Activity | Bio |
|-------|-----------|------------|-------|----------|-----|
| A | 5K-50K | >3% | >2.0 | weekly+ | has email/link |
| B | 1K-10K | >2% | >1.5 | weekly+ | niche keywords |
| C | 1K-50K | >1% | >1.0 | monthly+ | any |
| SKIP | <1K or >50K | <1% | <1.0 | inactive | - |

## Output Format
```json
{
  "username": "@fitmarija",
  "name": "Marija Petrovic",
  "followers": 12500,
  "following": 3200,
  "posts": 340,
  "engagement_rate": 4.2,
  "follower_ratio": 3.9,
  "bio": "Fitness | Healthy lifestyle | Belgrade 📍",
  "has_email": true,
  "has_website": true,
  "lead_score": "A",
  "niche_match": true,
  "notes": "Professional photos, consistent posting, local audience"
}
```
