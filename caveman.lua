Caveman = extend(Person)

Caveman.rangeRange = {200, 350}
Caveman.reloadRange = {1, 1.5}

----------------
-- Core
----------------
function Caveman:activate()
  self.gender = love.math.random() < .5 and 'female' or 'male'
  self.index = love.math.random(1, self.gender == 'male' and 1 or 2)
  self.image = data.media.graphics.dinoland[self.gender]['normal' .. self.index]
  self.direction = 1

  --self.hasSpear = love.math.random() > .5
  self.state = self.state or self.idle
  self.walkTimer = 1
  self.reloadTimer = 0

  self.range = lume.random(unpack(self.rangeRange))

  Person.activate(self)
end

function Caveman:update()
  self.walkTimer = timer.rot(self.walkTimer)

  Person.update(self)
end

----------------
-- Helpers
----------------
function Caveman:reloadSpear()
  self.reloadTimer = timer.rot(self.reloadTimer)
end

function Caveman:inRange()
  return self:distanceTo(ctx.pigeon) < self.range
end

----------------
-- States
----------------
Caveman.idle = {}
Caveman.idle.walkRate = {.4, .5}
function Caveman.idle:update()
  self.image = data.media.graphics.dinoland[self.gender]['normal' .. self.index]
  if self:distanceTo(ctx.pigeon) < 300 then
    self:changeState(love.math.random() < .5 and 'panic' or 'attack')
  end

  if self.walkTimer == 0 then
    self:hop(0)
    self.walkTimer = lume.random(unpack(self.state.walkRate))
  end
end

Caveman.panic = {}
Caveman.panic.walkRate = {.3, .4}
function Caveman.panic:update()
  self.direction = 1 -- -self:directionTo(ctx.pigeon)
  self.image = data.media.graphics.dinoland[self.gender]['panic' .. self.index]

  if self.walkTimer == 0 then
    self:hop(self.direction)
    self.walkTimer = lume.random(unpack(self.state.walkRate))
  end

  self:reloadSpear()
end

Caveman.attack = {}
Caveman.attack.walkRate = {.4, .6}
function Caveman.attack:update()
  self.direction = self:directionTo(ctx.pigeon)
  self.image = data.media.graphics.dinoland[self.gender]['normal' .. self.index]
  self:reloadSpear()

  if self:inRange() then
    if self.walkTimer == 0 and self.reloadTimer == 0 then
      self.reloadTimer = lume.random(unpack(self.reloadRange))
      ctx.projectiles:add(Spear, {x = self.body:getX(), y = self.body:getY() - self.h, direction = self.direction})
    end
  else
    if self.walkTimer == 0 then
      self:hop(self.direction)
      self.walkTimer = lume.random(unpack(self.state.walkRate))
    end
  end
end
