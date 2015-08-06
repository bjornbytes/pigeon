Person = extend(Enemy)
Person.tag = 'person'

----------------
-- Core
----------------
function Person:activate()
  local widthRatio = self.image:getWidth() / self.image:getHeight()
  self.h = 35
  self.w = self.h * widthRatio
  self.scale = self.h / self.image:getHeight()
  self.alpha = 1

  self.body = love.physics.newBody(ctx.world, self.x - self.w / 2, self.y - self.h / 2, 'dynamic')
  self.shape = love.physics.newRectangleShape(self.w, self.h)
  self.fixture = love.physics.newFixture(self.body, self.shape)

  self.body:setUserData(self)
  self.body:setFixedRotation(true)

  self.fixture:setFriction(.75)
  self.fixture:setCategory(ctx.categories.person)

  self.phlerp = PhysicsInterpolator(self, 'alpha')

  self.screamed = false
  self.splatted = false

  ctx.event:emit('view.register', {object = self})

  Enemy.activate(self)
end

function Person:deactivate()
  self.body:destroy()
  ctx.event:emit('view.unregister', {object = self})
end

function Person:update()
  self.phlerp:update()

  self.invincible = timer.rot(self.invincible or 0)

  if self.state then
    self.state.update(self)
  end
end

function Person:draw()
  local g = love.graphics

  local lerpd = self.phlerp:lerp()
  local x, y, angle = self.body:getX(), self.body:getY(), self.body:getAngle()

  g.setColor(255, 255, 255, 255 * math.clamp(lerpd.alpha, 0, 1))
  g.draw(self.image, x, y, angle, self.scale * self.direction, self.scale, self.image:getWidth() / 2, self.image:getHeight() / 2)

  self.phlerp:delerp()
end

function Person:paused()
  self.phlerp:update()
end

function Person:collideWith(other)
  if other.tag == 'building' and not other.destroyed then
    return false
  elseif other.tag == 'platform' and self.body:getY() > other.body:getY() then
    return false
  elseif other.tag == 'person' then
    if self.state == self.dead then
      local vx, vy = self.body:getLinearVelocity()
      if math.distance(0, 0, vx, vy) > 820 and vy > 0 and other.state ~= other.dead then
        other:changeState('dead')
      end
    else
      return false
    end
  end

  if select(2, self.body:getLinearVelocity()) > 500 and self.state == self.dead then
    if not self.splatted then
      ctx.sound:play('splat', function(sound)
        sound:setPitch(.9 + love.math.random() * .2)
      end)
      ctx.particles:emit('blood', self.body:getX(), self.body:getY(), 8)
      self.splatted = true
      if self.screamSound then
        self.screamSound:stop()
      end
    end
  end

  return true
end

----------------
-- Helpers
----------------
function Person:hop(direction)
  self.body:applyLinearImpulse(30 * direction, -45)
end

function Person:directionTo(object)
  return lume.sign(object.body:getX() - self.body:getX())
end

function Person:distanceTo(object)
  return math.abs(object.body:getX() - self.body:getX())
end

function Person:changeState(target, ...)
  if self.state == target then return end
  f.exe(self.state.exit, self)
  self.state = self[target]
  f.exe(self.state.enter, self, ...)
  return self.state
end

----------------
-- Base States
----------------
Person.dead = {}
function Person.dead:enter(cause)
  ctx.hud.deathBulge = ctx.hud.deathBulge + 1
  self.body:setFixedRotation(false)
  self.fixture:setCategory(ctx.categories.debris)
  self.fixture:setFriction(0.25)
  self.body:applyLinearImpulse(-200 + love.math.random() * 400, -200 + love.math.random() * -500)
  self.body:setAngularVelocity(-20 + love.math.random() * 40)
  ctx.hud:addScore(10, 'person', cause)
  ctx.nonPeckKill = ctx.nonPeckKill or (cause ~= 'peck')
  ctx.stats.peopleKilled = ctx.stats.peopleKilled + 1
  if self:isMale() and love.math.random() < .75 then
    self.screamSound = ctx.sound:play('scream2', function(sound)
      sound:setVolume(.75)
      sound:setPitch(.8 + love.math.random() * .4)
    end)
    self.screamed = true
  elseif love.math.random() < .02 then
    self.screamSound = ctx.sound:play('wilhelm', function(sound)
      sound:setVolume(.75)
      sound:setPitch(.8 + love.math.random() * .4)
    end)
    self.screamed = true
  elseif love.math.random() < .1 then
    self.screamSound = ctx.sound:play('scream3', function(sound)
      sound:setVolume(.5)
      sound:setPitch(.8 + love.math.random() * .4)
    end)
    self.screamed = true
  elseif love.math.random() < .1 and self:isMale() then
    self.screamSound = ctx.sound:play('scream4', function(sound)
      sound:setVolume(.75)
      sound:setPitch(.8 + love.math.random() * .4)
    end)
    self.screamed = true
  elseif love.math.random() < .3 then
    self.screamSound = ctx.sound:play('scream5', function(sound)
      sound:setVolume(.75)
      sound:setPitch(.9 + love.math.random() * .2)
    end)
    self.screamed = true
  elseif love.math.random() < .3 and self.gender == 'female' then
    self.screamSound = ctx.sound:play('scream6', function(sound)
      sound:setVolume(.75)
      sound:setPitch(.9 + love.math.random() * .2)
    end)
    self.screamed = true
  elseif love.math.random() < .3 and self:isMale() then
    self.screamSound = ctx.sound:play('scream7', function(sound)
      sound:setVolume(.75)
      sound:setPitch(.9 + love.math.random() * .2)
    end)
    self.screamed = true
  elseif love.math.random() < .3 and self.gender == 'female' then
    self.screamSound = ctx.sound:play('scream8', function(sound)
      sound:setVolume(.75)
      sound:setPitch(.9 + love.math.random() * .2)
    end)
    self.screamed = true
  elseif love.math.random() < .3 and self:isMale() then
    self.screamSound = ctx.sound:play('scream9', function(sound)
      sound:setVolume(.75)
      sound:setPitch(.9 + love.math.random() * .2)
    end)
    self.screamed = true
  elseif love.math.random() < .01 and self:isMale()  then
    self.screamSound = ctx.sound:play('scream10', function(sound)
      sound:setVolume(1)
      sound:setPitch(.9 + love.math.random() * .2)
    end)
    self.screamed = true
  elseif love.math.random() < .3 and self:isMale() then
    self.screamSound = ctx.sound:play('scream11', function(sound)
      sound:setVolume(.75)
      sound:setPitch(.9 + love.math.random() * .2)
    end)
    self.screamed = true
  end

  ctx.particles:emit('blood', self.body:getX(), self.body:getY(), 4)
end

function Person.dead:update()
  local x, y = self.body:getLinearVelocity()
  if (math.abs(x) < 1 and math.abs(y) < 1) or (math.abs(x) > 2000 and math.abs(y) > 2000) then
    self.alpha = self.alpha - ls.tickrate
    if self.alpha <= 0 then
      ctx.enemies:remove(self)
    end
  end

  if y > 900 and not self.screamed then
    self.screamed = true
    self.screamSound = ctx.sound:play('scream1')
  end
end

function Person:isMale()
  return self.gender == 'male' or self.gender == 'wizard' or self.gender == 'knight'
end
