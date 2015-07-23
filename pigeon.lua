Pigeon = class()

----------------
-- Constants
----------------
Pigeon.walkForce = 600
Pigeon.maxSpeed = 350
Pigeon.jumpForce = 3000
Pigeon.rocketForce = 500
Pigeon.maxFlySpeed = 300
Pigeon.maxFuel = 50

----------------
-- Core
----------------
function Pigeon:init()
  self.shapeSize = 50
  self.body = love.physics.newBody(ctx.world, self.shapeSize / 2, ctx.map.height - ctx.map.ground.height - self.shapeSize / 2, 'dynamic')
  self.shape = love.physics.newRectangleShape(self.shapeSize, self.shapeSize)
  self.fixture = love.physics.newFixture(self.body, self.shape)

  self.body:setFixedRotation(true)
  self.body:setGravityScale(5)
  self.fixture:setCategory(ctx.categories.pigeon)
  self.fixture:setMask(ctx.categories.oneWayPlatform, ctx.categories.person, ctx.categories.debris)

  self.phlerp = PhysicsInterpolator(self.body)

  self.fuel = self.maxFuel
  self.state = self.idle

  self.animation = data.animation.pigeon()

  self.animation:on('complete', function(event)
    if event.state.name == 'jump' then
      self.animation:set('idle')
    end
  end)

  self.animation:on('event', function(event)
    local name = event.data.name
    if name == 'rightstep' then
      self.slide = 'left'
    elseif name == 'leftstep' then
      self.slide = 'right'
    elseif name == 'leftstop' or name == 'rightstop' then
      self.slide = nil
    end
  end)

  self.slide = nil
  self.slideSpeeds = {
    left = 693,
    right = 555
  }

  ctx.event:emit('view.register', {object = self})
end

function Pigeon:update()
  self.phlerp:update()

  self.grounded = self:getGrounded()
  self.state.update(self)
  self:contain()
end

function Pigeon:draw()
  local g = love.graphics
  self.phlerp:lerp()

  local points = {self.body:getWorldPoints(self.shape:getPoints())}
  g.setColor(255, 255, 255)
  --g.polygon('line', points)

  local x, y = self.body:getPosition()
  self.animation:draw(x, y + self.shapeSize / 2)

  local x1, y1, x2, y2 = self:getGroundRaycastPoints()
  g.setColor(self.grounded and {0, 255, 0} or {255, 0, 0})
  g.line(x1, y1, x2, y2)

  self.phlerp:delerp()
end

----------------
-- Helpers
----------------
function Pigeon:changeState(target)
  lume.call(self.state.exit, self)
  self.state = self[target]
  lume.call(self.state.enter, self)
  return self.state
end

function Pigeon:getGroundRaycastPoints()
  local x, y = self.body:getPosition()
  local h = self.shapeSize / 2
  local x1, y1, x2, y2 = x, y + h, x, y + h + 1
  return x1, y1, x2, y2
end

function Pigeon:getGrounded()
  local grounded = false
  local x1, y1, x2, y2 = self:getGroundRaycastPoints()
  ctx.world:rayCast(x1, y1, x2, y2, function(fixture)
    local categories = {fixture:getCategory()}
    if lume.find(categories, ctx.categories.ground) or lume.find(categories, ctx.categories.building) then
      grounded = true
    end
    return 1
  end)

  return grounded
end

----------------
-- Actions
----------------
function Pigeon:move()
  local left, right = love.keyboard.isDown('left'), love.keyboard.isDown('right')

  if left then
    --self.body:applyLinearImpulse(-self.walkForce, 0)
    self.animation.flipped = true

    if self.slide then
      self.body:setX(self.body:getX() - self.slideSpeeds[self.slide] * ls.tickrate * self.animation.state.speed * self.animation.scale)
    end
  elseif right then
    --self.body:applyLinearImpulse(self.walkForce, 0)
    self.animation.flipped = false

    if self.slide then
      self.body:setX(self.body:getX() + self.slideSpeeds[self.slide] * ls.tickrate * self.animation.state.speed * self.animation.scale)
    end
  end

  local vx, vy = self.body:getLinearVelocity()
  self.body:setLinearVelocity(math.min(math.abs(vx), self.maxSpeed) * lume.sign(vx), vy)
end

function Pigeon:jump()
  self.body:applyLinearImpulse(0, -self.jumpForce)
  self.animation:set('jump')
end

function Pigeon:recoverFuel()
  self.fuel = math.min(self.fuel + 20 * ls.tickrate, self.maxFuel)
end

function Pigeon:contain()
  if self.body:getX() < 0 then
    self.body:setPosition(0, self.body:getY())
  end
end

----------------
-- States
----------------
Pigeon.idle = {}
function Pigeon.idle:update()
  self:recoverFuel()
  self.animation:set('idle')

  if love.keyboard.isDown('left', 'right') then
    return self:changeState('walk').update(self)
  end

  if love.keyboard.isDown('up') then
    self:jump()
    self:changeState('air')
  else
    local vx, vy = self.body:getLinearVelocity()
    self.body:setLinearVelocity(vx / 1.2, vy)
  end
end

Pigeon.walk = {}
function Pigeon.walk:update()
  local left, right = love.keyboard.isDown('left'), love.keyboard.isDown('right')
  self.animation:set('walk')

  self:recoverFuel()

  if love.keyboard.isDown('up') then
    self:jump()
    return self:changeState('air')
  end

  if left or right then
    self:move()
  else
    return self:changeState('idle').update(self)
  end
end

Pigeon.air = {}
function Pigeon.air:update()
  local left, right = love.keyboard.isDown('left'), love.keyboard.isDown('right')
  local vx, vy = self.body:getLinearVelocity()

  if self.grounded then
    return self:changeState('idle').update(self)
  end

  if left or right then
    self:move()
  else
    self.body:setLinearVelocity(0, vy)
  end

  if love.keyboard.isDown(' ') then
    if self.fuel > 0 then
      if (vy > 0 or math.abs(vy) < self.maxFlySpeed) then
        self.fuel = math.max(self.fuel - 33 * ls.tickrate, 0)

        local bonusBoost = vy > 0 and vy / 2 or 0
        self.body:applyLinearImpulse(0, -(self.rocketForce + bonusBoost))
      end
    end
  end
end
