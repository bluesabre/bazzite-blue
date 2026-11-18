#!/usr/bin/env bash

# System-wide KDE Plasma defaults. Everything under /etc/xdg is a fallback
# layer: any key a user has set in ~/.config still wins. Bazzite already ships
# some of these files, so they are edited in place with kwriteconfig6 rather
# than replaced.

set ${SET_X:+-x} -eou pipefail

echo "Configuring KDE Plasma defaults"

WALLPAPER="file:///usr/share/wallpapers/Next/"
ACCENT_RGB="146,110,228"
ACCENT_HEX="#926ee4"

# kset FILE GROUP... KEY VALUE  (nested groups are passed as separate args)
kset() {
    local file="$1"
    shift
    local args=()
    while (($# > 2)); do
        args+=(--group "$1")
        shift
    done
    kwriteconfig6 --file "/etc/xdg/${file}" "${args[@]}" --key "$1" "$2"
}

## Global theme: automatic light/dark switching, Breeze Twilight / Breeze Dark
kset kdeglobals KDE LookAndFeelPackage org.kde.breezedark.desktop
kset kdeglobals KDE AutomaticLookAndFeel true
kset kdeglobals KDE DefaultDarkLookAndFeel org.kde.breezedark.desktop
kset kdeglobals KDE DefaultLightLookAndFeel org.kde.breezetwilight.desktop
kset kdeglobals General AccentColor "${ACCENT_RGB}"

# Applications read colors from the [Colors:*] groups that are written when a
# color scheme is applied, so the accent above only fully takes effect once a
# scheme is applied with it. Do that once per user, unless they chose their own.
mkdir -p /usr/libexec/bazzite-blue
cat >/usr/libexec/bazzite-blue/apply-default-accent <<EOF
#!/usr/bin/env bash
# Apply the Bazzite Blue default accent color once per user.
set -euo pipefail

config="\${XDG_CONFIG_HOME:-\$HOME/.config}"
marker="\${XDG_STATE_HOME:-\$HOME/.local/state}/bazzite-blue/accent-applied"

[[ -e "\$marker" ]] && exit 0
mkdir -p "\$(dirname "\$marker")"

if ! grep -q '^AccentColor=' "\$config/kdeglobals" 2>/dev/null; then
    scheme="\$(kreadconfig6 --file kdeglobals --group General --key ColorScheme --default BreezeDark)"
    plasma-apply-colorscheme --accent-color '${ACCENT_HEX}' "\$scheme"
fi

touch "\$marker"
EOF
chmod 755 /usr/libexec/bazzite-blue/apply-default-accent

cat >/etc/xdg/autostart/bazzite-blue-accent.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=Bazzite Blue default accent color
Exec=/usr/libexec/bazzite-blue/apply-default-accent
OnlyShowIn=KDE;
NoDisplay=true
X-KDE-autostart-phase=1
EOF

## Lock screen wallpaper (replaces Bazzite's convergence.jxl)
kset kscreenlockerrc Greeter Wallpaper org.kde.image General Image "${WALLPAPER}"
kset kscreenlockerrc Greeter Wallpaper org.kde.image General PreviewImage "${WALLPAPER}"

## Login manager (Plasma Login Manager) wallpaper
mkdir -p /usr/lib/plasmalogin/plasmalogin.conf.d
cat >/usr/lib/plasmalogin/plasmalogin.conf.d/50-bazzite-blue.conf <<EOF
[Greeter]
WallpaperPlugin=org.kde.image

[Greeter][Wallpaper][org.kde.image][General]
Image=${WALLPAPER}
PreviewImage=${WALLPAPER}
EOF

## Spectacle
kset spectaclerc General autoSaveImage true
kset spectaclerc General clipboardGroup PostScreenshotCopyImage
kset spectaclerc General rememberSelectionRect Always
kset spectaclerc GuiConfig quitAfterSaveCopyExport true

## Alt-tab: show windows from all virtual desktops
kset kwinrc TabBox DesktopMode 0

## Clipboard: don't keep history
kset klipperrc General KeepClipboardContents false
kset klipperrc General MaxClipItems 1

## KWin rules: give LibreOffice (Flatpak) windows the right app icon
cat >/etc/xdg/kwinrulesrc <<'EOF'
[General]
Order=c9762a32-fb44-44f5-9152-ab138d1574a8,505fdb77-554b-46f5-8947-527c33cbf097,2f8a947b-4395-49a7-b4cd-3e69e4065890,0335c6d8-da86-453f-9b2c-92a70158d7d0,596f2410-6655-4433-912f-f23c263a0122,b9daee93-59da-4a50-b208-40e437cdd344
EOF

add_lo_rule() {
    local uuid="$1" app="$2" id="$3"
    cat >>/etc/xdg/kwinrulesrc <<EOF

[${uuid}]
Description=LibreOffice ${app} (flatpak) icon
desktopfile=org.libreoffice.LibreOffice.${id}
desktopfilerule=2
title=LibreOffice ${app}
titlematch=2
wmclass=org.libreoffice.LibreOffice
wmclasscomplete=false
wmclassmatch=1
EOF
}
add_lo_rule c9762a32-fb44-44f5-9152-ab138d1574a8 Writer writer
add_lo_rule 505fdb77-554b-46f5-8947-527c33cbf097 Calc calc
add_lo_rule 2f8a947b-4395-49a7-b4cd-3e69e4065890 Impress impress
add_lo_rule 0335c6d8-da86-453f-9b2c-92a70158d7d0 Draw draw
add_lo_rule 596f2410-6655-4433-912f-f23c263a0122 Math math
add_lo_rule b9daee93-59da-4a50-b208-40e437cdd344 Base base

## Default panel layout and desktop wallpaper (new users only)
# Plasma builds the initial desktop from the active global theme's layout
# script. Breeze, Breeze Dark and Breeze Twilight ship the same stock file.
STOCK_LAYOUT_MD5="c6e022134264efdfdf25f9a340b642a3"
LAYOUT="$(mktemp)"
cat >"${LAYOUT}" <<'EOF'
// Bazzite Blue default desktop layout

var panel = new Panel;
var panelScreen = panel.screen;

// Same sizing as the stock defaultPanel template
panel.height = 2 * Math.ceil(gridUnit * 2.5 / 2);

const maximumAspectRatio = 21 / 9;
if (panel.formFactor === "horizontal") {
    const geo = screenGeometry(panelScreen);
    const maximumWidth = Math.ceil(geo.height * maximumAspectRatio);

    if (geo.width > maximumWidth) {
        panel.alignment = "center";
        panel.minimumLength = maximumWidth;
        panel.maximumLength = maximumWidth;
    }
}

panel.addWidget("org.kde.plasma.weather");
panel.addWidget("org.kde.plasma.panelspacer");

var kickoff = panel.addWidget("org.kde.plasma.kickoff");
kickoff.currentConfigGroup = ["General"];
kickoff.writeConfig("icon", "distributor-logo-steamdeck");

var tasks = panel.addWidget("org.kde.plasma.icontasks");
tasks.currentConfigGroup = ["General"];
tasks.writeConfig("launchers", [
    "preferred://browser",
    "applications:io.github.kolunmi.Bazaar.desktop",
    "preferred://filemanager",
    "applications:virt-manager.desktop",
    "applications:com.microsoft.VSCode.desktop"
]);
tasks.writeConfig("showOnlyCurrentDesktop", false);

panel.addWidget("org.kde.plasma.panelspacer");
panel.addWidget("org.kde.plasma.marginsseparator");

// Input Method Panel for languages that typically use an IME (from the stock template)
var langIds = ["as", "bn", "bo", "brx", "doi", "gu", "hi", "ja", "kn", "ko",
               "kok", "ks", "lep", "mai", "ml", "mni", "mr", "ne", "or", "pa",
               "sa", "sat", "sd", "si", "ta", "te", "th", "ur", "vi",
               "zh_CN", "zh_TW"];
if (langIds.indexOf(languageId) != -1) {
    panel.addWidget("org.kde.plasma.kimpanel");
}

// Plasma 6's system tray keeps its item lists in its own [General] group
var systray = panel.addWidget("org.kde.plasma.systemtray");
systray.currentConfigGroup = ["General"];
systray.writeConfig("hiddenItems", ["org.kde.plasma.clipboard"]);

panel.addWidget("org.kde.plasma.digitalclock");
panel.addWidget("org.kde.plasma.showdesktop");

var desktopsArray = desktopsForActivity(currentActivity());
for (var j = 0; j < desktopsArray.length; j++) {
    desktopsArray[j].wallpaperPlugin = "org.kde.image";
    desktopsArray[j].currentConfigGroup = ["Wallpaper", "org.kde.image", "General"];
    desktopsArray[j].writeConfig("Image", "file:///usr/share/wallpapers/Next/");
}
EOF

for lnf in org.kde.breeze.desktop org.kde.breezedark.desktop org.kde.breezetwilight.desktop; do
    target="/usr/share/plasma/look-and-feel/${lnf}/contents/layouts/org.kde.plasma.desktop-layout.js"
    if [[ ! -f "${target}" ]]; then
        echo "WARNING: ${target} not found; upstream layout moved?" >&2
    elif [[ "$(md5sum <"${target}" | cut -d' ' -f1)" != "${STOCK_LAYOUT_MD5}" ]]; then
        echo "WARNING: upstream ${lnf} layout changed; review before overriding" >&2
    fi
    install -Dm644 "${LAYOUT}" "${target}"
done
rm -f "${LAYOUT}"
