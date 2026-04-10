# LinkedIn Engagement Skill

## Purpose
Respond to comments on my posts and engage with network.

## Trigger
Notification from com.linkedin.android containing "commented"

## Steps — Reply to Comment
1. Launch LinkedIn: `launch_app("com.linkedin.android")`
2. Tap Notifications tab: `find_and_tap("Notifications")`
3. Find the notification about comment: `find_and_tap("commented")`
4. Read the comment: `get_screen_text()` -> extract comment text
5. Generate reply using LLM (max 2 sentences, conversational)
6. Tap Reply: `find_and_tap("Reply")`
7. Type reply: `type_text(reply)`
8. Send: `find_and_tap("Send")` or `find_and_tap("Post")`
9. Return: `press_back()` twice

## Steps — Proactive Engagement
1. Launch LinkedIn
2. Scroll feed: `scroll_up()` x3
3. For each post visible:
   a. `get_screen_text()` -> read post content
   b. If post is from target network (founders, tech, Serbia):
      - Tap Like: `find_and_tap("Like")`
      - Optional: tap Comment, write thoughtful reply
4. Repeat 3x per session

## Rate Limits
- Max 30 likes per day
- Max 10 comments per day
- Random pause 20-60 seconds between actions
- Sessions at 09:00, 13:00, 18:00
