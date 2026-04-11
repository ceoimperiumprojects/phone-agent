# LinkedIn — UI Map & Flows

Package: `com.linkedin.android`
Screen: 1080x2408 (Samsung A14)
App bounds: y=64 to y=2273 (below that = Android system nav)

## IMPORTANT: uiautomator WORKS on LinkedIn

Despite initial failures, `uiautomator dump` works reliably. The phone_fast.sh `screen` parser had a bug. Use raw ADB dump instead:
```bash
ADB="adb -s 192.168.1.146:5555"
$ADB shell "uiautomator dump /sdcard/ui.xml" && $ADB pull /sdcard/ui.xml /tmp/ui.xml
```
Then parse with Python to get exact coordinates. ALWAYS prefer this over guessing from screenshots.

## Bottom Nav Bar (VERIFIED 2026-04-10)

| Tab | X | Y | Notes |
|-----|---|---|-------|
| Home/Feed | 113 | 2205 | Main feed |
| My Network | 326 | 2205 | Connections, invitations |
| Post (+) | 539 | 2205 | Create post button |
| Notifications | 752 | 2205 | Bell icon |
| Jobs | 965 | 2205 | Job listings |

**CRITICAL:** Nav bar Y=2205, NOT 2340. Y=2340+ hits Android system nav bar!
Hit area per tab: y=2138 to y=2273.

## Top Bar (VERIFIED 2026-04-10)

| Element | X | Y | Notes |
|---------|---|---|-------|
| Back arrow | 68 | 132 | When in sub-page |
| Search bar | 540 | 126 | Tap to search (bounds: [169,81][911,171]) |
| Profile pic | 60 | 120 | Opens profile/menu (on home screen) |
| Messaging icon | 980 | 120 | Opens DM inbox (on home screen) |

## Search Filters (VERIFIED 2026-04-10)

After searching, filter tabs appear at y=268:

| Filter | X | Y |
|--------|---|---|
| Posts | 107 | 268 |
| People | 296 | 268 |
| Products | 515 | 268 |
| Jobs | 716 | 268 |
| Companies | 937 | 268 |

After tapping People, connection filters appear:

| Filter | X | Y |
|--------|---|---|
| 1st connections | 456 | 268 |
| 2nd connections | 596 | 268 |
| 3rd+ connections | 747 | 268 |

## Connect Buttons

In search results and My Network, Connect buttons are at **x=989** (right side).
Y varies per person (use uiautomator to get exact position).
Look for `content-desc="Invite [Name] to connect"` in UI dump.

After connecting: changes to "Pending, click to withdraw invitation sent to [Name]"

## Flows

#### Open Feed
Last verified: 2026-04-10
1. `$PF nav linkedin` → wait 3s
2. Lands on feed automatically (or tap Home: `$PF tap 113 2205`)

#### My Network / Connections
Last verified: 2026-04-10
1. `$PF nav linkedin` → wait 3s
2. Tap My Network: `$PF tap 326 2205`
3. "Grow" tab shows: Invitations at top, "People you may know" below
4. "Catch up" tab shows: Job changes, birthdays, work anniversaries
5. Connect buttons at x=989, Y varies per person

#### Search People
Last verified: 2026-04-10
1. Tap search bar: `$PF tap 540 126`
2. Type query: `$PF type "digital%smarketing%sBelgrade"`
3. Press enter: `$PF key enter`
4. Tap "People" filter: `$PF tap 296 268`
5. Results show with Connect buttons at x=989
6. Use uiautomator dump to get exact names, titles, positions

#### Send Connection Request
Last verified: 2026-04-10
1. Find Connect button via uiautomator (look for "Invite [Name] to connect")
2. Tap the coordinates
3. Connection sent immediately (no confirmation dialog by default)
4. Status changes to "Pending"

#### Open DMs / Messaging
Last verified: 2026-04-10
1. From feed: tap messaging icon top-right (~980, 120)
2. Or from anywhere: DM icon changes position based on context
3. Inbox shows: Focused, Jobs, Unread, Drafts tabs
4. Tap conversation to open, text input at bottom

#### Open Profile
Last verified: not yet
1. `$PF nav linkedin` → wait 3s
2. Tap profile pic: `$PF tap 60 120`

#### Create Post
Last verified: not yet
1. `$PF nav linkedin` → wait 3s
2. Tap Post (+): `$PF tap 539 2205`
3. Tap text area (use uiautomator to find)
4. Type content
5. Tap "Post" button (top right)

#### Engage — Like/Comment on Feed
Last verified: not yet
1. Go to feed (Home tab)
2. Use uiautomator dump to find Like/Comment buttons per post
3. Like/Comment positions vary per post — always dump first

## Pre-built Skill Docs
- `/media/pavle/Data/Projects 1/PhoneAgent/skills/linkedin-post.md`
- `/media/pavle/Data/Projects 1/PhoneAgent/skills/linkedin-engage.md`
- `/media/pavle/Data/Projects 1/PhoneAgent/skills/linkedin-outreach.md`

## Tips
- **ALWAYS use uiautomator dump** for dynamic content (search results, feed, invitations)
- Bottom nav bar and search filters are STABLE — safe to use memorized coordinates
- Connect buttons are always at x=989 in list views
- LinkedIn app launches to your PROFILE if opened fresh, press Back to get to feed
- `$PF screen` parser may fail — use raw `$ADB shell uiautomator dump` + Python parse instead
- scrcpy v3.3.4 works for live screen mirroring: `/tmp/scrcpy-linux-x86_64-v3.3.4/scrcpy --serial=192.168.1.146:5555 --no-control`
