# PhoneAgent — Kompletni Vodič

## Šta je PhoneAgent?

PhoneAgent je AI sistem koji kontroliše pravi Android telefon (Samsung Galaxy A14) sa tvog PC-ja. AI vidi ekran, čita tekst, tapne, swajpuje, kuca — kao da čovek drži telefon. Radi 24/7 na punjaču, bez da ga iko pipne.

```
Ti (PC) ──── AI Brain ──── ADB/SSH ──── Samsung A14 (ruke + oči)
```

## Kako funkcioniše?

1. **AI čita ekran** — `uiautomator dump` izvlači SVE UI elemente (tekst, dugmad, koordinate)
2. **AI odlučuje** — LLM analizira šta vidi i bira sledeću akciju
3. **AI izvršava** — ADB šalje tap/swipe/type komandu na telefon
4. **AI verifikuje** — ponovo čita ekran da proveri da li je akcija uspela
5. **Ponovi** — dok task nije gotov

## Pristup telefonu (3 načina)

### 1. SSH (terminal na telefonu)
```bash
ssh phone
# Ili puna komanda:
ssh -i ~/.ssh/phone_agent -p 8022 192.168.1.146
```
**Koristi za:** Termux komande, instalacija paketa, fajl sistema, skripte na telefonu.

### 2. ADB (kontrola UI-ja)
```bash
ADB="adb -s 192.168.1.146:5555"

# Tap na koordinate
$ADB shell input tap 540 1200

# Kucaj tekst
$ADB shell input text "Hello%sWorld"

# Swipe (scroll)
$ADB shell input swipe 540 1500 540 500

# Home / Back / Enter
$ADB shell input keyevent 3    # Home
$ADB shell input keyevent 4    # Back
$ADB shell input keyevent 66   # Enter

# Screenshot
$ADB shell screencap /sdcard/screen.png
$ADB pull /sdcard/screen.png /tmp/screen.png

# Čitanje ekrana (accessibility tree)
$ADB shell uiautomator dump /sdcard/ui.xml
$ADB pull /sdcard/ui.xml /tmp/ui.xml

# Otvori app
$ADB shell monkey -p com.instagram.android 1

# Instaliraj APK
$ADB install /path/to/app.apk

# Obriši app
$ADB shell pm uninstall -k --user 0 com.some.app
```
**Koristi za:** SVE što se tiče kontrole telefona — tapkanje, kucanje, otvaranje app-ova, instalacija.

### 3. scrcpy (vidiš ekran na PC-ju)
```bash
scrcpy --tcpip=192.168.1.146:5555

# Sa snimanjem
scrcpy --tcpip=192.168.1.146:5555 --record=demo.mp4

# Manja rezolucija (brže)
scrcpy --tcpip=192.168.1.146:5555 --max-size=1024
```
**Koristi za:** Debug, demo snimci, manuelna kontrola kad treba.

## Python Controller

```python
from phone_controller import PhoneController, APPS

phone = PhoneController(device_ip="192.168.1.146")

# Status
phone.get_device_info()
phone.get_battery_level()
phone.is_screen_on()

# Navigacija
phone.launch_app(APPS["linkedin"])
phone.press_home()
phone.press_back()

# Interakcija
phone.find_and_tap("Post")           # Nađi element po tekstu i tapni
phone.type_text("Hello World")       # Otkucaj tekst
phone.scroll_up()                     # Skroluj gore
phone.scroll_down()                   # Skroluj dole

# Čitanje
elements = phone.get_screen_text()    # Lista svih UI elemenata
summary = phone.get_screen_summary()  # Čitljiv pregled ekrana

# Čekanje
phone.wait_for_element("Home", timeout=10)  # Čekaj da se pojavi element

# Screenshot
phone.screenshot("/tmp/screen.png")

# Log
phone.save_log()
```

## App Package Names

| App | Package |
|-----|---------|
| LinkedIn | `com.linkedin.android` |
| Instagram | `com.instagram.android` |
| WhatsApp | `com.whatsapp` |
| Telegram | `org.telegram.messenger` |
| Chrome | `com.android.chrome` |
| YouTube | `com.google.android.youtube` |
| Gmail | `com.google.android.gm` |
| Maps | `com.google.android.apps.maps` |
| Camera | `com.sec.android.app.camera` |
| Play Store | `com.android.vending` |
| Facebook | `com.facebook.katana` |
| Messenger | `com.facebook.orca` |
| TikTok | `com.zhiliaoapp.musically` |
| Twitter/X | `com.twitter.android` |

## Kada koristiti PhoneAgent?

### UVEK koristi za:
- **Social media posting** — LinkedIn, Instagram, TikTok, X
- **DM odgovaranje** — Instagram, WhatsApp, Messenger
- **Engagement** — lajkovi, komentari, follow/unfollow
- **Lead generation** — influencer outreach, LinkedIn outreach
- **Monitoring** — Google Reviews, competitor cene, notifikacije
- **Cross-listing** — isti proizvod na više marketplace-ova

### NEMOJ koristiti za:
- Stvari koje se mogu uraditi preko API-ja brže (npr. email slanje — koristi Gmail API)
- Bulk data scraping (koristi Imperium Crawl umesto toga)
- Bilo šta što zahteva >5 minuta neprekidnog rada bez pauze (anti-detection)

## Kako se pišu skillovi?

Skillovi su `.md` fajlovi u `skills/` folderu. Svaki skill opisuje:
1. **Svrhu** — šta radi
2. **Trigger** — kada se pokreće (zakazano ili event-driven)
3. **Korake** — tačan redosled akcija sa `find_and_tap()`, `type_text()`, itd.
4. **Error handling** — šta kad nešto ne radi
5. **Rate limits** — koliko puta dnevno, pauze između akcija

### Šablon za novi skill:

```markdown
# [Ime Skilla]

## Purpose
[Jedna rečenica — šta ovaj skill radi]

## Trigger
- Scheduled: [vreme, npr. "08:00 svaki dan"]
- Event: [notifikacija, npr. "nova poruka od com.whatsapp"]

## Prerequisites
- [App instaliran i ulogovan]
- [Knowledge base fajl postoji]

## Steps
1. Launch app: `launch_app("com.app.package")`
2. Wait for load: `wait_for_element("Home")`
3. Navigate: `find_and_tap("Button text")`
4. Read screen: `get_screen_text()`
5. Type: `type_text("message")`
6. Confirm: `find_and_tap("Send")`
7. Verify: `wait_for_element("Sent")`
8. Return: `press_home()`

## Error Handling
- If step X fails: [alternativna akcija]
- If app crashes: relaunch and retry (max 3x)
- If rate limit: stop, wait 2h

## Rate Limits
- Max [N] actions per day
- Min [N] seconds between actions
- Sessions: [times]

## Logging
Save to logs/[skill-name].csv:
date, target, action, result, response_time
```

## Dnevni raspored (config/schedule.md)

| Vreme | Skill | Opis |
|-------|-------|------|
| 08:00 | linkedin-post | Jutarnji post |
| 09:00 | linkedin-engage | Lajkovi + komentari |
| 10:00 | linkedin-outreach | Connection requests |
| 13:00 | linkedin-engage | Podnevni engagement |
| 16:00 | linkedin-outreach | Još connection-a |
| 18:00 | linkedin-engage | Večernji engagement |
| Non-stop | instagram-dm | Odgovori na DM-ove (<60 sec) |

## Anti-Detection pravila

**KRITIČNO — poštuj ovo ili ban:**

1. **Random delay** između SVAKE akcije: 0.5-2 sekunde
2. **Random delay** između skill koraka: 20-90 sekundi
3. **Max sesija:** 45 minuta, pa 10 min pauza
4. **Mešaj aktivnosti:** ne radi samo outreach — lajkuj, skroluj feed, gledaj stories
5. **Nikad identične poruke** — svaka mora biti unikatna
6. **Warm-up novi nalog:** 3 dana normalne upotrebe pre automatizacije
7. **Vikend:** 50% aktivnosti
8. **Preskači random sesije:** 1 sesija dnevno se preskače

## Telefon specifikacije

| | |
|---|---|
| **Model** | Samsung Galaxy A14 (SM-A145R) |
| **Android** | 15 |
| **RAM** | 3.6GB (1.3GB slobodno posle debloat-a) |
| **Storage** | 107GB (102GB slobodno) |
| **WiFi IP** | 192.168.1.146 |
| **ADB** | WiFi na portu 5555 |
| **SSH** | Termux na portu 8022 |
| **Battery** | Uvek na punjaču |
| **Screen** | Uvek upaljen (stay_on_while_plugged_in) |
| **Lock** | NEMA — disabled |
| **Animacije** | OFF (0x scale) |
| **Debloated** | 90 paketa obrisano |

## Troubleshooting

### ADB ne vidi telefon
```bash
adb kill-server && adb start-server
adb connect 192.168.1.146:5555
```

### SSH ne radi
```bash
# Na telefonu u Termux-u:
sshd
# Ili restartuj telefon — Termux:Boot će pokrenuti sshd automatski
```

### Telefon se restartovao
Termux:Boot automatski pokreće:
- SSH server (sshd)
- Wake lock (WiFi ostaje aktivan)
Posle boota samo: `adb connect 192.168.1.146:5555`

### UI element se ne nalazi
1. Probaj `get_screen_text()` da vidiš šta je na ekranu
2. Ako je prazan — ekran je zaključan ili app crashovao
3. `press_home()` pa pokušaj ponovo
4. Screenshot za debug: `phone.screenshot()`

### App se promenio posle update-a
1. Ažuriraj skill sa novim UI elementima
2. Zapiši promenu u `memory/errors.md`
3. Isključi auto-update: Settings → Play Store → Auto-update → Don't auto-update

## Restore obrisanih paketa
```bash
# Ako si obrisao nešto što ti treba nazad:
adb -s 192.168.1.146:5555 shell cmd package install-existing com.package.name
```
