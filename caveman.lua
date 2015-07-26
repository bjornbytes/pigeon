Caveman = extend(Person)

Caveman.rangeRange = {100, 150}
Caveman.reloadRange = {3, 4}

----------------
-- Core
----------------
function Caveman:activate()
  self.gender = love.math.random() < .5 and 'female' or 'male'
  self.image = data.media.graphics.dinoland[self.gender].normal
  self.direction = 1

  self.hasSpear = love.math.random() > .5
  self.state = self.hasSpear and self.attack or self.panic
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
  self.reloadTimer = timer.rot(self.reloadTimer, function()
    self.hasSpear = true
  end)
end

function Caveman:inRange()
  return self:distanceTo(ctx.pigeon) < self.range
end

----------------
-- States
----------------
Caveman.panic = {}
Caveman.panic.walkRate = {.3, .4}
function Caveman.panic:update()
  self.direction = 1 -- -self:directionTo(ctx.pigeon)
  self.image = data.media.graphics.dinoland[self.gender].panic

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
  self.image = data.media.graphics.dinoland[self.gender].normal

  if self:inRange() then
    if self.walkTimer == 0 and self.reloadTimer == 0 then
      self.reloadTimer = lume.random(unpack(self.reloadRange))
    end
  else
    if self.walkTimer == 0 then
      self:hop(self.direction)
      self.walkTimer = lume.random(unpack(self.state.walkRate))
    end
  end
end
