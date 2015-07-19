function table.each(t, ...)
  if not t then return end
  return lume.each(t, ...)
end

function table.with(t, k, ...)
  local args = {...}
  table.each(t, function(v) lume.call(v[k], v, unpack(args)) end)
end

function table.interpolate(t1, t2, x)
  local res = {}
  for k, v in pairs(t2) do
    if not t1[k] then return t2[k] end
    res[k] = lume.lerp(t1[k], t2[k], x)
  end
  return res
end

function math.clamp(x, l, h) return math.min(math.max(x, l), h) end

function math.hlola(x1, y1, x2, y2, x3, y3, x4, y4) -- Hot line on line action (boolean).
  local function s(x1, y1, x2, y2, x3, y3)
    return (y3 - y1) * (x2 - x1) > (y2 - y1) * (x3 - x1)
  end
  return s(x1, y1, x3, y3, x4, y4) ~= s(x2, y2, x3, y3, x4, y4) and s(x1, y1, x2, y2, x3, y3) ~= s(x1, y1, x2, y2, x4, y4)
end

function math.hlora(x1, y1, x2, y2, rx, ry, rw, rh) -- Hot line on rectangle action (boolean).
  local rxw, ryh = rx + rw, ry + rh
  return math.hlola(x1, y1, x2, y2, rx, ry, rxw, ry)
      or math.hlola(x1, y1, x2, y2, rx, ry, rx, ryh)
      or math.hlola(x1, y1, x2, y2, rxw, ry, rxw, ryh)
      or math.hlola(x1, y1, x2, y2, rx, ryh, rxw, ryh)
end

physics = {}
function physics.draw(how, obj)
  if obj.shape:typeOf('PolygonShape') then
    love.graphics.polygon(how, obj.body:getWorldPoints(obj.shape:getPoints()))
  end
end

timer = {}
function timer.rot(v, fn)
 if v > 0 then
   v = v - ls.tickrate
   if v <= 0 then
     v = 0
     v = lume.call(fn) or 0
   end
 end
 return v
end
