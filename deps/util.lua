f = {}
f.exe = function(x, ...) if type(x) == 'function' then return x(...) end return x end

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

function drawPhysicsObject(how, obj)
  if obj.shape:typeOf('PolygonShape') then
    love.graphics.polygon(how, obj.body:getWorldPoints(obj.shape:getPoints()))
  end
end
