function new(x, ...)
  local t = extend(x)
  if t.init then
    t:init(...)
  end
  return t
end

function extend(x)
  local t = {}
  setmetatable(t, {__index = x, __call = new})
  return t
end

function class() return extend() end
