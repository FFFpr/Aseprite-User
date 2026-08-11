-- Create a left-facing side-view pixel hammer with grip pivot.
-- Usage:
--   mkdir -p src/weapons export/weapons
--   ./scripts/aseprite-cli.sh --script scripts/make_hammer.lua

local OUT_ASE = app.params["out_ase"] or "src/weapons/hammer.aseprite"
local OUT_PNG = app.params["out_png"] or "export/weapons/hammer.png"

local W, H = 48, 48

local C = {
  empty = Color{ r=0, g=0, b=0, a=0 },
  outline = Color{ r=42, g=34, b=28, a=255 },
  metalL = Color{ r=196, g=202, b=212, a=255 },
  metalM = Color{ r=138, g=146, b=158, a=255 },
  metalD = Color{ r=78, g=85, b=96, a=255 },
  woodL = Color{ r=196, g=138, b=70, a=255 },
  woodM = Color{ r=154, g=101, b=50, a=255 },
  woodD = Color{ r=107, g=64, b=32, a=255 },
  wrap = Color{ r=72, g=58, b=44, a=255 },
}

-- . empty  O outline
-- L/M/D metal light/mid/dark
-- l/m/d wood light/mid/dark
-- w grip wrap
local palette = {
  ["."] = C.empty,
  ["O"] = C.outline,
  ["L"] = C.metalL,
  ["M"] = C.metalM,
  ["D"] = C.metalD,
  ["l"] = C.woodL,
  ["m"] = C.woodM,
  ["d"] = C.woodD,
  ["w"] = C.wrap,
}

-- 48x48. Facing LEFT: hammer head on the left, handle extends right.
-- Grip pivot at wrap center (29, 21).
local rows = {
--         1         2         3         4
--123456789012345678901234567890123456789012345678
  "................................................", -- 0
  "................................................", -- 1
  "................................................", -- 2
  "................................................", -- 3
  "................................................", -- 4
  "................................................", -- 5
  "................................................", -- 6
  "................................................", -- 7
  "................................................", -- 8
  "................................................", -- 9
  "......OOOOOOOO..................................", -- 10
  ".....OLLLLLLLMO.................................", -- 11
  ".....OLLLLLMMMO.................................", -- 12
  ".....OLLLLMMMDO.................................", -- 13
  ".....OLLLMMMDDO.................................", -- 14
  ".....OLLMMMDDDO.................................", -- 15
  ".....OMMMDDDDDOOOOOOOOOOOOOOOOOOOOOOOOO.........", -- 16 neck→handle
  ".....OMMDDDDDDllllllllllllllllllllllmmmO........", -- 17
  ".....OMDDDDDDDlllllllllllllllllllllmmmmO........", -- 18
  ".....ODDDDDDDDmmmmmmmmmmmmmmmmmmmmmddddO........", -- 19
  ".....ODDDDDDDDmmmmmmmmmmmmmwwwwwmmmddddO........", -- 20 wrap near butt
  ".....OMMDDDDDDdddddddddddddwwwwwdddddddO........", -- 21 wrap / grip
  ".....OMMMDDDDDddddddddddddddddddddddddO.........", -- 22
  ".....OLMMMDDDOOOOOOOOOOOOOOOOOOOOOOOOO..........", -- 23
  ".....OLLLMMMDDO.................................", -- 24
  ".....OLLLLMMMDO.................................", -- 25
  ".....OLLLLLMMMO.................................", -- 26
  ".....OLLLLLLLDO.................................", -- 27
  "......OOOOOOOO..................................", -- 28
  "................................................", -- 29
  "................................................", -- 30
  "................................................", -- 31
  "................................................", -- 32
  "................................................", -- 33
  "................................................", -- 34
  "................................................", -- 35
  "................................................", -- 36
  "................................................", -- 37
  "................................................", -- 38
  "................................................", -- 39
  "................................................", -- 40
  "................................................", -- 41
  "................................................", -- 42
  "................................................", -- 43
  "................................................", -- 44
  "................................................", -- 45
  "................................................", -- 46
  "................................................", -- 47
}

assert(#rows == H, "row count mismatch: " .. #rows)
for i, row in ipairs(rows) do
  assert(#row == W, string.format("row %d width %d != %d", i - 1, #row, W))
end

-- Wrap band center on handle (see rows 20-21, x=27-31)
local PIVOT_X, PIVOT_Y = 29, 21

local spr = Sprite(W, H, ColorMode.RGB)
spr.filename = OUT_ASE
app.activeSprite = spr

local img = spr.cels[1].image
img:clear(C.empty)

for y = 0, H - 1 do
  local row = rows[y + 1]
  for x = 0, W - 1 do
    local ch = row:sub(x + 1, x + 1)
    local col = palette[ch]
    if not col then
      error(string.format("unknown char '%s' at %d,%d", ch, x, y))
    end
    if col.alpha > 0 then
      img:drawPixel(x, y, col)
    end
  end
end

local slice = spr:newSlice(Rectangle(0, 0, W, H))
slice.name = "hammer"
slice.pivot = Point(PIVOT_X, PIVOT_Y)
slice.data = string.format("grip=%d,%d;facing=left;view=side", PIVOT_X, PIVOT_Y)

spr:saveAs(OUT_ASE)
spr:saveCopyAs(OUT_PNG)

print(string.format("Wrote %s and %s (pivot %d,%d)", OUT_ASE, OUT_PNG, PIVOT_X, PIVOT_Y))
