# Instagram Influencer Lead Generation Skill

## Purpose
Find nano/micro influencers (1K-50K followers) in a target niche,
analyze their profile, and send personalized collaboration DMs.

## Parameters
- niche: "fitness" | "food" | "beauty" | "tech" | "fashion" | "travel" | custom
- location: "Serbia" | "Balkans" | "Europe" | any
- follower_range: [1000, 50000]
- daily_limit: 30 DMs
- client_name: brand name for the outreach
- client_offer: what we're offering (free product, paid collab, affiliate)

## Phase 1: Discovery — Find Influencers

### Method A: Hashtag Search
1. Launch Instagram: `launch_app("com.instagram.android")`
2. Tap Search: `find_and_tap("Search")`
3. Type niche hashtag: `type_text("#{niche}serbia")` (e.g. #fitnesserbia)
4. Tap Tags tab: `find_and_tap("Tags")`
5. Open top hashtag result
6. Switch to "Recent" posts (not Top — less competition there)
7. For each post:
   a. Tap on post
   b. Tap on username to open profile
   c. Go to Phase 2 (Analyze)
   d. Press back twice to return to hashtag feed
   e. Scroll to next post

### Method B: Explore Page
1. Tap Search/Explore icon
2. Tap search bar
3. Type niche keyword: `type_text("{niche} {location}")`
4. Tap "Accounts" tab
5. Browse results, open each profile
6. Go to Phase 2 (Analyze)

### Method C: Competitor Followers
1. Go to a known bigger influencer in the niche
2. Tap "Followers"
3. Browse follower list — many will be micro influencers themselves
4. Open promising profiles
5. Go to Phase 2 (Analyze)

## Phase 2: Analyze Profile

1. `get_screen_text()` -> extract:
   - **Username**
   - **Full name**
   - **Bio text**
   - **Follower count** (must be between follower_range)
   - **Following count**
   - **Post count**
   - **Email in bio** (bonus — direct contact)
   - **Link in bio** (website = more serious creator)

2. Quick quality check:
   - follower/following ratio > 1.5 (not follow-for-follow)
   - Post count > 30 (active creator)
   - Recent post < 7 days ago (still active)
   - Bio has niche keywords
   - NOT a brand/business account (we want creators)

3. Scroll down to see recent posts:
   - `scroll_up()` to see grid
   - Check post engagement: likes/comments relative to followers
   - Engagement rate > 2% = good, > 5% = great
   - Note content style: photos, reels, stories

4. Score the lead:
   - A-tier: 5K-50K followers, >3% engagement, niche match, has email
   - B-tier: 1K-10K followers, >2% engagement, niche match
   - C-tier: everything else that passes basic checks
   - SKIP: below 1K, inactive, follow-for-follow, wrong niche

5. If SKIP: `press_back()`, continue to next
6. If A/B/C-tier: Go to Phase 3

## Phase 3: Send Personalized DM

1. Tap Message button: `find_and_tap("Message")`
2. Wait for chat to load: `wait_for_element("Message...")`
3. Tap message input: `find_and_tap("Message...")`

4. Generate personalized message using LLM with context:
   - Their name (from profile)
   - Their niche/content style (from bio + posts)
   - Specific post reference (shows we actually looked)
   - Client offer (from parameters)

5. Message templates (LLM picks and personalizes):

### Template A: Direct Collab
```
Zdravo {name}! 👋
Pratim tvoj content o {niche} i bas mi se svidja stil koji imas,
posebno onaj post o {specific_reference}.
Radim sa brendom {client_name} i mislim da bi odlicno pasovali
za saradnju. Da li bi te zanimalo da cujes vise? 🙌
```

### Template B: Product Gifting
```
Hej {name}! Videla/o sam tvoj profil i odusevljen/a sam
kako predstavljas {niche} content.
{client_name} bi voleo/la da ti posalje {product} na poklon,
bez ikakvih obaveza. Ako ti se svidi, bilo bi super da
podelis utisak sa svojom publikom.
Sta kazes? 😊
```

### Template C: Paid Collaboration
```
Zdravo {name}!
Imam super priliku za saradnju sa {client_name}.
Trazimo kreatore sa autenticnim stilom u {niche} niši
i tvoj profil je upravo to sto nam treba.
Radi se o placenom partnerstvu. Da li imas vremena
da popricamo o detaljima? 💼
```

6. Type message: `type_text(personalized_message)`
7. Send: `find_and_tap("Send")` or `press_enter()`
8. Go back: `press_back()`

## Phase 4: Log & Track

Save to `logs/influencer-outreach.csv`:
```
date,username,name,followers,engagement_rate,tier,niche,message_sent,status
2026-04-10,@fitmarija,Marija P,12500,4.2%,A,fitness,Template A,sent
```

## Phase 5: Follow-Up (next day)

1. Check `logs/influencer-outreach.csv` for yesterday's sends
2. Open Instagram DMs
3. For each sent message:
   - If REPLIED: flag as "interested", notify owner
   - If SEEN but no reply (after 48h): send follow-up
   - If NOT SEEN: skip (will check again tomorrow)

### Follow-up message:
```
Hej {name}, samo da proverim da li si videla/o moju poruku?
Ako te zanima saradnja sa {client_name}, rado bih ti
poslala/o vise detalja. Nema pritiska! 😊
```

Max 1 follow-up per person. If no response after follow-up -> mark as "cold", move on.

## Error Handling
- "Action Blocked" popup -> STOP immediately, wait 24h, reduce daily limit by 50%
- Can't find Message button -> account might be private, skip
- DM request goes to "Message Requests" -> normal for first contact, no action needed
- Profile not loading -> network issue, wait 10s and retry
- Account is private -> skip (can't analyze without following)

## Anti-Detection (CRITICAL for Instagram)
- Random delay 30-90 seconds between each profile visit
- Random delay 60-120 seconds between each DM sent
- Max 30 DMs per day (start with 15, increase gradually)
- Vary session length: 20-40 minutes
- Sessions: max 3 per day (morning, afternoon, evening)
- Mix DM outreach with normal behavior (browse feed, like posts, watch stories)
- First week: only 10 DMs/day to warm up the account
- If using new account: 3 days of normal usage before any outreach
- NEVER send identical messages — every DM must be unique
- Random typos/emoji variation to appear human

## Metrics to Track
- DMs sent per day
- Response rate (target: >15%)
- Positive response rate (target: >8%)
- Deals closed
- Cost per lead (LLM tokens / leads generated)
- Best performing template
- Best performing niche
- Best time of day for responses
