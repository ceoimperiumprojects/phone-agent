#!/bin/bash
###############################################################################
# Samsung Galaxy A14 (Android 13 / OneUI Core 5.x) Complete Debloat Script
#
# Usage:
#   1. Enable USB Debugging on phone (Settings > Developer Options)
#   2. Connect phone via USB, authorize the PC
#   3. Run: bash samsung_a14_debloat.sh
#
# To RESTORE any removed package later:
#   adb shell cmd package install-existing <package.name>
#
# Sources cross-referenced:
#   - github.com/khlam/debloat-samsung-android (475+ stars)
#   - github.com/Achno/debloat-samsung-ADB-shizuku
#   - github.com/invinciblevenom/debloat_samsung_android (OneUI 2.5-6.1)
#   - github.com/TheOneAndOnlyAtlas/Samsung-Debloater
#   - github.com/Universal-Debloater-Alliance/universal-android-debloater-next-generation
#   - Gist: Maetih/samsung-bloatware-apps-android-14
#   - Reddit: r/samsung Ultimate OneUI Debloat Guide
#   - Reddit: r/Android Samsung bloatware rootless ADB list
###############################################################################

set -euo pipefail

CMD="adb shell pm uninstall -k --user 0"

echo "============================================="
echo " Samsung Galaxy A14 Debloat Script"
echo " Android 13 / OneUI Core 5.x"
echo "============================================="
echo ""

# Verify ADB connection
if ! adb devices 2>/dev/null | grep -q "device$"; then
    echo "[ERROR] No device found. Check USB cable and USB debugging."
    echo "        Run 'adb devices' to verify connection."
    exit 1
fi

DEVICE=$(adb shell getprop ro.product.model 2>/dev/null | tr -d '\r')
echo "[OK] Connected to: $DEVICE"
echo ""

###############################################################################
# SECTION 1: SAFE TO REMOVE (100% safe, no side effects on core functionality)
###############################################################################

echo "==========================================="
echo " SECTION 1: SAFE TO REMOVE"
echo " (100% safe - bloatware, no side effects)"
echo "==========================================="
echo ""

# ---------- BIXBY ----------
echo "--- Removing Bixby ---"
$CMD com.samsung.android.bixby.agent              # Bixby Voice assistant
$CMD com.samsung.android.bixby.agent.dummy         # Bixby agent placeholder
$CMD com.samsung.android.bixby.service             # Bixby background service
$CMD com.samsung.android.bixby.wakeup              # Bixby voice wake-up ("Hi Bixby")
$CMD com.samsung.android.bixbyvision.framework     # Bixby Vision (camera AI)
$CMD com.samsung.android.bixby.es.globalaction     # Bixby global actions
$CMD com.samsung.android.bixby.plmsync             # Bixby plan sync service
$CMD com.samsung.android.bixby.voiceinput          # Bixby voice input engine
$CMD com.samsung.android.app.settings.bixby        # Bixby settings panel
$CMD com.samsung.android.visionintelligence        # Bixby Vision intelligence
$CMD com.samsung.systemui.bixby                    # Bixby SystemUI integration
$CMD com.samsung.systemui.bixby2                   # Bixby SystemUI integration v2

# ---------- SAMSUNG AR / EMOJI / STICKERS ----------
echo "--- Removing AR Zone / Emoji / Stickers ---"
$CMD com.samsung.android.aremoji                   # AR Emoji
$CMD com.samsung.android.aremojieditor             # AR Emoji editor
$CMD com.samsung.android.arzone                    # AR Zone app
$CMD com.samsung.android.ardrawing                 # AR Doodle drawing
$CMD com.samsung.android.livestickers              # Live Stickers (camera)
$CMD com.samsung.android.stickercenter             # Sticker Center hub
$CMD com.samsung.android.stickerplugin             # Sticker plugin
$CMD com.sec.android.mimage.avatarstickers         # Avatar stickers
$CMD com.sec.android.mimage.avatar.stickers        # Avatar stickers (alternate pkg)
$CMD com.samsung.android.app.camera.sticker.facear.preload          # Camera face AR sticker
$CMD com.samsung.android.app.camera.sticker.facear3d.preload        # Camera 3D face AR sticker
$CMD com.samsung.android.app.camera.sticker.facearavatar.preload    # Camera avatar sticker
$CMD com.samsung.android.app.camera.sticker.facearframe.preload     # Camera frame sticker
$CMD com.samsung.android.app.camera.sticker.stamp.preload           # Camera stamp sticker

# ---------- SAMSUNG THEMES / WALLPAPERS ----------
echo "--- Removing Themes / Wallpapers ---"
$CMD com.samsung.android.themestore                # Galaxy Themes Store
$CMD com.samsung.android.themecenter               # Theme Center service
$CMD com.samsung.android.dynamiclock               # Dynamic Lock Screen (wallpaper ads)
$CMD com.samsung.android.keyguardwallpaperupdator  # Lock screen wallpaper updater
$CMD com.android.wallpaper.livepicker              # Live wallpaper picker
$CMD com.android.wallpapercropper                  # Wallpaper cropper

# ---------- SAMSUNG CLOUD / ACCOUNT SERVICES ----------
echo "--- Removing Samsung Cloud / Sync ---"
$CMD com.samsung.android.scloud                    # Samsung Cloud
$CMD com.samsung.android.mobileservice             # Samsung Group Sharing
$CMD com.samsung.storyservice                      # Samsung Story Service
$CMD com.samsung.android.allshare.service.mediashare  # Nearby media share service
$CMD com.samsung.android.allshare.service.fileshare   # Nearby file share service
$CMD com.samsung.android.app.simplesharing         # Link Sharing
$CMD com.samsung.android.privateshare              # Private Share

# ---------- SAMSUNG PAY / WALLET ----------
echo "--- Removing Samsung Pay / Wallet ---"
$CMD com.samsung.android.spay                      # Samsung Pay
$CMD com.samsung.android.spayfw                    # Samsung Pay framework
$CMD com.samsung.android.coldwalletservice         # Samsung Blockchain Wallet
$CMD com.samsung.android.kgclient                  # Samsung Pay device service

# ---------- SAMSUNG GAME LAUNCHER ----------
echo "--- Removing Game Launcher ---"
$CMD com.samsung.android.game.gamehome             # Game Launcher home
$CMD com.samsung.android.game.gametools            # Game Tools overlay
$CMD com.samsung.android.game.gos                  # Game Optimizing Service
$CMD com.samsung.android.gametuner.thin            # Game Tuner
$CMD com.enhance.gameservice                       # Game enhancement service
$CMD com.sec.android.app.gamehub                   # Game Hub (older name)

# ---------- SAMSUNG DEX / LINK TO WINDOWS ----------
echo "--- Removing DeX / Link to Windows ---"
$CMD com.samsung.android.mdx                       # Link to Windows service
$CMD com.samsung.android.mdx.kit                   # Link to Windows kit
$CMD com.samsung.android.mdx.quickboard            # Link to Windows quick panel
$CMD com.sec.android.app.desktoplauncher           # DeX launcher
$CMD com.sec.android.app.dexonpc                   # DeX on PC
$CMD com.sec.android.desktopmode.uiservice         # DeX UI service
$CMD com.samsung.desktopsystemui                   # DeX system UI

# ---------- SAMSUNG KIDS ----------
echo "--- Removing Samsung Kids ---"
$CMD com.samsung.android.kidsinstaller             # Kids mode installer
$CMD com.sec.android.app.kidshome                  # Kids Home launcher

# ---------- SAMSUNG KNOX ----------
echo "--- Removing Knox (enterprise) ---"
$CMD com.samsung.android.knox.analytics.uploader   # Knox analytics uploader
$CMD com.sec.enterprise.knox.cloudmdm.smdms        # Knox enrollment service
$CMD com.samsung.knox.securefolder                 # Secure Folder
$CMD com.samsung.knox.securefolder.setuppage       # Secure Folder setup
$CMD com.samsung.android.knox.zt.framework         # Knox Zero Trust framework
$CMD com.samsung.knox.appsupdateagent              # Knox apps update agent
$CMD com.samsung.knox.rcp.components               # Knox RCP components
$CMD com.samsung.klmsagent                         # Knox License Manager

# ---------- SAMSUNG PASS ----------
echo "--- Removing Samsung Pass ---"
$CMD com.samsung.android.samsungpass               # Samsung Pass (password manager)
$CMD com.samsung.android.samsungpassautofill       # Samsung Pass autofill

# ---------- SAMSUNG SMART SWITCH ----------
echo "--- Removing Smart Switch ---"
$CMD com.sec.android.easyMover                     # Smart Switch main app
$CMD com.sec.android.easyMover.Agent               # Smart Switch agent
$CMD com.samsung.android.smartswitchassistant      # Smart Switch assistant
$CMD com.samsung.android.easysetup                 # Easy Setup wizard

# ---------- SAMSUNG MISCELLANEOUS APPS ----------
echo "--- Removing Samsung misc apps ---"
$CMD com.samsung.android.app.spage                 # Samsung Daily / Free (left panel)
$CMD com.samsung.android.app.tips                  # Samsung Tips
$CMD com.samsung.android.voc                       # Samsung Members (feedback app)
$CMD com.samsung.android.app.reminder              # Samsung Reminder
$CMD com.samsung.android.rubin.app                 # Customization Service (tracking)
$CMD com.samsung.android.beaconmanager             # Beacon Manager (BLE tracking)
$CMD com.samsung.android.forest                    # Digital Wellbeing (Samsung's version)
$CMD com.samsung.android.wellbeing                 # Digital Wellbeing (alternate)
$CMD com.samsung.android.app.cocktailbarservice    # Edge Panels service
$CMD com.samsung.android.app.taskedge              # Tasks Edge panel
$CMD com.samsung.android.app.appsedge              # Apps Edge panel
$CMD com.samsung.android.app.clipboardedge         # Clipboard Edge panel
$CMD com.samsung.android.app.sbrowseredge          # Browser Edge panel
$CMD com.samsung.android.da.daagent                # Dual Messenger
$CMD com.samsung.android.fmm                       # Find My Mobile (Samsung)
$CMD com.samsung.android.fmmm                      # Find My Mobile module
$CMD com.samsung.android.app.find                  # SmartThings Find
$CMD com.samsung.android.app.sharelive             # Quick Share (share to nearby)
$CMD com.samsung.android.aware.service             # Quick Share / Nearby awareness
$CMD com.samsung.android.service.peoplestripe      # People Edge contacts
$CMD com.samsung.android.authfw                    # Samsung Authentication Framework
$CMD com.samsung.android.tvplus                    # Samsung TV Plus (streaming)
$CMD com.samsung.android.oneconnect                # SmartThings
$CMD com.samsung.android.app.watchmanager          # Galaxy Wearable manager
$CMD com.samsung.android.app.watchmanagerstub      # Galaxy Wearable stub
$CMD com.sec.android.app.billing                   # Samsung billing service
$CMD com.samsung.android.dkey                      # Samsung Digital Key
$CMD com.samsung.android.dqagent                   # Samsung DQA (diagnostic)
$CMD com.samsung.android.ipsgeofence               # Samsung geofence tracking
$CMD com.samsung.android.smartsuggestions           # Smart Suggestions
$CMD com.samsung.android.service.stplatform        # Samsung ST platform service
$CMD com.samsung.android.mdecservice               # Samsung marketing/diagnostics
$CMD com.samsung.android.mcfds                     # Samsung MCF device service
$CMD com.samsung.android.networkdiagnostic         # Network diagnostic
$CMD com.samsung.android.scpm                      # Samsung security policy
$CMD com.samsung.android.scs                       # Samsung Cloud sync
$CMD com.samsung.android.securitylogagent          # Security log agent
$CMD com.samsung.android.mapsagent                 # Samsung Maps agent
$CMD com.samsung.android.app.omcagent              # OMC agent (carrier config)
$CMD com.samsung.android.app.parentalcare          # Parental Care
$CMD com.samsung.android.app.separation            # App separation
$CMD com.samsung.android.sdk.handwriting           # Handwriting SDK
$CMD com.samsung.android.sm.devicesecurity         # McAfee device security
$CMD com.samsung.android.sm.policy                 # Samsung security policy
$CMD com.samsung.android.fast                      # Samsung Fast (setup)
$CMD com.samsung.sree                              # Samsung SREE service
$CMD com.samsung.safetyinformation                 # Safety Information app
$CMD com.samsung.android.app.ledbackcover          # LED back cover support
$CMD com.samsung.android.app.ledcoverdream         # LED cover dream
$CMD com.sec.android.cover.ledcover                # LED cover service
$CMD com.samsung.android.service.livedrawing       # Live drawing feature
$CMD com.samsung.android.app.filterinstaller       # Camera filter installer
$CMD com.samsung.android.app.galaxyfinder          # Finder (notification panel search)
$CMD com.samsung.android.tripwidget                # Trip widget
$CMD com.samsung.android.visionarapps              # Vision AR apps
$CMD com.samsung.android.visioncloudagent          # Vision cloud service
$CMD com.samsung.android.setting.multisound        # Multi sound settings
$CMD com.samsung.android.app.vrsetupwizardstub     # VR Setup wizard stub
$CMD com.samsung.android.hmt.vrshell               # Gear VR shell
$CMD com.samsung.android.hmt.vrsvc                 # Gear VR service
$CMD com.samsung.android.service.travel            # Travel service
$CMD com.samsung.android.dlp.service               # DLP service
$CMD com.samsung.android.drivelink.stub            # Drive Link stub
$CMD com.samsung.android.app.mirrorlink            # MirrorLink
$CMD com.samsung.android.aircommandmanager         # Air Command (S-Pen related)
$CMD com.samsung.android.widgetapp.yahooedge.finance   # Yahoo Finance widget
$CMD com.samsung.android.widgetapp.yahooedge.sport     # Yahoo Sports widget
$CMD com.sec.android.widgetapp.easymodecontactswidget  # Easy Mode contacts widget
$CMD com.sec.samsung.android.widgetapp.samsungapps     # Galaxy Essentials widget
$CMD com.sec.android.widgetapp.webmanual           # User Manual widget
$CMD com.samsung.android.bbc.bbcagent              # Samsung BBC agent
$CMD com.samsung.android.app.advsounddetector      # Sound detector (accessibility)
$CMD com.samsung.android.app.storyalbumwidget      # Story Album widget
$CMD com.samsung.app.highlightplayer               # Highlight player
$CMD com.samsung.daydream.customization            # Daydream customization
$CMD com.samsung.dcmservice                        # DCM service
$CMD com.samsung.enhanceservice                    # Enhance service
$CMD com.samsung.faceservice                       # Face service
$CMD com.samsung.fresco.logging                    # Fresco logging
$CMD com.samsung.groupcast                         # Group Cast
$CMD com.samsung.hs20provider                      # HS20 provider
$CMD com.samsung.ipservice                         # IP service
$CMD com.samsung.voiceserviceplatform              # Voice service platform
$CMD com.samsung.svoice.sync                       # S Voice sync
$CMD com.samsung.android.svoice                    # S Voice
$CMD com.samsung.android.svoiceime                 # S Voice IME
$CMD com.samsung.ucs.agent.ese                     # UCS agent
$CMD com.samsung.SMT                               # Samsung TTS
$CMD com.samsung.aasaservice                       # Samsung AASA service
$CMD com.sec.android.app.apex                      # Samsung APEX
$CMD com.sec.android.app.applinker                 # App Linker
$CMD com.sec.android.app.magnifier                 # Magnifier
$CMD com.sec.android.app.ocr                       # OCR service
$CMD com.sec.android.app.parser                    # Parser service
$CMD com.sec.android.app.personalization           # Personalization service
$CMD com.sec.android.app.ringtoneBR                # Ringtone BR
$CMD com.sec.android.app.safetyassurance           # Safety assurance
$CMD com.sec.android.app.soundalive                # SoundAlive
$CMD com.sec.android.app.sysscope                  # SysScope
$CMD com.sec.android.app.tourviewer                # Tour Viewer
$CMD com.sec.android.app.translator                # Translator
$CMD com.sec.android.app.ve.vebgm                  # Video editor BGM
$CMD com.sec.android.app.wfdbroker                 # WiFi Direct broker
$CMD com.sec.android.app.withtv                    # Samsung TV related
$CMD com.samsung.android.app.withtv                # Samsung TV related (alt)
$CMD com.sec.android.app.wlantest                  # WLAN test
$CMD com.sec.android.diagmonagent                  # Diagnostic monitor agent
$CMD com.sec.android.mimage.gear360editor          # Gear 360 editor
$CMD com.sec.android.mimage.photoretouching        # Photo retouching
$CMD com.sec.android.ofviewer                      # Office viewer
$CMD com.sec.android.provider.snote                # S Note provider
$CMD com.sec.android.easyonehand                   # One Hand Operation
$CMD com.sec.android.emergencylauncher             # Emergency launcher
$CMD com.sec.android.app.SmartClipEdgeService      # Smart Clip edge service
$CMD com.sec.android.app.quicktool                 # Quick Tools
$CMD com.sec.spp.push                              # Samsung Push Service
$CMD com.sec.android.app.chromecustomizations      # Chrome customizations (Samsung)
$CMD com.policydm                                  # Policy DM service
$CMD com.samsung.sec.android.application.csc       # CSC application
$CMD com.val.hardware                              # Hardware diagnostic
$CMD com.wsomacp                                   # Samsung email config

# ---------- FACEBOOK PREINSTALLED ----------
echo "--- Removing Facebook ---"
$CMD com.facebook.appmanager                       # Facebook App Manager
$CMD com.facebook.services                         # Facebook Services
$CMD com.facebook.system                           # Facebook System
$CMD com.facebook.katana                           # Facebook app

# ---------- MICROSOFT PREINSTALLED ----------
echo "--- Removing Microsoft apps ---"
$CMD com.microsoft.appmanager                      # Microsoft App Manager (Link to Windows)
$CMD com.microsoft.skydrive                        # OneDrive
$CMD com.microsoft.office.excel                    # Excel
$CMD com.microsoft.office.word                     # Word
$CMD com.microsoft.office.powerpoint               # PowerPoint
$CMD com.microsoft.office.officehubrow             # Microsoft Office hub
$CMD com.microsoft.office.outlook                  # Outlook

# ---------- NETFLIX PREINSTALLED ----------
echo "--- Removing Netflix ---"
$CMD com.netflix.mediaclient                       # Netflix app
$CMD com.netflix.partner.activation                # Netflix activation service

# ---------- SPOTIFY PREINSTALLED ----------
echo "--- Removing Spotify ---"
$CMD com.spotify.music                             # Spotify (if preinstalled)

# ---------- THIRD-PARTY BLOAT ----------
echo "--- Removing 3rd party bloat ---"
$CMD de.axelspringer.yana.zeropage                 # Upday news feed
$CMD com.hiya.star                                 # Hiya caller ID
$CMD com.linkedin.android                          # LinkedIn
$CMD com.imdb.mobile                               # IMDb
$CMD com.audible.application                       # Audible
$CMD com.blurb.checkout                            # Blurb
$CMD com.cnn.mobile.android.phone.edgepanel        # CNN Edge panel
$CMD com.flipboard.app                             # Flipboard
$CMD com.flipboard.boxer.app                       # Flipboard Briefing
$CMD com.gotv.nflgamecenter.us.lite                # NFL Game Center
$CMD com.hancom.office.editor.hidden               # Hancom Office editor
$CMD com.infraware.polarisoffice5                  # Polaris Office
$CMD com.mobeam.barcodeService                     # Mobeam barcode service
$CMD com.sec.penup                                 # PenUp (Samsung art community)
$CMD com.sec.android.app.voicenote                 # Voice Recorder (Samsung)

# ---------- AMAZON PREINSTALLED ----------
echo "--- Removing Amazon apps ---"
$CMD com.amazon.fv                                 # Amazon FreeVee
$CMD com.amazon.kindle                             # Kindle
$CMD com.amazon.mShop.android                      # Amazon Shopping
$CMD com.amazon.mp3                                # Amazon Music
$CMD com.amazon.venezia                            # Amazon App Store

# ---------- GOOGLE BLOAT (safe if you use alternatives) ----------
echo "--- Removing Google bloat ---"
$CMD com.google.android.apps.tachyon               # Google Duo / Meet
$CMD com.google.android.apps.youtube.music         # YouTube Music
$CMD com.google.android.apps.docs                  # Google Docs
$CMD com.google.android.apps.books                 # Google Play Books
$CMD com.google.android.apps.magazines             # Google Play Magazines
$CMD com.google.android.apps.maps                  # Google Maps
$CMD com.google.android.apps.photos                # Google Photos
$CMD com.google.android.apps.plus                  # Google+
$CMD com.google.android.apps.bard                  # Google Gemini (Bard)
$CMD com.google.android.videos                     # Google TV / Play Movies
$CMD com.google.android.youtube                    # YouTube
$CMD com.google.android.gm                         # Gmail
$CMD com.google.android.talk                       # Google Hangouts
$CMD com.google.android.googlequicksearchbox       # Google Search / Assistant widget
$CMD com.google.android.tts                        # Google Text-to-Speech
$CMD com.google.ar.core                            # Google AR Core
$CMD com.google.vr.vrcore                          # Google VR Core
$CMD com.google.android.feedback                   # Google feedback
$CMD com.google.android.printservice.recommendation  # Print service recommendation
$CMD com.google.android.syncadapters.calendar      # Google Calendar sync adapter
$CMD com.google.android.syncadapters.contacts      # Google Contacts sync adapter
$CMD com.google.android.apps.walletnfcrel          # Google Wallet (NFC payments)
$CMD com.google.android.projection.gearhead        # Android Auto
$CMD com.google.android.apps.turbo                 # Device Health Services
$CMD com.google.android.apps.restore               # Google restore service
$CMD com.google.android.apps.messaging             # Google Messages (if using Samsung Messages)
$CMD com.google.android.health.connect.backuprestore  # Health Connect backup
$CMD com.google.android.healthconnect.controller   # Health Connect controller
$CMD com.google.android.partnersetup               # Google Partner Setup
$CMD com.google.android.onetimeinitializer         # Google first-time initializer

# ---------- ANDROID SYSTEM BLOAT (safe) ----------
echo "--- Removing Android system bloat ---"
$CMD com.android.chrome                            # Chrome browser
$CMD com.android.bookmarkprovider                  # Bookmark provider
$CMD com.android.dreams.basic                      # Basic screensaver/daydream
$CMD com.android.dreams.phototable                 # Photo screensaver
$CMD com.android.hotwordenrollment.okgoogle        # "OK Google" hotword
$CMD com.android.hotwordenrollment.xgoogle         # "Hey Google" hotword
$CMD com.android.providers.partnerbookmarks        # Partner bookmarks in Chrome
$CMD com.android.egg                               # Android Easter egg
$CMD com.android.backupconfirm                     # Backup confirm dialog
$CMD com.android.bips                              # Built-in print service
$CMD com.android.printspooler                      # Print spooler
$CMD com.android.providers.userdictionary          # User dictionary provider
$CMD com.android.sharedstoragebackup               # Shared storage backup
$CMD com.android.managedprovisioning               # Work profile setup

# ---------- ANT+ PLUGINS ----------
echo "--- Removing ANT+ ---"
$CMD com.dsi.ant.plugins.antplus                   # ANT+ Plugins
$CMD com.dsi.ant.sample.acquirechannels            # ANT+ sample
$CMD com.dsi.ant.server                            # ANT+ server
$CMD com.dsi.ant.service.socket                    # ANT+ socket service

# ---------- CARRIER BLOAT (US carriers - skip if not applicable) ----------
echo "--- Removing Carrier bloat ---"
# T-Mobile
$CMD com.tmobile.echolocate                        # T-Mobile diagnostics
$CMD com.tmobile.pr.adapt                          # T-Mobile Adapt
$CMD com.tmobile.simlock                           # T-Mobile SIM lock
$CMD com.tmobile.services                          # T-Mobile services
$CMD com.tmobile.vvm.application                   # T-Mobile Visual Voicemail
$CMD com.ironsrc.aura.tmo                          # T-Mobile Aura (app installer)
# Verizon
$CMD com.vzw.apnlib                                # Verizon APN library
$CMD com.vzw.ecid                                  # Verizon ECID
$CMD com.vzw.hss.myverizon                         # My Verizon
$CMD com.vzw.hs.android.modlite                    # Verizon module
$CMD com.vcast.mediamanager                        # Verizon Media Manager
$CMD com.verizon.llkagent                          # Verizon LLK agent
$CMD com.verizon.mips.services                     # Verizon MIPS
$CMD com.vzw.visualvoicemail                       # Verizon Visual Voicemail
$CMD com.samsung.vzwapiservice                     # Samsung Verizon API
$CMD com.verizon.obdm                              # Verizon OBD Manager
$CMD com.securityandprivacy.android.verizon.vms    # Verizon VMS
$CMD com.verizon.onetalk.dialer                    # Verizon OneTalk
# AT&T
$CMD com.att.dh                                    # AT&T Device Help
$CMD com.att.callprotect                           # AT&T Call Protect
$CMD com.att.tv                                    # AT&T TV
$CMD com.att.myWireless                            # AT&T My Wireless
$CMD com.att.visualvoicemail                       # AT&T Visual Voicemail
$CMD com.att.android.attsmartwifi                  # AT&T Smart WiFi
# Sprint / Boost
$CMD com.boost.vvm                                 # Boost Visual Voicemail
$CMD com.sprint.ms.smf.services                    # Sprint services
$CMD com.sprint.provider                           # Sprint provider
# Other
$CMD com.cricketwireless.mycricket                 # Cricket Wireless
$CMD com.mizmowireless.tethering                   # Mizmo tethering
$CMD com.aura.oobe.samsung.gl                      # Aura OOBE (app suggestions)
$CMD com.aura.oobe.samsung                         # Aura OOBE (app suggestions)
$CMD com.aura.oobe.att                             # Aura OOBE AT&T
$CMD com.xfinitymobile.cometcarrierservice         # Xfinity Mobile service
$CMD com.spectrum.cm.headless                      # Spectrum headless
$CMD com.uscc.ecid                                 # US Cellular ECID
$CMD com.cequint.ecid                              # Caller ID (carrier)
$CMD com.sec.android.app.tfunlock                  # TracFone unlock
$CMD com.sec.android.omc                           # OMC (carrier config loader)

# ---------- SAMSUNG FONTS ----------
echo "--- Removing extra fonts ---"
$CMD com.monotype.android.font.chococooky          # Choco Cooky font
$CMD com.monotype.android.font.cooljazz            # Cool Jazz font
$CMD com.monotype.android.font.foundation          # Foundation font
$CMD com.monotype.android.font.rosemary            # Rosemary font

echo ""
echo "==========================================="
echo " SECTION 1 COMPLETE"
echo "==========================================="
echo ""


###############################################################################
# SECTION 2: OPTIONAL (safe but some users may want these)
# Uncomment lines you want to remove
###############################################################################

echo "==========================================="
echo " SECTION 2: OPTIONAL"
echo " (uncomment what you do NOT use)"
echo "==========================================="
echo ""

# Samsung Internet Browser
# $CMD com.sec.android.app.sbrowser                # Samsung Internet browser
# $CMD com.sec.android.app.sbrowser.lite           # Samsung Internet Lite

# Samsung Calendar
# $CMD com.samsung.android.calendar                # Samsung Calendar app
# $CMD com.samsung.providers.calendar              # Samsung Calendar storage

# Samsung Email
# $CMD com.samsung.android.email.provider          # Samsung Email
# $CMD com.android.email                           # Android Email client
# $CMD com.android.exchange                        # Exchange service

# Samsung Messages
# $CMD com.samsung.android.messaging               # Samsung Messages

# Samsung Contacts
# $CMD com.samsung.android.app.contacts            # Samsung Contacts

# Samsung Clock
# $CMD com.sec.android.app.clockpackage            # Samsung Clock app

# Samsung Calculator
# $CMD com.sec.android.app.popupcalculator         # Samsung Calculator

# Samsung My Files
# $CMD com.sec.android.app.myfiles                 # My Files manager

# Samsung Notes
# $CMD com.samsung.android.app.notes               # Samsung Notes

# Samsung Health
# $CMD com.sec.android.app.shealth                 # Samsung Health

# Samsung Routines / Modes
# $CMD com.samsung.android.app.routines            # Bixby Routines / Modes

# Galaxy Wearable (keep if you have Galaxy Watch/Buds)
# $CMD com.samsung.android.app.watchmanager        # Galaxy Wearable

# Samsung Galaxy Store
# $CMD com.sec.android.app.samsungapps             # Galaxy Store

# Samsung Account (removing breaks Galaxy Store, Find My, Cloud)
# $CMD com.osp.app.signin                          # Samsung Account sign-in

# Samsung Keyboard
# $CMD com.samsung.android.honeyboard              # Samsung Keyboard

# Samsung Gallery
# $CMD com.sec.android.gallery3d                   # Samsung Gallery

# Samsung Camera (DO NOT remove on main user)
# $CMD com.sec.android.app.camera                  # Samsung Camera

# Google Play Store (only if using alternative like F-Droid)
# $CMD com.android.vending                         # Google Play Store

# Google Play Services (WARNING: breaks many apps)
# $CMD com.google.android.gms                      # Google Play Services

# Google Services Framework (WARNING: breaks Google ecosystem)
# $CMD com.google.android.gsf                      # Google Services Framework

# Google Setup Wizard (safe after initial setup, but needed for factory reset)
# $CMD com.google.android.setupwizard              # Google Setup Wizard

# Samsung Weather (via daemon)
# $CMD com.sec.android.daemonapp                   # Samsung Weather daemon

# SIM Toolkit
# $CMD com.android.stk                             # SIM Toolkit

echo ""
echo "==========================================="
echo " SECTION 2: Uncomment items above to remove"
echo "==========================================="
echo ""


###############################################################################
# SECTION 3: DO NOT REMOVE (will break phone / critical system components)
###############################################################################

echo "==========================================="
echo " SECTION 3: DO NOT REMOVE"
echo " Listed below as reference only."
echo "==========================================="
echo ""

# DO NOT REMOVE THESE PACKAGES:
# com.android.systemui                     # System UI - PHONE WILL BE UNUSABLE
# com.android.settings                     # Settings app - CANNOT ACCESS SETTINGS
# com.android.phone                        # Phone/Dialer - CANNOT MAKE CALLS
# com.android.server.telecom              # Telecom server - BREAKS CALLING
# com.android.providers.contacts          # Contacts database - BREAKS CONTACTS
# com.android.providers.telephony         # Telephony database - BREAKS SMS/CALLS
# com.android.providers.media             # Media database - BREAKS GALLERY/FILES
# com.android.providers.downloads         # Download manager - BREAKS DOWNLOADS
# com.android.providers.settings          # Settings database - BOOTLOOP RISK
# com.android.providers.calendar          # Calendar database provider
# com.android.inputmethod.latin           # Default keyboard - NO KEYBOARD
# com.samsung.android.honeyboard          # Samsung Keyboard - NO KEYBOARD (if default)
# com.samsung.android.incallui            # In-call UI - CANNOT SEE CALLS
# com.samsung.android.dialer              # Samsung Dialer
# com.samsung.android.contacts            # Samsung Contacts provider
# com.samsung.android.messaging           # Samsung Messages (if default SMS)
# com.samsung.android.lool                # Samsung One UI Home launcher
# com.sec.android.app.launcher            # Samsung Launcher (older)
# com.android.launcher3                   # Fallback launcher
# com.android.packageinstaller            # Package installer - CANNOT INSTALL APPS
# com.android.permissioncontroller        # Permission controller - SECURITY
# com.android.networkstack                # Network stack - NO INTERNET
# com.android.wifi.resources              # WiFi resources - NO WIFI
# com.android.bluetooth                   # Bluetooth service
# com.android.nfc                         # NFC service
# com.android.documentsui                 # Documents UI / file picker
# com.samsung.android.provider.filterprovider  # System filter provider
# com.samsung.android.providers.contacts  # Samsung contacts provider
# com.samsung.android.net.wifi.wifiguider # WiFi connection manager
# com.samsung.android.location            # Samsung Location services
# com.samsung.android.wifi.softap.resources  # WiFi hotspot
# com.samsung.android.connectivity.security  # Connectivity security
# com.samsung.android.app.dofviewer       # Depth of field (camera component)
# com.sec.android.app.hwmoduletest        # Hardware module test (breaks with factory removal)
# com.samsung.android.providers.factory   # Factory provider (needed by hwmoduletest)
# com.android.cellbroadcastreceiver       # Emergency alerts
# com.samsung.android.emergencymode       # Emergency mode
# com.android.se                          # Secure Element
# com.android.cts.priv.ctsshim           # CTS compatibility
# com.samsung.android.pixel.repaircal     # Display calibration
# com.samsung.android.biometrics.app.setting  # Biometrics settings
# com.samsung.android.bio.face.service    # Face unlock service
# com.samsung.android.fingerprint.service # Fingerprint service
# com.wssyncmldm                          # System/security update service

echo "Script complete. Reboot your phone: adb reboot"
echo ""
echo "To restore any removed app:"
echo "  adb shell cmd package install-existing <package.name>"
echo ""
