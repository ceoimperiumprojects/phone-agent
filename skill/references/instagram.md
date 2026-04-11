# Instagram — UI Map & Flows

Package: `com.instagram.android`
Screen: 1080x2408 (Samsung A14)

## Bottom Nav Bar

| Tab | X | Y | Notes |
|-----|---|---|-------|
| Home | ~100 | ~2340 | Feed |
| Search | ~300 | ~2340 | Explore/Search |
| Reels | ~540 | ~2340 | Reels tab |
| Shop | ~780 | ~2340 | Shopping |
| Profile | ~980 | ~2340 | Your profile |

## Top Bar

| Element | X | Y | Notes |
|---------|---|---|-------|
| Camera/Create | ~60 | ~120 | New post/story |
| DM icon | ~980 | ~120 | Direct messages |

## Flows

#### Open DMs
Last verified: not yet
1. `$PF nav instagram` → wait 3s
2. Tap DM icon (top right): `$PF tap 980 120`
3. Now in message inbox

#### Post Story
Last verified: not yet
1. `$PF nav instagram` → wait 3s
2. Tap your profile pic with "+" (top left, ~60, ~180)
3. Camera opens — capture or select from gallery

#### Search / Explore
Last verified: not yet
1. `$PF nav instagram` → wait 3s
2. Tap Search: `$PF tap 300 2340`
3. Tap search bar at top
4. Type query: `$PF type "search term"`

#### Post Photo
Last verified: not yet
1. Tap (+) create button
2. Select photo from gallery
3. Apply filters/edit
4. Write caption
5. Tap "Share"

#### View/Reply to DM
Last verified: not yet
1. Open DMs (above)
2. Tap conversation
3. Text input at bottom
4. Type reply and send

## Pre-built Skill Docs
- `/media/pavle/Data/Projects 1/PhoneAgent/skills/instagram-dm.md`

## Tips
- Instagram changes UI frequently — verify coordinates with screen read if something doesn't work
- Bottom nav is stable, top bar is mostly stable
- DM icon position may shift if there are unread badges
