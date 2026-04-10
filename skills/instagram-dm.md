# Instagram DM Responder Skill

## Purpose
Auto-respond to Instagram DMs for business accounts.

## Trigger
Notification from com.instagram.android containing "sent you a message"

## Steps
1. Open notification tap (or launch Instagram)
2. If launched fresh: `find_and_tap("Messenger")` or DM icon (paper plane)
3. Tap on the unread conversation (has bold text / blue dot)
4. Read the last message: `get_screen_text()` -> extract message
5. Identify message type:
   - Price question -> respond with price list from knowledge base
   - Availability/schedule -> check schedule, suggest slot
   - Location question -> send address + directions
   - Complaint -> apologize, escalate to owner
   - Unknown -> "Hvala na poruci! Javicemo vam se uskoro"
6. Tap message input field: `find_and_tap("Message...")`
7. Type response: `type_text(response)`
8. Send: `find_and_tap("Send")` or `press_enter()`
9. Go back: `press_back()`
10. Log: timestamp, user, message type, response

## Knowledge Base Files
- config/prices.md — all services and prices
- config/schedule.md — working hours
- config/faq.md — frequently asked questions
- config/escalation.md — when to forward to owner

## Rate Limits
- Response time target: < 60 seconds
- Max 100 DMs per day
- If unsure about answer: escalate, don't guess
