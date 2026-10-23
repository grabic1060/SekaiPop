// Framing.js: how the banner, avatar and phone picture are framed, and how that is kept.
//   node tests/framing-test/framing_unit.js
const fs = require('fs'), assert = require('assert')
const src = fs.readFileSync(__dirname + '/../../modules/common/functions/Framing.js', 'utf8').replace('.pragma library', '')
const F = new Function('module', src + '\nreturn module.exports')({ exports: {} })
const IMsrc = fs.readFileSync(__dirname + '/../../modules/common/functions/ImageMath.js', 'utf8').replace('.pragma library', '')
const IM = new Function(IMsrc + '\nreturn { drawRect: drawRect, panBy: panBy }')()
let n = 0
const ok = (c, m) => { assert.ok(c, m); n++ }
const eq = (a, b, m) => { assert.strictEqual(JSON.stringify(a), JSON.stringify(b), m); n++ }

// normalize: anything broken is centred, everything is kept in range
eq(F.normalize(null), { zoom: 1, panX: 0, panY: 0 }, 'nothing is centred')
eq(F.normalize({ zoom: 9, panX: -3, panY: 'x' }), { zoom: 6, panX: -1, panY: -1 }, 'clamped')
eq(F.normalize({ zoom: 0.2 }), { zoom: 1, panX: 0, panY: 0 }, 'zoom never under 1')
ok(F.isCentred({ zoom: 1, panX: 0, panY: 0 }) && !F.isCentred({ zoom: 1.2 }), 'isCentred')

// a centred framing is today's PreserveAspectCrop: cover, centred
const r = IM.drawRect(602, 240, 1800, 900, 'crop', 1, 0, 0)
ok(Math.abs(r.w - 602) < 1e-6 && Math.abs(r.h - 301) < 1e-6 && Math.abs(r.y + 30.5) < 1e-6 && r.x === 0, 'centred = cover, centred')

// stored per file: another picture of the same kind starts centred
const path = '/home/u/.local/share/sekaipop/banner-17.jpg'
let map = F.withFraming({}, 'banner', path, { zoom: 1.6, panX: 0.8, panY: -0.3 })
eq(map, { banner: { file: 'banner-17.jpg', zoom: 1.6, panX: 0.8, panY: -0.3 } }, 'saved with its file name')
eq(F.forPicture(map, 'banner', path), { zoom: 1.6, panX: 0.8, panY: -0.3 }, 'read back')
eq(F.forPicture(map, 'banner', '/home/u/.local/share/sekaipop/banner-18.jpg'), { zoom: 1, panX: 0, panY: 0 }, 'a new pick is centred')
eq(F.forPicture(map, 'avatar', path), { zoom: 1, panX: 0, panY: 0 }, 'kinds do not mix')
eq(F.forPicture(map, 'banner', ''), { zoom: 1, panX: 0, panY: 0 }, 'no picture: centred')

// a centred framing (or a removed picture) leaves nothing behind
map = F.withFraming(map, 'avatar', '/a/avatar-3.png', { zoom: 2, panX: 0, panY: 0.5 })
eq(Object.keys(map), ['banner', 'avatar'], 'two kinds')
eq(Object.keys(F.withFraming(map, 'banner', path, { zoom: 1, panX: 0, panY: 0 })), ['avatar'], 'Reset + Done drops the entry')
eq(Object.keys(F.withFraming(map, 'banner', '', { zoom: 2 })), ['avatar'], 'no picture drops it')

// the setting round-trips, and junk in it is dropped
eq(F.parse(F.stringify(map)), map, 'round trip')
eq(F.parse(''), {}, 'empty setting')
eq(F.parse('{not json'), {}, 'broken setting')
eq(F.parse('{"banner":{"zoom":2},"cat":{"file":"x"},"phone":{"file":"phone-1.png","zoom":40}}'),
   { phone: { file: 'phone-1.png', zoom: 6, panX: 0, panY: 0 } }, 'entries without a file or of an unknown kind are dropped')
ok(F.stringify({}) === '', 'nothing framed: the setting is empty')

// zoom steps and the slider
ok(F.stepZoom(1, 1) === 1.25 && F.stepZoom(1, -1) === 1 && F.stepZoom(5.9, 1) === 6, 'stepZoom')
ok(F.wheelZoom(1, true) === 1.08 && F.wheelZoom(1, false) === 1, 'wheelZoom')
ok(F.zoomFraction(1) === 0 && F.zoomFraction(6) === 1 && F.zoomFraction(3.5) === 0.5, 'zoomFraction')
ok(F.zoomFromFraction(0.5) === 3.5 && F.zoomFromFraction(-1) === 1, 'zoomFromFraction')
ok(F.zoomText(1.6) === '1.60×', 'zoomText')

// dragging moves the picture with the pointer, and never past its edges
const p = IM.panBy(602, 240, 1800, 900, 1, 0, 0, 0, 10)
ok(p.panX === 0 && p.panY < 0, 'drag down shows more of the top')
const q = IM.panBy(602, 240, 1800, 900, 1, 0, 0, 500, 0)
ok(q.panX === 0, 'at zoom 1 a wide banner cannot move sideways (nothing to show)')

console.log('framing_unit: ' + n + ' checks passed')
