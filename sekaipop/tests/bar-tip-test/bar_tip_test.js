// Hover tags on the bar: every module that opens a popup (or a flyout) on a press also says what it is
// when the pointer rests on it, and the tag's own pointer check cannot hide it by mistake.
// Node cannot load QML, so this reads the source for the pieces that make that work.
//   node tests/bar-tip-test/bar_tip_test.js
const fs = require("fs")
const path = require("path")
const assert = require("assert")

const root = path.join(__dirname, "..", "..")
const read = f => fs.readFileSync(path.join(root, "modules/sekai/bar", f), "utf8")
const statusBar = read("Status_Bar.qml")

// each of these gets a tag, hover on its press area, the bar's edge from Status_Bar
const modules = ["BatteryIndicator", "ResourceIndicator", "WeatherIndicator", "DateIndicator", "KeyboardLayoutIndicator", "NotificationBadge"]
for (const m of modules) {
    const src = read(m + ".qml")
    assert.ok(/MouseArea \{[^}]*hoverEnabled: true/.test(src), m + ": its press area listens for hover")
    assert.ok(/BarTip \{[^}]*shown: area\.containsMouse[^}]*pressed: area\.pressed[^}]*text: root\.tipText[^}]*barPosition: root\.barPosition/.test(src), m + ": has a BarTip wired to its area")
    assert.ok(/property string barPosition: "top"/.test(src), m + ": knows which edge the bar is on")
    assert.ok(/readonly property string tipText:/.test(src), m + ": says something")
    const at = statusBar.indexOf("        " + m + " {")
    assert.ok(at >= 0, m + " is in Status_Bar.qml")
    const block = statusBar.slice(at, statusBar.indexOf("\n        }\n", at))
    assert.ok(/barPosition: status_Bar\.barPosition/.test(block), m + ": Status_Bar hands it the bar's edge")
}

// the utility keys (mic, screen snip, record, ...) name themselves on the bar's pill, not in the flyout
const key = read("UtilKey.qml"), keys = read("UtilKeys.qml"), buttons = read("UtilButtons.qml")
assert.ok(/BarTip \{[^}]*shown: root\.tip && area\.containsMouse[^}]*text: root\.label/.test(key), "UtilKey: tag shows the key's label when tip is on")
assert.strictEqual((keys.match(/tip: grid\.tips; barPosition: grid\.barPosition/g) || []).length, 8, "UtilKeys: all eight keys get tip + edge")
assert.ok(/tips: true/.test(buttons) && /barPosition: root\.barPosition/.test(buttons), "UtilButtons: the bar's keys have tags on")
assert.ok(!/tips: true/.test(read("UtilPopup.qml")), "UtilPopup: the flyout keeps its caption, no tags")
assert.ok(/barPosition: status_Bar\.barPosition/.test(statusBar.slice(statusBar.indexOf("UtilButtons {"), statusBar.indexOf("UtilButtons {") + 900)), "Status_Bar hands UtilButtons the edge")

// BarTip: the pointer check knows where a bottom / right bar's window really is, and a pointer that is
// visibly moving over the module is never "outside"
const tip = read("BarTip.qml")
assert.ok(/barPosition === "bottom"[\s\S]{0,60}scr\.height - win\.height/.test(tip), "BarTip: bottom bar window origin")
assert.ok(/barPosition === "right"[\s\S]{0,60}scr\.width - win\.width/.test(tip), "BarTip: right bar window origin")
assert.ok(/inside \|\| \(Date\.now\(\) - root\.lastMove < \d+\)/.test(tip), "BarTip: recent hover movement beats the cursor guess")
assert.ok(/acceptedButtons: Qt\.NoButton/.test(tip), "BarTip: its hover area takes no clicks")

console.log("bar-tip-test: all passed")
