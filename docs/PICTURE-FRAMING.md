# Framing the shell's own pictures

The banner and the avatar on the Quick Panel (and on the desktop's user card), and the phone's
own wallpaper, can be framed: you choose which part of the picture fills its slot, by moving it
and zooming in. They used to be drawn centred and cropped, so a banner whose subject was
off-centre, or a tall photo as an avatar, showed the wrong part. They are also all managed in
one place now: Edit Desktop › THEME.

## Using it

- **Edit Desktop › THEME** starts with the three pictures (before the theme tiles). Each shows
  what it is now and has keys: **Change** (the picture chooser), **Frame**, **Remove** (two
  clicks: the first says "Remove?"). The phone's also chooses what it shows: **Off**, **Desktop**
  (the monitor's wallpaper) or **A picture** of its own; "A picture" with none picked opens the
  chooser first.
- **On the Quick Panel**, hover the banner: **Change** and **Frame** keys. Hover the avatar: a
  **Frame** key (bottom left; the remove badge has the bottom right). Clicking the picture
  itself still changes it, as before.
- **Settings › General › Quick Panel**: "Frame the phone's picture", beside "Change the phone's
  picture".
- **A picture you have just picked** opens the framer straight away, centred, so Done at once
  is what the shell always showed. Until you press Done the new picture is only tried on:
  **Cancel** puts the one it replaced back (and the phone's mode, if picking turned "A picture"
  on), and the new copy is deleted.
- **Change / Pick in Edit Desktop** close Edit Desktop first: the chooser is a normal window, and
  Edit Desktop parks the windows and draws over them. The framer follows the pick.

**The framer** is one card for all three. Drag the picture to move it, scroll (or + / -, or the
slider) to zoom up to 6x, arrow keys to nudge it. Outside the slot the whole picture is shown
dimmed, so you see what you are cropping out. **Reset** centres it, **Cancel** or **Esc** leaves
everything as it was, **Done** (or Enter) saves it. What it shows while you frame:

| Picture | Shown in the slot |
| --- | --- |
| Banner | at its real size, 602 x 240, with the clock and the speed readout over it in the ink the Quick Panel will pick (the chip under it says which), and the avatar where it sits on it |
| Avatar | 2.5x, with its real size (120 px) beside it; the user card shows the same framing in its own shape |
| Phone wallpaper | the phone's glass, with a hint of the Quick screen's cards or the Apps screen's grid (switch them at the top right): one framing for both |

In Edit Desktop the framer sits over the stage and the tray stays, its hints saying what
framing does; anywhere else it opens over the desktop on the monitor you were using.

```sh
qs -c sekaipop ipc call pictures pick banner|avatar|phone      # the chooser (then the framer)
qs -c sekaipop ipc call pictures frame banner|avatar|phone     # the framer
qs -c sekaipop ipc call pictures unframe banner|avatar|phone   # back to centred
qs -c sekaipop ipc call pictures close                         # close the framer (as Cancel)
```

## How it works

- **The numbers** are the Custom Image widget's CROP mode: `zoom` 1..6 (1 = just covering the
  slot), `panX` / `panY` -1..1 (0 = centred). `ImageMath.drawRect` draws with them. Centred is
  exactly `PreserveAspectCrop`, so a picture nobody framed looks as it always did.
- **Stored** in the setting `pictures.framing` (JSON), one entry per kind with the picture's file
  name (`modules/common/functions/Framing.js`). A framing belongs to one picture: picking another
  starts centred. A centred framing is not stored at all.
- **Presets** carry the banner's and avatar's framing inside their `images` part, beside the
  picture's own copy, and put it back on the copy they restore (which comes back under a new
  name). `pictures.framing` is in the presets' `keepExact`, so wearing a preset never applies a
  framing meant for another picture. A centred picture adds nothing to a preset, so presets
  saved before framing still read as the look you are wearing.
- **Drawn by** `modules/common/widgets/FramedImage.qml`: a probe reads the picture's shape, then
  the picture is decoded at the size it is drawn (so a 6x zoom stays sharp and a centred banner
  costs what it did) and placed by `drawRect`. It replaces the `PreserveAspectCrop` images of
  the Quick Panel's banner and avatar, the user card's `MaskedPhoto`, and the phone's
  `LauncherLcd` (which keeps its 2400 px ceiling). The banner's and the phone's ink samplers
  measure the framed part, so the text colour follows the framing.
- **A new pick is pending** until the framer closes (`PanelImages.pending`): `pick-image.sh`
  keeps the copy it replaces (`SEKAIPOP_PICK_KEEP=1`), Done drops that one, Cancel drops the new
  one (`pick-image.sh drop <path>`, only ever a `<kind>-*` file in the data folder). A pick left
  unsettled by a shell stopping mid-framer is tidied at the next start (`load` keeps the newest).
- **Rounded clips** are `modules/common/widgets/RoundClip.qml`, a Quickshell `ClippingRectangle`
  with per-corner radii. A masked layer (MultiEffect) was tried first: one inside another (the
  slot in the work area, the thumbnails in the tray) drew square.
- **The UI**: `modules/sekai/framing/FramerCard.qml` (the card), `FramerWindow.qml` (one per
  monitor, built only while framing: over the stage in Edit Desktop, full screen otherwise),
  `modules/sekai/editMode/PicturesRow.qml` (the THEME board's pictures), the hover keys in
  `QuickPanelFace.qml`, and the state in `PanelImages.qml` (`framingFor`, `setFraming`, `frame`,
  `closeFramer`).

## Where it departs from the design

- The phone's slot is the glass's real proportions (616 x 1176, so 229 x 437 in the framer, with
  a 30 px corner), not the canvas's 235 x 437.
- The banner preview shows the real clock and date where the Quick Panel puts them (41, 10; 24 /
  20 px), not the canvas's larger sample, and arrows for the speed readout instead of invented
  rates.
- The avatar's Frame key sits at its bottom left: its bottom right already holds the remove
  badge.
- The THEME board's picture tiles leave out the sample clock on the banner thumbnail, the phone
  tile's keys are icons only, and the avatar tile is 180 wide (the canvas's 170 cut its label).
- The canvas kept a new pick on Cancel ("a new pick stays, centred"); here Cancel puts the old
  picture back, which is what Cancel reads as.

## Tests

`node tests/framing-test/framing_unit.js`: normalising, what is kept per file, the setting's
round trip and junk, the zoom steps, and that centred is today's crop.
