PhysicsInterpolator = class()

function PhysicsInterpolator:init(object, ...)
  self.object = object

  self.previous = {}
  self.current = {}

  self.props = {...}

  self:update()
end

function PhysicsInterpolator:update()
  self:updateState(self.previous)
end

function PhysicsInterpolator:lerp()
  self:updateState(self.current)

  local z = ls.accum / ls.tickrate
  local x = lume.lerp(self.previous.x, self.current.x, z)
  local y = lume.lerp(self.previous.y, self.current.y, z)
  local angle = lume.lerp(self.previous.angle, self.current.angle, z)

  self.object.body:setPosition(x, y)
  self.object.body:setAngle(angle)

  local result = {}

  table.each(self.props, function(prop)
    result[prop] = math.lerp(self.previous[prop], self.current[prop], z)
  end)

  return result
end

function PhysicsInterpolator:delerp()
  self.object.body:setPosition(self.current.x, self.current.y)
  self.object.body:setAngle(self.current.angle)
end

function PhysicsInterpolator:updateState(dest)
  table.each(self.props, function(prop)
    dest[prop] = self.object[prop]
  end)

  dest.x, dest.y = self.object.body:getPosition()
  dest.angle = self.object.body:getAngle()
end
