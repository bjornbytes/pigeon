Spear = extend(Projectile)

Spear.scale = .3

function Spear:activate()
  self.body = love.physics.newBody(ctx.world, self.x, self.y, 'dynamic')
  self.shape = love.physics.newCircleShape(10)
  self.fixture = love.physics.newFixture(self.body, self.shape)
  self.fixture:setCategory(6)

  self.body:setUserData(self)

  self.body:applyLinearImpulse((100 + love.math.random() * 100) * self.direction, -100 - love.math.random() * 100)

  self.prevx = self.x
  self.prevy = self.y

  ctx.event:emit('view.register', {object = self})
end

function Spear:deactivate()
  self.body:destroy()
  ctx.event:emit('view.unregister', {object = self})
end

function Spear:update()
  self.prevx = self.body:getX()
  self.prevy = self.body:getY()
end

function Spear:draw()
  local g = love.graphics
  local image = data.media.graphics.dinoland.spear
  local x = math.lerp(self.prevx, self.body:getX(), ls.accum / ls.tickrate)
  local y = math.lerp(self.prevy, self.body:getY(), ls.accum / ls.tickrate)
  local angle = math.direction(self.prevx, self.prevy, self.body:getPosition())

  g.setColor(255, 255, 255)
  g.draw(image, x, y, angle, self.scale / 2, self.scale, image:getWidth(), image:getHeight() / 2)
end

function Spear:collideWith(other)
  if isa(other, Map) or other.tag == 'platform' then
    ctx.projectiles:remove(self)
  end
end
