PhysicsInterpolator = class()

function PhysicsInterpolator:init(body)
  self.body = body

  self.previous = {}
  self.current = {}

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

  self.body:setPosition(x, y)
  self.body:setAngle(angle)
end

function PhysicsInterpolator:delerp()
  self.body:setPosition(self.current.x, self.current.y)
  self.body:setAngle(self.current.angle)
end

function PhysicsInterpolator:updateState(dest)
  dest.x, dest.y = self.body:getPosition()
  dest.angle = self.body:getAngle()
end
