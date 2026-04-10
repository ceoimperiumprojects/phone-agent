# LinkedIn Post Skill

## Purpose
Post content on LinkedIn from the phone app.

## Prerequisites
- LinkedIn app installed and logged in
- Content prepared in message

## Steps
1. Launch LinkedIn: `launch_app("com.linkedin.android")`
2. Wait for home screen: `wait_for_element("Home")`
3. Tap the post button: `find_and_tap("Post")` or `find_and_tap("Start a post")`
4. Wait for editor: `wait_for_element("What do you want to talk about?")`
5. Tap text area: `find_and_tap("What do you want to talk about?")`
6. Type the post content: `type_text(content)`
7. Tap Post button: `find_and_tap("Post")`
8. Verify: `wait_for_element("Your post has been shared")`
9. Return home: `press_home()`

## Error Handling
- If step 3 fails: scroll up and try again
- If step 7 fails: look for "Done" or "Share" button instead
- If app crashes: relaunch and retry from step 1
- Max retries: 3

## Rate Limits
- Max 3 posts per day
- Min 4 hours between posts
- Best posting times: 08:00, 12:00, 17:00
