Building = class()

Building.size = 60

function Building:activate()
  self.image = data.media.graphics.dinoland['hut' .. love.math.random(1, 2)]
  self.alpha = 1

  self.personTimer = 6 + love.math.random() * 3
  self.destroyed = false
  self.justDestroyed = false

  self.body = love.physics.newBody(ctx.world, self.x, self.y - self.size / 2, 'dynamic')
  self.shape = love.physics.newRectangleShape(self.size, self.size)
  self.fixture = love.physics.newFixture(self.body, self.shape)

  self.body:setUserData(self)
  self.body:setFixedRotation(true)

  self.fixture:setCategory(ctx.categories.building)
  --self.fixture:setMask(ctx.categories.person, ctx.categories.building, ctx.categories.debris)

  self.phlerp = PhysicsInterpolator(self, 'alpha')

  ctx.event:emit('view.register', {object = self})
end

function Building:deactivate()
  self.body:destroy()
  ctx.event:emit('view.unregister', {object = self})
end

function Building:update()
  self.phlerp:update()

  self.personTimer = timer.rot(self.personTimer, function()
    --ctx.enemies:add(Caveman, {x = self.x, y = self.y - 20})
    return 6 + love.math.random() * 3
  end)

  if self.justDestroyed then
    for i = 1, 6 do
      ctx.enemies:add(Caveman, {x = self.x - self.size / 2 + self.size * love.math.random(), y = self.y, invincible = 1, state = Caveman.panic})
    end

    self.justDestroyed = false
  end

  if self.destroyed then
    local x, y = self.body:getLinearVelocity()
    if (math.abs(x) < 1 and math.abs(y) < 1) or (math.abs(x) > 2000 and math.abs(y) > 2000) then
      self.alpha = timer.rot(self.alpha)
      if self.alpha < 0 then
        ctx.buildings:remove(self)
      end
    end
  end
end

function Building:draw()
  local g = love.graphics
  local scale = self.size / self.image:getWidth()

  local lerpd = self.phlerp:lerp()
  local x, y = self.body:getPosition()
  local angle = self.body:getAngle()
  g.setColor(255, 255, 255, 255 * math.clamp(lerpd.alpha, 0, 1))
  g.draw(self.image, x, y, angle, scale, scale, self.image:getWidth() / 2, self.image:getHeight() / 2)

  self.phlerp:delerp()
end

function Building:collideWith(other)
  if other.tag == 'platform' and self.body:getY() > other.body:getY() then
    return false
  end

  if isa(other, Person) and other.state ~= other.dead and self.destroyed and select(2, self.body:getLinearVelocity()) > 30 then
    other:changeState('dead')
  end

  return true
end

function Building:destroy()
  if self.destroyed then return end
  self.destroyed = true
  self.justDestroyed = true
  self.body:setFixedRotation(false)
  self.fixture:setCategory(ctx.categories.debris)
  self.fixture:setFriction(0.25)
  self.body:applyLinearImpulse(-400 + love.math.random() * 600, -2000 + love.math.random() * -2000)
  self.body:setAngularVelocity(-20 + love.math.random() * 40)
  ctx.hud:addScore(50)
end
