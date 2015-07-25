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
  self.body:setUserData(self)
  self.fixture:setCategory(ctx.categories.pigeon)
  self.fixture:setMask(ctx.categories.oneWayPlatform, ctx.categories.person, ctx.categories.debris)

  self.phlerp = PhysicsInterpolator(self.body)

  self.fuel = self.maxFuel
  self.state = self.idle

  self.animation = data.animation.pigeon()

  self.animation:on('complete', function(event)
    if event.state.name == 'jump' then
      self.animation:set('idle')
    elseif event.state.name == 'peck' then
      self:changeState('idle')
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
    elseif name == 'jump' then
      self:jump()
    elseif name == 'peck' and self.state == self.peck then
      self.peck.impact(self)
    end
  end)

  self.slide = nil
  self.slideSpeeds = {
    left = 693,
    right = 555
  }

  self:initBeak()

  ctx.event:emit('view.register', {object = self})
end

function Pigeon:update()
  self.phlerp:update()

  self.grounded = self:getGrounded()
  f.exe(self.state.update, self)
  self:contain()

  self:updateBeak()
end

function Pigeon:draw()
  local g = love.graphics
  self.phlerp:lerp()

  g.setColor(255, 255, 255)

  local x, y = self.body:getPosition()
  self.animation:draw(x, y + self.shapeSize / 2)

  local x1, y1, x2, y2 = self:getGroundRaycastPoints()
  g.setColor(self.grounded and {0, 255, 0} or {255, 0, 0})
  g.line(x1, y1, x2, y2)

  local points = {self.beak.bottom.body:getWorldPoints(self.beak.bottom.shape:getPoints())}
  g.setColor(255, 255, 255)
  g.polygon('line', points)
  local points = {self.beak.top.body:getWorldPoints(self.beak.top.shape:getPoints())}
  g.polygon('line', points)

  self.phlerp:delerp()
end

function Pigeon:collideWith(other, myFixture)
  if isa(other, Person) then
    if self.state == self.peck and (myFixture == self.beak.top.fixture or myFixture == self.beak.bottom.fixture) and other.state ~= other.dead then
      other:changeState('dead')
    end
  end
end

----------------
-- Helpers
----------------
function Pigeon:changeState(target)
  if self.state == target then return end
  f.exe(self.state.exit, self)
  self.state = self[target]
  f.exe(self.state.enter, self)
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

function Pigeon:initBeak()
  local spine = self.animation.spine

  self.beak = {}

  table.each({'top', 'bottom'}, function(name)
    local beak = {}

    local attachment = spine.skeleton:getAttachment('beak' .. name .. '_bb', 'beak' .. name .. '_bb')
    local polygon = table.copy(attachment.vertices)
    for i = 1, #polygon, 2 do
      polygon[i] = polygon[i] * self.animation.scale
      polygon[i + 1] = polygon[i + 1] * self.animation.scale
    end
    beak.shape = love.physics.newPolygonShape(unpack(polygon))
    beak.body = love.physics.newBody(ctx.world, 0, 0)
    beak.fixture = love.physics.newFixture(beak.body, beak.shape)
    beak.fixture:setSensor(true)
    beak.body:setUserData(self)

    self.beak[name] = beak
  end)
end

function Pigeon:updateBeak()
  local skeleton = self.animation.spine.skeleton

  skeleton.flipY = true
  skeleton:updateWorldTransform()

  table.each(self.beak, function(beak, name)
    local slot = skeleton:findSlot('beak' .. name)
    slot:setAttachment(skeleton:getAttachment(slot.data.name, slot.data.name .. '_bb'))

    local bone = skeleton:findBone('beak' .. name)
    beak.body:setX(skeleton.x + bone.worldX)
    beak.body:setY(skeleton.y + bone.worldY)
    beak.body:setAngle(math.rad(-bone.worldRotation))

    slot:setAttachment(skeleton:getAttachment(slot.data.name, slot.data.name))
  end)

  skeleton.flipY = false
end

----------------
-- Actions
----------------
function Pigeon:move()
  local left, right = love.keyboard.isDown('left'), love.keyboard.isDown('right')

  if left then
    self.animation.flipped = true

    if self.slide then
      self.body:setX(self.body:getX() - self.slideSpeeds[self.slide] * ls.tickrate * (self.animation.state.speed or 1) * self.animation.scale)
    end
  elseif right then
    self.animation.flipped = false

    if self.slide then
      self.body:setX(self.body:getX() + self.slideSpeeds[self.slide] * ls.tickrate * (self.animation.state.speed or 1) * self.animation.scale)
    end
  end

  local vx, vy = self.body:getLinearVelocity()
  self.body:setLinearVelocity(math.min(math.abs(vx), self.maxSpeed) * lume.sign(vx), vy)
end

function Pigeon:jump()
  if not self.jumped then
    self.body:applyLinearImpulse(0, -self.jumpForce)
    self.jumped = true
  end
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
    self:changeState('air')
  elseif love.keyboard.isDown('down') then
    self:changeState('peck')
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
    return self:changeState('air')
  elseif love.keyboard.isDown('down') then
    self:changeState('peck')
  end

  if left or right then
    self:move()
  else
    return self:changeState('idle').update(self)
  end
end

Pigeon.air = {}
function Pigeon.air:enter()
  self.jumped = false
  self.animation:set('jump')
end

function Pigeon.air:update()
  local left, right = love.keyboard.isDown('left'), love.keyboard.isDown('right')
  local vx, vy = self.body:getLinearVelocity()

  if self.jumped and self.grounded and vy >= 0 then
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

Pigeon.peck = {}
function Pigeon.peck:enter()
  self.animation:set('peck')
  table.each(self.beak, function(beak)
    beak.fixture:setSensor(false)
  end)
end

function Pigeon.peck:exit()
  table.each(self.beak, function(beak)
    beak.fixture:setSensor(true)
  end)
end

function Pigeon.peck:impact()
  local skeleton = self.animation.spine.skeleton

  table.each(self.beak, function(beak, name)
    --
  end)
end
