-- Thick round-end hammer (same family as simple hammer; bigger/thicker head).
-- Ends bulge only a few pixels. Canvas 48x48. Does not modify hammer.aseprite.
-- Usage: ./scripts/aseprite-cli.sh --script scripts/make_hammer_round.lua

local OUT_ASE = app.params["out_ase"] or "src/weapons/hammer_round.aseprite"
local OUT_PNG = app.params["out_png"] or "export/weapons/hammer_round.png"

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

local rows = {
  "................................................", -- 0
  "................................................", -- 1
  "................................................", -- 2
  "................................................", -- 3
  "................................................", -- 4
  "................................................", -- 5
  ".....OOOOOOOOOOO................................", -- 6
  "....OLLLLLLLLMMMO...............................", -- 7
  "...OLLLLLLLLLMMMMO..............................", -- 8
  "...OLLLLLLLLMMMMMO..............................", -- 9
  "...OLLLLLLLMMMMMMO..............................", -- 10
  "...OLLLLLLLMMMMMMO..............................", -- 11
  "...OLLLLLLMMMMMMMO..............................", -- 12
  "...OLLLLLMMMMMMMMO..............................", -- 13
  "..OLLLLLLMMMMMMMMMO.............................", -- 14
  "..OLLLLLMMMMMMMMMMOOOOOOOOOOOOOOOOOOO...........", -- 15
  ".OLLLLLLMMMMMMMMlllllllllllllllwwwwwlO..........", -- 16
  ".OLLLLLMMMMMMMMMlllllllllllllllwwwwwllO.........", -- 17
  ".OLLLLMMMMMMMMMDmmmmmmmmmmmmmmmwwwwwmmO.........", -- 18
  ".OLMLLMMMMMMMMDDmmmmmmmmmmmmmmmwwwwwmmO.........", -- 19
  ".OLMLMMMMMMMMMDDdddddddddddddddwwwwwddO.........", -- 20
  ".OLMMMMMMMMMMDDDdddddddddddddddwwwwwdO..........", -- 21
  "..OMMMMMMMMMMDDDDDOOOOOOOOOOOOOOOOOOO...........", -- 22
  "..OMMMMMMMMMDDDDDDO.............................", -- 23
  "...OMMMMMMMDDDDDDO..............................", -- 24
  "...OMMMMMMMDDDDDDO..............................", -- 25
  "...OMMMMMMDDDDDDDO..............................", -- 26
  "...OMMMMMDDDDDDDDO..............................", -- 27
  "...OMMMMMDDDDDDDDO..............................", -- 28
  "...OMMMMDDDDDDDDDO..............................", -- 29
  "....OMMDDDDDDDDDO...............................", -- 30
  ".....OOOOOOOOOOO................................", -- 31
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

assert(#rows == H)
for i, row in ipairs(rows) do
  assert(#row == W, string.format("row %d width %d != %d", i - 1, #row, W))
end

local PIVOT_X, PIVOT_Y = 33, 18

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
    if not col then error(string.format("unknown '%s' at %d,%d", ch, x, y)) end
    if col.alpha > 0 then img:drawPixel(x, y, col) end
  end
end

local slice = spr:newSlice(Rectangle(0, 0, W, H))
slice.name = "hammer_round"
slice.pivot = Point(PIVOT_X, PIVOT_Y)
slice.data = string.format("grip=%d,%d;facing=left;view=side;style=round", PIVOT_X, PIVOT_Y)

spr:saveAs(OUT_ASE)
spr:saveCopyAs(OUT_PNG)
print(string.format("Wrote %s and %s (pivot %d,%d)", OUT_ASE, OUT_PNG, PIVOT_X, PIVOT_Y))
