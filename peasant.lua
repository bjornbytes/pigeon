Peasant = extend(Person)

Peasant.rangeRange = {200, 350}
Peasant.reloadRange = {1, 1.5}

----------------
-- Core
----------------
function Peasant:activate()
  local genders = {'male', 'female', 'knight', 'wizard'}
  self.gender = genders[love.math.random(1, #genders)]
  if self.gender == 'knight' or self.gender == 'wizard' then
    self.index = 1
  else
    self.index = love.math.random(1, 2)
  end

  self.image = data.media.graphics.kingdumb[self.gender]['normal' .. self.index]
  self.direction = 1

  self.state = self.state or self.idle
  self.walkTimer = 1
  self.reloadTimer = 0

  self.range = lume.random(unpack(self.rangeRange))

  Person.activate(self)
end

function Peasant:update()
  self.walkTimer = timer.rot(self.walkTimer)

  Person.update(self)
end

----------------
-- Helpers
----------------
function Peasant:inRange()
  return self:distanceTo(ctx.pigeon) < self.range
end

----------------
-- States
----------------
Peasant.idle = {}
Peasant.idle.walkRate = {.4, .5}
function Peasant.idle:update()
  self.image = data.media.graphics.kingdumb[self.gender]['normal' .. self.index]
  if self:distanceTo(ctx.pigeon) < 300 then
    self:changeState('panic')
  end

  if self.walkTimer == 0 then
    self:hop(0)
    self.walkTimer = lume.random(unpack(self.state.walkRate))
  end
end

Peasant.panic = {}
Peasant.panic.walkRate = {.3, .4}
function Peasant.panic:update()
  self.direction = 1
  self.image = data.media.graphics.kingdumb[self.gender]['panic' .. self.index]

  if self.walkTimer == 0 then
    self:hop(self.direction)
    self.walkTimer = lume.random(unpack(self.state.walkRate))
  end
end
