# LinkedIn Outreach Skill

## Purpose
Send connection requests to targeted professionals.

## Parameters
- target_role: "CEO" | "CTO" | "Founder"
- target_location: "Serbia" | "Western Balkans"
- target_industry: "Tech" | "AI" | "SaaS"
- daily_limit: 20
- message_template: personalized based on profile

## Steps
1. Launch LinkedIn
2. Tap Search: `find_and_tap("Search")`
3. Type search query: `type_text("{target_role} {target_location} {target_industry}")`
4. Tap People filter: `find_and_tap("People")`
5. For each result (max daily_limit):
   a. Tap on profile
   b. `get_screen_text()` -> read headline, bio, company
   c. Generate personalized message using LLM:
      - Reference their role/company
      - Brief value prop
      - Max 3 sentences
   d. Tap Connect: `find_and_tap("Connect")`
   e. Tap "Add a note": `find_and_tap("Add a note")`
   f. Type message: `type_text(personalized_message)`
   g. Tap Send: `find_and_tap("Send")`
   h. Press back: `press_back()`
   i. Wait: random 30-90 seconds
6. Log: save name, company, message to outreach-log.csv

## Error Handling
- "Connect" not visible -> already connected, skip
- "Pending" visible -> already sent, skip
- "Follow" only -> premium required, skip
- Rate limit warning -> stop for today

## Anti-Detection
- Random delays between ALL actions (0.5-2 seconds)
- Vary session start time by +/-30 minutes
- Skip weekends occasionally
- Never exceed 25 connections/day
