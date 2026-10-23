// Low-battery warnings: the rules (modules/common/functions/BatteryAlertMath.js, loaded for
// real) and the wiring around them (read from the source, since node cannot load QML).
//   node tests/battery-alert-test/battery_alert_test.js
const fs = require("fs")
const path = require("path")
const assert = require("assert")

const root = path.join(__dirname, "..", "..")
const read = f => fs.readFileSync(path.join(root, f), "utf8")
const src = read("modules/common/functions/BatteryAlertMath.js").replace(".pragma library", "")
const BA = new Function(src + "\nreturn { LEVELS, CRITICAL_AT, NONE, levelFor, isCritical, decide, message }")()

// Feeds a list of readings through decide() the way the service does, and returns the levels sent.
function run(readings) {
    let fired = BA.NONE
    let first = true
    const sent = []
    for (const r of readings) {
        const pct = Array.isArray(r) ? r[0] : r
        const plugged = Array.isArray(r) ? !!r[1] : false
        const out = BA.decide(pct, plugged, fired, first)
        if (pct > 0) first = false
        fired = out.fired
        if (out.level > 0) sent.push(out.level)
    }
    return sent
}
const eq = (got, want, what) => assert.deepStrictEqual(got, want, what + ": got " + JSON.stringify(got))

assert.deepStrictEqual(BA.LEVELS, [20, 15, 10, 5], "the levels")

// levelFor: the lowest level reached
eq([21, 20, 19, 16, 15, 14, 11, 10, 9, 6, 5, 4, 1].map(BA.levelFor), [0, 20, 20, 20, 15, 15, 15, 10, 10, 10, 5, 5, 5], "levelFor")

// a normal run down, starting well above 20: one warning per level, in order, once each
eq(run([30, 25, 21, 20, 19, 18, 17, 16, 15, 14, 12, 10, 9, 7, 5, 4, 3]), [20, 15, 10, 5], "full discharge")

// the same level read again does not repeat
eq(run([30, 19, 19, 19, 19]), [20], "no repeats")

// a jump over levels sends only the one it landed on (30 -> 12 is the 15 warning, not 20 and 15)
eq(run([30, 12]), [15], "jump over a level")
eq(run([30, 4]), [5], "jump to the bottom")

// a reading that wobbles around a level does not warn again
eq(run([25, 20, 21, 20, 21, 20, 22, 20]), [20], "wobble at 20")
eq(run([25, 19, 15, 16, 15, 16, 15]), [20, 15], "wobble at 15")

// plugging in starts over
eq(run([30, 19, 14, [14, true], [30, true], 19, 14]), [20, 15, 20, 15], "unplug, recharge, run down again")
eq(run([30, 14, [14, true], 14]), [15, 15], "unplug at the same level after a short charge warns again")

// no charger reported, but the battery climbed well past 20: counts as recharged
eq(run([30, 19, 40, 19]), [20, 20], "recharged without a charger flag")

// while plugged in nothing is sent, however low
eq(run([[10, true], [8, true], [4, true]]), [], "plugged in")

// not read yet (0 %) is never "empty", and does not use up the first reading
eq(run([0, 0, 50]), [], "0 % is not read yet")
eq(run([0, 0, 8]), [10], "0 %, then a real critical reading")

// the first reading: normal levels are remembered, not said; critical ones are said
eq(run([18]), [], "start at 18 %: silent")
eq(run([18, 17, 16, 15, 14]), [15], "start at 18 %: the next level still warns");
eq(run([12]), [], "start at 12 %: silent")
eq(run([9]), [10], "start at 9 %: critical, said")
eq(run([3]), [5], "start at 3 %: critical, said")

// urgency: 20 / 15 normal, 10 / 5 critical
assert.ok(!BA.isCritical(20) && !BA.isCritical(15) && BA.isCritical(10) && BA.isCritical(5) && !BA.isCritical(0))
eq(BA.LEVELS.map(l => BA.message(l, l, "").urgency), ["normal", "normal", "critical", "critical"], "urgency per level")

// text: real percentage and the time when there is one
eq(BA.message(15, 14, "38m"), { title: "Battery low", body: "14% left, about 38m. Plug in soon.", urgency: "normal" }, "text with time")
eq(BA.message(10, 10, "").body, "10% left. Plug in now.", "text without time")
assert.ok(/shut down/.test(BA.message(5, 5, "").body), "the last level says it may shut down")

// ---- wiring ----
const svc = read("services/BatteryAlertService.qml")
const ss = read("services/SettingsService.qml")
const dp = read("services/DesktopPresetService.qml")
const shell = read("shell.qml")
const page = read("modules/sekai/settings/SettingsPageGeneral.qml")
const nk = read("modules/common/functions/NotifyKinds.js")

assert.ok(/"battery\.alerts": true/.test(ss), "battery.alerts exists and defaults to on")
assert.ok(/SettingsService\.flag\("battery\.alerts"\)/.test(svc), "the service obeys the setting")
assert.ok(/SettingsService\.toggle\("battery\.alerts"\)/.test(page), "Settings > General has the switch")
const keep = dp.slice(dp.indexOf("property var keepExact"), dp.indexOf("]", dp.indexOf("property var keepExact")))
assert.ok(/"battery\.alerts"/.test(keep), "a preset leaves battery.alerts alone")
assert.ok(/^\s*BatteryAlertService \{\}/m.test(shell), "shell.qml builds one BatteryAlertService")
assert.strictEqual((shell.match(/BatteryAlertService \{/g) || []).length, 1, "only one of them")
assert.ok(/battery_alert/.test(nk), "the badge glyph has a colour in NotifyKinds.js")
assert.ok(/"-i", "material:battery_alert"/.test(svc), "the notification carries the shell's own badge glyph")
assert.ok(/"-u", m\.urgency/.test(svc), "urgency is passed to notify-send")
assert.ok(/BA\.decide\(/.test(svc) && /BatteryAlertMath\.js/.test(svc), "the service uses the tested rules")
assert.ok(/target: "battery"/.test(svc), "ipc call battery ... exists for testing")
assert.ok(/root\.percent <= 0/.test(svc), "0 % is never judged")
assert.ok(!/Timer \{[^}]*repeat: true/.test(svc), "nothing polls")

console.log("battery-alert-test: all passed")
