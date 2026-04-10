# PhoneAgent Schedule

## Daily Routine

| Time | Skill | Notes |
|------|-------|-------|
| 08:00 | linkedin-post | Morning post (if scheduled) |
| 09:00 | linkedin-engage | Like + comment on feed |
| 10:00 | linkedin-outreach | 10 connection requests |
| 13:00 | linkedin-engage | Midday engagement round |
| 16:00 | linkedin-outreach | 10 more connection requests |
| 18:00 | linkedin-engage | Evening engagement |

## Always-On (event-driven)
- Instagram DM -> instagram-dm skill (< 60 sec response)
- LinkedIn comment notification -> linkedin-engage skill
- WhatsApp message -> TBD

## Rate Limits (per day)
- LinkedIn posts: 3
- LinkedIn likes: 30
- LinkedIn comments: 10
- LinkedIn connections: 20
- Instagram DM responses: 100

## Anti-Detection Rules
- Random delay 0.5-2s between every action
- Session start varies +/-30 min from schedule
- 5-10 min breaks between skill runs
- Skip 1 random session per day
- Weekend: 50% activity only
