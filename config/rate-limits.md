# Rate Limits

## LinkedIn
- Connection requests: 20/day (hard max 25)
- Posts: 3/day
- Comments: 10/day
- Likes: 30/day
- Profile views: 50/day
- Messages: 25/day
- Min delay between actions: 20-60 seconds (random)

## Instagram
- DM responses: 100/day
- Follows: 20/day
- Likes: 50/day
- Comments: 15/day
- Min delay between actions: 10-30 seconds (random)

## WhatsApp
- Messages: unlimited (responding only)
- No outbound spam

## General
- Max continuous session: 45 minutes, then 10 min break
- Action cooldown: min 0.5s between any two actions
- If rate limit warning detected: stop skill immediately, cooldown 2 hours
