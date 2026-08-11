-- Create a left-facing round-head hammer (bigger head, shorter handle).
-- Same 48x48 canvas as the simple hammer; does not modify hammer.aseprite.
-- Head is a horizontal capsule with bulging ends (圆头锤), not a flat block.
-- Usage:
--   ./scripts/aseprite-cli.sh --script scripts/make_hammer_round.lua

local OUT_ASE = app.params["out_ase"] or "src/weapons/hammer_round.aseprite"
local OUT_PNG = app.params["out_png"] or "export/weapons/hammer_round.png"

local W, H = 48, 48

local COL = {
  O = Color{ r=42, g=34, b=28, a=255 },
  L = Color{ r=196, g=202, b=212, a=255 },
  M = Color{ r=138, g=146, b=158, a=255 },
  D = Color{ r=78, g=85, b=96, a=255 },
  l = Color{ r=196, g=138, b=70, a=255 },
  m = Color{ r=154, g=101, b=50, a=255 },
  d = Color{ r=107, g=64, b=32, a=255 },
  w = Color{ r=72, g=58, b=44, a=255 },
}

local spr = Sprite(W, H, ColorMode.RGB)
spr.filename = OUT_ASE
app.activeSprite = spr
local img = spr.cels[1].image
img:clear(Color{ r=0, g=0, b=0, a=0 })

local function put(x, y, c)
  if x >= 0 and x < W and y >= 0 and y < H then
    img:drawPixel(x, y, c)
  end
end

local function is_opaque(x, y)
  if x < 0 or x >= W or y < 0 or y >= H then return false end
  return app.pixelColor.rgbaA(img:getPixel(x, y)) > 0
end

-- Heavy round-head silhouette:
-- union of left ball + right ball + thick middle bar (bulging ends).
local function inside_head(x, y)
  local px, py = x + 0.5, y + 0.5
  -- left striking bulb
  local lx, ly, lr = 9.0, 16.0, 9.2
  local dx, dy = px - lx, py - ly
  if dx * dx + dy * dy <= lr * lr then return true end
  -- right peen bulb (slightly smaller)
  local rx, ry, rr = 22.0, 16.0, 8.4
  dx, dy = px - rx, py - ry
  if dx * dx + dy * dy <= rr * rr then return true end
  -- thick bar connecting bulbs (reads as one heavy head)
  if px >= 9 and px <= 22 and py >= 8.5 and py <= 23.5 then
    -- slight vertical taper so ends stay rounder than the waist
    local mid = 15.5
    local half = 7.2
    if math.abs(py - mid) <= half then return true end
  end
  return false
end

for y = 0, H - 1 do
  for x = 0, W - 1 do
    if inside_head(x, y) then
      local px, py = x + 0.5, y + 0.5
      -- shade: upper-left light, core/lower-right dark for weight
      local shade = (px - 9) / 18 * 0.55 + (py - 8) / 16 * 0.7
      local c
      if shade < 0.35 then
        c = COL.L
      elseif shade < 0.75 then
        c = COL.M
      else
        c = COL.D
      end
      -- deepen absolute left face highlight
      if px < 6 and py > 12 and py < 20 then c = COL.L end
      put(x, y, c)
    end
  end
end

-- Short handle (smaller than simple hammer)
local handle_y0, handle_y1 = 14, 18
local handle_x0, handle_x1 = 26, 40
for y = handle_y0, handle_y1 do
  for x = handle_x0, handle_x1 do
    local t = (y - handle_y0) / (handle_y1 - handle_y0)
    local c
    if t < 0.3 then c = COL.l
    elseif t < 0.65 then c = COL.m
    else c = COL.d end
    put(x, y, c)
  end
end

-- Grip wrap near butt
for y = handle_y0, handle_y1 do
  for x = 34, 38 do
    put(x, y, COL.w)
  end
end

-- Round the handle butt corners
put(handle_x1, handle_y0, Color{ r=0, g=0, b=0, a=0 })
put(handle_x1, handle_y1, Color{ r=0, g=0, b=0, a=0 })

-- 1px outline (4-neighborhood). Collect first so outline does not flood.
local outline = {}
for y = 0, H - 1 do
  for x = 0, W - 1 do
    if not is_opaque(x, y) then
      if is_opaque(x - 1, y) or is_opaque(x + 1, y)
          or is_opaque(x, y - 1) or is_opaque(x, y + 1) then
        outline[#outline + 1] = { x, y }
      end
    end
  end
end
for _, p in ipairs(outline) do
  put(p[1], p[2], COL.O)
end

local PIVOT_X, PIVOT_Y = 36, 16

local slice = spr:newSlice(Rectangle(0, 0, W, H))
slice.name = "hammer_round"
slice.pivot = Point(PIVOT_X, PIVOT_Y)
slice.data = string.format("grip=%d,%d;facing=left;view=side;style=round", PIVOT_X, PIVOT_Y)

spr:saveAs(OUT_ASE)
spr:saveCopyAs(OUT_PNG)
print(string.format("Wrote %s and %s (pivot %d,%d)", OUT_ASE, OUT_PNG, PIVOT_X, PIVOT_Y))
