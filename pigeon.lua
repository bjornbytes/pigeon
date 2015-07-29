Pigeon = class()

----------------
-- Constants
----------------
Pigeon.walkForce = 600
Pigeon.maxSpeed = 350
Pigeon.jumpForce = 3000
Pigeon.flySpeed = 100
Pigeon.rocketForce = 500
Pigeon.maxFlySpeed = 300
Pigeon.maxFuel = 25
Pigeon.laserTurnSpeed = .75
Pigeon.laserChargeDuration = 2

----------------
-- Core
----------------
function Pigeon:init()
  self.shapeSize = 50
  self.body = love.physics.newBody(ctx.world, 100, ctx.map.height - ctx.map.ground.height - self.shapeSize / 2, 'dynamic')
  self.shape = love.physics.newRectangleShape(self.shapeSize, self.shapeSize)
  self.fixture = love.physics.newFixture(self.body, self.shape)

  self.body:setFixedRotation(true)
  self.body:setGravityScale(5)
  self.body:setUserData(self)
  self.fixture:setCategory(ctx.categories.pigeon)
  self.fixture:setMask(ctx.categories.oneWayPlatform, ctx.categories.person, ctx.categories.debris)

  self.phlerp = PhysicsInterpolator(self)

  self.fuel = self.maxFuel
  self.state = self.idle

  self.animation = data.animation.pigeon()

  self.animation:on('complete', function(event)
    if event.state.name == 'jump' then
      self.animation:set('idle')
    elseif event.state.name == 'peck' then
      self:changeState('idle')
    elseif event.state.name == 'laserStart' then
      self.animation:set('laserCharge')
    elseif event.state.name == 'laserEnd' then
      self:changeState('idle')
      self.laser.active = false
    end
  end)

  self.animation:on('event', function(event)
    local name = event.data.name
    if name == 'rightDrop' then
      self.drop = 'right'
    elseif name == 'leftDrop' then
      self.drop = 'left'
    elseif name == 'rightStep' then
      self.slide = 'right'
      self.drop = nil
      if self.walk.firstShake == false then
        ctx.view:screenshake(6)
      else
        self.walk.firstShake = false
      end
    elseif name == 'leftStep' then
      self.slide = 'left'
      self.drop = nil
      if self.walk.firstShake == false then
        ctx.view:screenshake(6)
      else
        self.walk.firstShake = false
      end
    elseif name == 'leftStop' or name == 'rightStop' then
      self.slide = nil
    elseif name == 'jump' then
      self:jump()
    elseif name == 'laser' then
      self.laser.active = true
    elseif name == 'peck' and self.state == self.peck then
      self.peck.impact(self)
    end
  end)

  self.slide = nil
  self.slideSpeeds = {
    left = 693,
    right = 555
  }

  self.drop = nil

  self:initBeak()
  self:initFeet()

  ctx.event:emit('view.register', {object = self})
end

function Pigeon:update()
  self.phlerp:update()

  self.grounded = self:getGrounded()
  f.exe(self.state.update, self)
  self:contain()

  self:updateBeak()
  self:updateFeet()
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

  if ctx.debug then
    g.setColor(255, 255, 255)
    local points = {self.feet.left.body:getWorldPoints(self.feet.left.shape:getPoints())}
    g.polygon('line', points)
    local points = {self.feet.right.body:getWorldPoints(self.feet.right.shape:getPoints())}
    g.polygon('line', points)
    local points = {self.beak.top.body:getWorldPoints(self.beak.top.shape:getPoints())}
    g.polygon('line', points)
    local points = {self.beak.bottom.body:getWorldPoints(self.beak.bottom.shape:getPoints())}
    g.polygon('line', points)
  end

  if self.state == self.laser then
    local x1, y1, x2, y2 = self:getLaserRaycastPoints()
    local dis, dir = math.vector(x1, y1, x2, y2)
    local len = dis
    ctx.world:rayCast(x1, y1, x2, y2, function(fixture, x, y, xn, yn, f)
      if lume.find({fixture:getCategory()}, ctx.categories.ground) then
        len = math.min(len, dis * f)
        return len
      end
      return 1
    end)
    g.setColor(255, 0, 0)
    g.setLineWidth(self.laser.active and 10 or 1)
    g.line(x1, y1, x1 + len * math.cos(dir), y1 + len * math.sin(dir))
    g.setLineWidth(1)
  end

  self.phlerp:delerp()
end

function Pigeon:collideWith(other, myFixture)
  if isa(other, Person) and other.state ~= other.dead then
    if self.state == self.peck and (myFixture == self.beak.top.fixture or myFixture == self.beak.bottom.fixture) then
      other:changeState('dead')
    elseif self.state == self.walk and self.drop and myFixture == self.feet[self.drop].fixture then
      other:changeState('dead')
    elseif self.state == self.air and select(2, self.body:getLinearVelocity()) > 0 and (myFixture == self.feet.left.fixture or myFixture == self.feet.right.fixture) then
      other:changeState('dead')
    end
  end

  return true
end

----------------
-- Helpers
----------------
function Pigeon:changeState(target)
  print('changing state to ' .. target)
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

function Pigeon:getLaserRaycastPoints()
  local x1, y1 = self.animation.spine.skeleton.x + self.animation.spine.skeleton:findBone('beakbottom').worldX, self.animation.spine.skeleton.y - self.animation.spine.skeleton:findBone('beakbottom').worldY
  local dir = self.laser.direction
  local x2, y2 = x1 + math.cos(dir) * 2000, y1 + math.sin(dir) * 2000
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
      polygon[i + 1] = polygon[i + 1] * self.animation.scale * -1
    end
    beak.shape = love.physics.newPolygonShape(unpack(polygon))
    beak.body = love.physics.newBody(ctx.world, 0, 0, 'kinematic')
    beak.fixture = love.physics.newFixture(beak.body, beak.shape)
    beak.fixture:setCategory(ctx.categories.pigeon)
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
    beak.body:setAngle(math.rad(bone.worldRotation * (self.animation.flipped and 1 or -1) + (self.animation.flipped and 180 or 0)))

    slot:setAttachment(skeleton:getAttachment(slot.data.name, slot.data.name))
  end)

  skeleton.flipY = false
end

function Pigeon:initFeet()
  local spine = self.animation.spine

  self.feet = {}

  table.each({'left', 'right'}, function(name)
    local foot = {}

    local attachment = spine.skeleton:getAttachment(name .. 'foot_bb', name .. 'foot_bb')
    local polygon = table.copy(attachment.vertices)
    for i = 1, #polygon, 2 do
      polygon[i] = polygon[i] * self.animation.scale
      polygon[i + 1] = polygon[i + 1] * self.animation.scale * -1
    end
    foot.shape = love.physics.newPolygonShape(unpack(polygon))
    foot.body = love.physics.newBody(ctx.world, 0, 0, 'kinematic')
    foot.fixture = love.physics.newFixture(foot.body, foot.shape)
    foot.fixture:setCategory(ctx.categories.pigeon)
    foot.fixture:setSensor(true)
    foot.body:setUserData(self)

    self.feet[name] = foot
  end)
end

function Pigeon:updateFeet()
  local skeleton = self.animation.spine.skeleton

  skeleton.flipY = true
  skeleton:updateWorldTransform()

  table.each(self.feet, function(foot, name)
    local slot = skeleton:findSlot(name .. 'foot')
    slot:setAttachment(skeleton:getAttachment(slot.data.name, slot.data.name .. '_bb'))

    local bone = skeleton:findBone(name .. 'foot')
    foot.body:setX(skeleton.x + bone.worldX)
    foot.body:setY(skeleton.y + bone.worldY)
    foot.body:setAngle(math.rad(bone.worldRotation * (self.animation.flipped and 1 or -1) + (self.animation.flipped and 180 or 0)))

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

    if self.state == self.walk and self.slide then
      self.body:setX(self.body:getX() - self.slideSpeeds[self.slide] * ls.tickrate * (self.animation.state.speed or 1) * self.animation.scale)
    elseif not self.grounded then
      self.body:applyLinearImpulse(-self.flySpeed, 0)
    end
  elseif right then
    self.animation.flipped = false

    if self.state == self.walk and self.slide then
      self.body:setX(self.body:getX() + self.slideSpeeds[self.slide] * ls.tickrate * (self.animation.state.speed or 1) * self.animation.scale)
    elseif not self.grounded then
      self.body:applyLinearImpulse(self.flySpeed, 0)
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
  elseif love.keyboard.isDown(' ') then
    self:changeState('laser')
  else
    local vx, vy = self.body:getLinearVelocity()
    self.body:setLinearVelocity(vx / 1.2, vy)
  end
end

Pigeon.walk = {}
function Pigeon.walk:enter()
  self.walk.firstShake = true
end

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
  elseif love.keyboard.isDown(' ') then
    self:changeState('laser')
  else
    return self:changeState('idle').update(self)
  end
end

Pigeon.air = {}
function Pigeon.air:enter()
  self.jumped = false
  self.animation:set('jump')
  self.air.lastVelocity = 0
end

function Pigeon.air:exit()
  if self.air.lastVelocity > 800 then
    ctx.view:screenshake(15 + (self.air.lastVelocity / 100))
  end
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
    if self.fuel > 0 and not self.grounded then
      if (vy > 0 or math.abs(vy) < self.maxFlySpeed) then
        self.fuel = math.max(self.fuel - 33 * ls.tickrate, 0)

        local bonusBoost = vy > 0 and vy / 2 or 0
        self.body:applyLinearImpulse(0, -(self.rocketForce + bonusBoost))
      end

      self.animation:set('fly')
      self.jumped = true
    end
  end

  if self.animation.state.name == 'fly' and (not love.keyboard.isDown(' ') or self.fuel < 1) then
    self.animation:set('flyEnd')
  end

  self.air.lastVelocity = vy
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
  ctx.view:screenshake(20)
end

Pigeon.laser = {}
function Pigeon.laser:enter()
  self.laser.active = false
  self.laser.direction = self.animation.flipped and 3 * math.pi / 4 or math.pi / 4
  self.animation:set('laserStart')
end

function Pigeon.laser:update()
  if not self.laser.active then

    if love.keyboard.isDown('up', 'right') then
      self.laser.direction = self.laser.direction - self.laserTurnSpeed * ls.tickrate * math.sign(math.pi / 2 - self.laser.direction)
    elseif love.keyboard.isDown('down', 'left') then
      self.laser.direction = self.laser.direction + self.laserTurnSpeed * ls.tickrate * math.sign(math.pi / 2 - self.laser.direction)
    end

    if not love.keyboard.isDown(' ') or self.animation.state.name == 'laserCharge' then
      if self.animation.state.name == 'laserCharge' or self.animation.state.name == 'laserEnd' then
        self.animation:set('laserEnd')
      else
        self:changeState('idle')
      end
    end
  else
    local x1, y1, x2, y2 = self:getLaserRaycastPoints()
    local dis = math.distance(x1, y1, x2, y2)
    ctx.world:rayCast(x1, y1, x2, y2, function(fixture, x, y, xn, yn, fraction)
      local object = fixture:getBody():getUserData()
      if object and isa(object, Person) and object.state ~= object.dead then
        object:changeState('dead')
        return -1
      elseif lume.find({fixture:getCategory()}, ctx.categories.ground) then
        return fraction * dis
      end

      return 1
    end)

    if love.keyboard.isDown('up', 'right') then
      self.laser.direction = self.laser.direction - self.laserTurnSpeed * ls.tickrate * math.sign(math.pi / 2 - self.laser.direction) * .2
    elseif love.keyboard.isDown('down', 'left') then
      self.laser.direction = self.laser.direction + self.laserTurnSpeed * ls.tickrate * math.sign(math.pi / 2 - self.laser.direction) * .2
    end
  end
end

