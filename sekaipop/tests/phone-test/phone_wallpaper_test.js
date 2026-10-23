// The phone wallpaper (issue #41): one setting for what the Quick and Apps screens show behind
// them. The rules in PanelImages.qml run against fakes (Quickshell can't run here), the
// wiring is checked as text, and pick-image.sh's `load` runs for real on a scratch folder.
// Run: node tests/phone-test/phone_wallpaper_test.js
const fs = require("fs"), os = require("os"), path = require("path"), assert = require("assert")
const { execFileSync } = require("child_process")
const locate = require("../lib/locate")
const read = f => require("../lib/themetext")(fs.readFileSync(locate(f), "utf8"))

const images = read("modules/common/PanelImages.qml")
const settings = read("services/SettingsService.qml")
const general = read("modules/sekai/settings/SettingsPageGeneral.qml")
const qpFace = read("modules/sekai/quickPanel/QuickPanelFace.qml")
const quick = read("modules/sekai/quickPanel/QuickPanel.qml")

// ---------- the rules ----------
const modeSrc = images.match(/readonly property string phoneMode: (\{[\s\S]*?\n    \})/)[1]
const forSrc = images.match(/function phoneWallpaperFor\(screenName\) (\{[\s\S]*?\n    \})/)[1]
function rules(values, phonePath) {
    const SettingsService = {
        get: k => k in values ? values[k] : ({ "phone.wallpaper": "", "launcher.lcdWallpaper": true })[k],
        flag: k => !!SettingsService.get(k)
    }
    const WallpaperService = { pathFor: s => "/walls/" + s + ".mp4", imageFor: p => p.replace(".mp4", ".jpg") }
    const root = {}
    root.phoneMode = new Function("SettingsService", modeSrc)(SettingsService)
    root.phonePath = phonePath
    const wallFor = new Function("root", "WallpaperService", "return function(screenName) " + forSrc)(root, WallpaperService)
    return { mode: root.phoneMode, wall: wallFor("DP-3") }
}
assert.deepStrictEqual(rules({}, ""), { mode: "desktop", wall: "/walls/DP-3.jpg" },
                       "unchosen, old switch on (the default): the monitor's wallpaper")
assert.deepStrictEqual(rules({ "launcher.lcdWallpaper": false }, ""), { mode: "off", wall: "" },
                       "unchosen, old switch turned off: a plain phone, as before")
assert.deepStrictEqual(rules({ "phone.wallpaper": "picture" }, "/data/phone-1.png"), { mode: "picture", wall: "/data/phone-1.png" },
                       "a picture: that picture, on every monitor")
assert.deepStrictEqual(rules({ "phone.wallpaper": "picture" }, ""), { mode: "picture", wall: "" },
                       "a picture that is gone: nothing (not someone else's picture)")
assert.deepStrictEqual(rules({ "phone.wallpaper": "off", "launcher.lcdWallpaper": true }, "/x.png"), { mode: "off", wall: "" },
                       "chosen off beats the old switch")
assert.deepStrictEqual(rules({ "phone.wallpaper": "bogus", "launcher.lcdWallpaper": false }, ""), { mode: "off", wall: "" },
                       "an unknown value falls back to the old switch")

// ---------- the setting ----------
assert.ok(/"phone\.wallpaper":\s*""/.test(settings), "starts unchosen")
assert.ok(/current: PanelImages\.phoneMode/.test(general), "Settings shows the mode in force, the old switch's included")
assert.ok(/id === "picture" && PanelImages\.phonePath === ""\)\s*PanelImages\.pick\("phone"\)/.test(general),
          "A picture with none picked opens the chooser first")
assert.ok(/picker\.kind === "phone"\)\s*SettingsService\.set\("phone\.wallpaper", "picture"\)/.test(images),
          "only a picked picture turns it on (cancelling changes nothing)")
assert.ok(/visible: PanelImages\.phoneMode === "picture"[\s\S]{0,400}PanelImages\.pick\("phone"\)/.test(general),
          "the picture can be changed while it is the one shown")

// ---------- the Quick screen ----------
assert.ok(/wallpaperPath: PanelImages\.phoneWallpaperFor\(root\.targetScreen/.test(quick),
          "the Quick Panel feeds the Quick screen the same picture, for its monitor")
assert.ok(!/^[^/\n]*PanelImages\.|import qs\.services/m.test(qpFace), "the face is handed the path; it doesn't look it up")
assert.ok(/LauncherLcd \{[\s\S]{0,60}z: -10[\s\S]{0,400}path: face\.wallpaperPath[\s\S]{0,200}active: face\.visible/.test(qpFace),
          "the same LCD under everything, only decoded while the screen shows")
const fills = qpFace.match(/color: face\.wallOn \? Qt\.alpha\(/g) || []
assert.strictEqual(fills.length, 2, "both cards (buttons, notifications) let the wallpaper through")
assert.ok(/visible: !face\.wallOn/.test(qpFace), "the notification card's shadow is not drawn under a see-through card")
assert.ok(/text: face\.userName \+ "@" \+ face\.hostName\s*color: face\.wallOn \? "#ffffff"[^\n]*\s*style: face\.wallOn \? Text\.Outline/.test(qpFace),
          "the name under the avatar is white with a dark edge over the wallpaper")

// ---------- the picture is kept like the avatar and banner ----------
const pick = locate("scripts/images/pick-image.sh")
const shrink = read("scripts/images/shrink-image.sh")
assert.ok(/phone\) maxw=\d+; maxh=\d+ ;;/.test(shrink), "shrink-image.sh knows how big a phone picture needs to be")
const tmp = fs.mkdtempSync(path.join(os.tmpdir(), "sekaipop-phonewall-"))
try {
    const dir = path.join(tmp, "sekaipop")
    fs.mkdirSync(dir)
    fs.writeFileSync(path.join(dir, "phone-100.png"), "x")
    fs.writeFileSync(path.join(dir, "avatar-100.png"), "x")
    const env = { ...process.env, XDG_DATA_HOME: tmp }
    const out = execFileSync("sh", [pick, "load"], { env, encoding: "utf8" })
    assert.ok(out.includes("phone " + path.join(dir, "phone-100.png")), "load finds the phone picture")
    assert.ok(out.includes("avatar " + path.join(dir, "avatar-100.png")), "and still the avatar")
    execFileSync("sh", [pick, "clear", "phone"], { env })
    assert.ok(!fs.existsSync(path.join(dir, "phone-100.png")) && fs.existsSync(path.join(dir, "avatar-100.png")),
              "clear phone forgets only the phone picture")
} finally {
    fs.rmSync(tmp, { recursive: true, force: true })
}
console.log("phone_wallpaper_test: all checks passed")
