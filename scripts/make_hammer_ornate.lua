-- Ornate hammer based on hammer_round: gold trim + emerald on right of head.
-- Canvas 48x48. Does not modify hammer / hammer_round.
-- Usage: ./scripts/aseprite-cli.sh --script scripts/make_hammer_ornate.lua

local OUT_ASE = app.params["out_ase"] or "src/weapons/hammer_ornate.aseprite"
local OUT_PNG = app.params["out_png"] or "export/weapons/hammer_ornate.png"

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
  goldY = Color{ r=232, g=196, b=64, a=255 },
  goldR = Color{ r=196, g=72, b=48, a=255 },
  gemL = Color{ r=120, g=220, b=140, a=255 },
  gemM = Color{ r=40, g=168, b=96, a=255 },
  gemD = Color{ r=20, g=110, b=70, a=255 },
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
  ["Y"] = C.goldY,
  ["R"] = C.goldR,
  ["g"] = C.gemL,
  ["G"] = C.gemM,
  ["E"] = C.gemD,
}

local rows = {
  "................................................", -- 0
  "................................................", -- 1
  "................................................", -- 2
  "................................................", -- 3
  "................................................", -- 4
  "................................................", -- 5
  ".....OOOOOOOOOOO................................", -- 6
  "....OLLLLLLLLMRYO...............................", -- 7
  "...OLLLLLLLLLMYRYO..............................", -- 8
  "...OLLLLLLLLMMRYRO..............................", -- 9
  "...OLLLLLLLMMMYRYO..............................", -- 10
  "...OLLLLLLLMMMRYRO..............................", -- 11
  "...OLLLLLLMMMMYRYO..............................", -- 12
  "...OLLLLLMMMMMRYRO..............................", -- 13
  "...OLLLLLMMMMMYRYRO.............................", -- 14
  "...OLLLLMMMMMMRYRYOOOOOOOOOOOOOOOOOOO...........", -- 15
  "..OlLLLLMMMMMMYEYRYllllllllllllwwwwwlO..........", -- 16
  ".OllLLLMMMMMMMEGEYRllllllllllllwwwwwllO.........", -- 17
  ".OmmLLMMMMMMMEGgGEYmmmmmmmmmmmmwwwwwmmO.........", -- 18
  ".OmmLLMMMMMMMMEGEYRmmmmmmmmmmmmwwwwwmmO.........", -- 19
  ".OddLMMMMMMMMMYEYRYddddddddddddwwwwwddO.........", -- 20
  "..OdMMMMMMMMMDRYRYRddddddddddddwwwwwdO..........", -- 21
  "...OMMMMMMMMMDYRYROOOOOOOOOOOOOOOOOOO...........", -- 22
  "...OMMMMMMMMDDRYRYO.............................", -- 23
  "...OMMMMMMMDDDYRYO..............................", -- 24
  "...OMMMMMMMDDDRYRO..............................", -- 25
  "...OMMMMMMDDDDYRYO..............................", -- 26
  "...OMMMMMDDDDDRYRO..............................", -- 27
  "...OMMMMMDDDDDYRYO..............................", -- 28
  "...OMMMMDDDDDDRYRO..............................", -- 29
  "....OMMDDDDDDDYRO...............................", -- 30
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
slice.name = "hammer_ornate"
slice.pivot = Point(PIVOT_X, PIVOT_Y)
slice.data = string.format("grip=%d,%d;facing=left;view=side;style=ornate", PIVOT_X, PIVOT_Y)

spr:saveAs(OUT_ASE)
spr:saveCopyAs(OUT_PNG)
print(string.format("Wrote %s and %s (pivot %d,%d)", OUT_ASE, OUT_PNG, PIVOT_X, PIVOT_Y))
