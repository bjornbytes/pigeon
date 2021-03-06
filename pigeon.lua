Pigeon = class()

----------------
-- Constants
----------------
Pigeon.walkForce = 600
Pigeon.maxSpeed = 350
Pigeon.jumpForce = 3000
Pigeon.flySpeed = 75
Pigeon.rocketForce = 500
Pigeon.maxFlySpeed = 300
Pigeon.maxFuel = 25
Pigeon.laserTurnSpeed = .75
Pigeon.laserChargeDuration = 2
Pigeon.rainbowShitThreshold = 50

----------------
-- Core
----------------
function Pigeon:init()
  self.shapeSize = 50
  self.body = love.physics.newBody(ctx.world, ctx.view.width / 2, ctx.map.height - ctx.map.ground.height - self.shapeSize / 2, 'dynamic')
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
      self.animation:set('walk')
    elseif event.state.name == 'peck' then
      self:changeState('walk')
    elseif event.state.name == 'laserStart' then
      self.animation:set('laserCharge')
    elseif event.state.name == 'laserEnd' then
      self:changeState('idle')
      self.laser.active = false
    elseif event.state.name == 'flyStart' then
      self.animation:set('fly')
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
        ctx.view:screenshake(10)
        self.stepsTaken = self.stepsTaken + 1

        local skeleton = self.animation.spine.skeleton
        local bone = skeleton:findBone('rightfoot')
        local x = skeleton.x + bone.worldX
        local y = skeleton.y + bone.worldY
        ctx.particles:emit('feetdust', x, y, 20)
      else
        self.walk.firstShake = false
      end

      if self.rightWhirr then
        self.rightWhirr:stop()
      end

      self.leftWhirr = ctx.sound:play('whirr', function(sound)
        sound:setVolume(.35)
        sound:setPitch(lume.random(.95, 1.05))
      end)

      ctx.sound:play('impact', function(sound)
        sound:setVolume(.5)
      end)

    elseif name == 'leftStep' then
      self.slide = 'left'
      self.drop = nil
      if self.walk.firstShake == false then
        ctx.view:screenshake(10)
        self.stepsTaken = self.stepsTaken + 1

        local skeleton = self.animation.spine.skeleton
        local bone = skeleton:findBone('leftfoot')
        local x = skeleton.x + bone.worldX
        local y = skeleton.y + bone.worldY
        ctx.particles:emit('feetdust', x, y, 20)
      else
        self.walk.firstShake = false
      end

      if self.leftWhirr then
        self.leftWhirr:stop()
      end

      self.rightWhirr = ctx.sound:play('whirr', function(sound)
        sound:setVolume(.35)
        sound:setPitch(lume.random(.95, 1.05))
      end)

      ctx.sound:play('impact', function(sound)
        sound:setVolume(.5)
      end)
    elseif name == 'leftStop' or name == 'rightStop' then
      self.slide = nil
    elseif name == 'jump' then
      ctx.sound:play('jump', function(sound)
        sound:setVolume(.35)
      end)
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

  self.leftWhirr = nil
  self.rightWhirr = nil

  self.drop = nil
  self.downDirty = 0
  self.crushGrace = 0
  self.rainbowShitSound = nil

  self.stepsTaken = 0
  self.jumps = 0
  self.pecks = 0
  self.rainbowShits = 0

  self.peckDirty = false

  self:initBeak()
  self:initFeet()

  self.rainbowShitTimer = 0


  ctx.event:emit('view.register', {object = self, depth = -10})
end

function Pigeon:update()
  self.phlerp:update()

  self.grounded = self:getGrounded()
  f.exe(self.state.update, self)
  self:contain()

  --self.animation.scale = self.rainbowShitTimer > 0 and 1 or .7
  self.rainbowShitTimer = timer.rot(self.rainbowShitTimer, function()
    ctx.backgroundSound:resume()
    self.rainbowShitSound:stop()
    flux.to(self.animation, .2, {scale = .7}, 'elasticout')
  end)

  if love.keyboard.isDown('down', 's') or (joystick and (joystick:getGamepadAxis('lefty') > .5 or (joystick:isGamepadDown('dpdown')))) then
    self.downDirty = timer.rot(self.downDirty)
  else
    self.downDirty = .1
  end

  local skeleton = self.animation.spine.skeleton
  skeleton.flipY = true
  skeleton:updateWorldTransform()
  local bone = skeleton:findBone('leftwing')
  local x, y = skeleton.x + bone.worldX, skeleton.y + bone.worldY
  local dir = (-bone.worldRotation * math.pi / 180) - .2
  x = x + math.cos(dir) * (bone.data.length + 100) * self.animation.scale
  y = y + math.sin(dir) * (bone.data.length + 100) * self.animation.scale
  ctx.particles:emit(self.rainbowShitTimer > 0 and 'rainbowshit' or 'smoke', x, y, 3, {direction = -bone.worldRotation * math.pi / 180})
  skeleton.flipY = false

  self.crushGrace = timer.rot(self.crushGrace)
  if not love.keyboard.isDown(' ') then
    self.peckDirty = false
  end

  self:updateBeak()
  self:updateFeet()

  if self.body:getX() > ctx.goal.x then
    if self.state ~= self.idle then
      self:changeState('idle')
    end
    self.animation:set('flyLoop')
    if not ctx.hud.win.active then
      ctx.hud:activateWin()
      ctx.sound:play('win')
      if not ctx.sound.muted then
        ctx.backgroundSound:setVolume(.1)
      end
    end
  end
end

function Pigeon:draw()
  local g = love.graphics
  self.phlerp:lerp()

  g.setColor(255, 255, 255)

  local x, y = self.body:getPosition()
  self.animation:draw(x, y + self.shapeSize / 2, {noupdate = ctx.paused})

  if ctx.debug then
    local x1, y1, x2, y2 = self:getGroundRaycastPoints()
    g.setColor(self.grounded and {0, 255, 0} or {255, 0, 0})
    g.line(x1, y1, x2, y2)
  end

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

function Pigeon:keypressed(key)
end

function Pigeon:paused()
  self.phlerp:update()
end

function Pigeon:collideWith(other, myFixture)
  if isa(other, Person) and other.state ~= other.dead and other.invincible == 0 then
    if self.state == self.peck and (myFixture == self.beak.top.fixture or myFixture == self.beak.bottom.fixture) then
      other:changeState('dead', 'peck')
    elseif self.state == self.walk and self.drop and myFixture == self.feet[self.drop].fixture then
      other:changeState('dead', 'step')
    elseif self.crushGrace > 0 and (myFixture == self.feet.left.fixture or myFixture == self.feet.right.fixture) then
      other:changeState('dead', 'jump')
    end
  elseif isa(other, Building) and not other.destroyed and self.state == self.peck and (myFixture == self.beak.top.fixture or myFixture == self.beak.bottom.fixture) then
    other:destroy('peck')
  elseif isa(other, Building) and not other.destroyed and self.crushGrace > 0 and (myFixture == self.feet.left.fixture or myFixture == self.feet.right.fixture) then
    other:destroy('step')
  end

  if isa(other, Building) then return false end

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

function Pigeon:getLaserLength()
  local x1, y1, x2, y2 = self:getLaserRaycastPoints()
  local minLen = 1
  ctx.world:rayCast(x1, y1, x2, y2, function(fixture, len)
    local categories = {fixture:getCategory()}
    if lume.find(categories, ctx.categories.ground) or lume.find(categories, ctx.categories.building) then
      minLen = math.min(minLen, len)
    end
    return 1
  end)
  return minLen * math.distance(x1, y1, x2, y2)
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

function Pigeon:activateRainbowShit()
  self.rainbowShitTimer = 5--self.rainbowShitTimer + 5
  self.rainbowShits = self.rainbowShits + 1
  ctx.backgroundSound:pause()
  if not self.rainbowShitSound or self.rainbowShitSound:isStopped() then
    self.rainbowShitSound = ctx.sound:loop('disco', function(sound)
      sound:setVolume(1)
    end)
  end
  flux.to(self.animation, .2, {scale = 1}, 'elasticout')
end

----------------
-- Actions
----------------
function Pigeon:move()
  if ctx.debug then return end
  local left, right = false, true

  if left then
    self.animation.flipped = true

    if self.state == self.walk and self.slide then
      self.body:setX(self.body:getX() - self.slideSpeeds[self.slide] * ls.tickrate * (self.animation.state.speed or 1) * self.animation.scale * self.animation.speed)
    elseif not self.grounded then
      self.body:applyLinearImpulse(-self.flySpeed, 0)
    end
  elseif right then
    self.animation.flipped = false

    if self.state == self.walk and self.slide then
      self.body:setX(self.body:getX() + self.slideSpeeds[self.slide] * ls.tickrate * (self.animation.state.speed or 1) * self.animation.scale * self.animation.speed)
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
end

Pigeon.walk = {}
function Pigeon.walk:enter()
  self.walk.firstShake = true
end

function Pigeon.walk:update()
  local left, right = false, true
  self.animation:set('walk')

  self:recoverFuel()

  if love.keyboard.isDown('up', 'w', 'z') or (joystick and (joystick:getGamepadAxis('lefty') < -.5 or joystick:isGamepadDown('a', 'dpup'))) then
    return self:changeState('air')
  elseif (love.keyboard.isDown(' ', 's', 'x') or (joystick and (joystick:isGamepadDown('b', 'x', 'y')))) and not self.peckDirty then
    self:changeState('peck')
  end

  if not self.grounded then
    self.crushGrace = .1
  end

  if left or right then
    self:move()
  end
end

Pigeon.air = {}
function Pigeon.air:enter()
  if self.leftWhirr then
    self.leftWhirr:stop()
    self.rightWhirr:stop()
  end
  self.jumped = false
  if love.keyboard.isDown('up', 'w', 'z') or (joystick and (joystick:getGamepadAxis('lefty') < -.5 or joystick:isGamepadDown('a', 'dpup'))) then
    self.animation:set('jump')
  end
  self.jumps = self.jumps + 1
  self.air.lastVelocity = 0
end

function Pigeon.air:exit()
  if self.air.lastVelocity > 800 then
    ctx.view:screenshake(15 + (self.air.lastVelocity / 50))
    local skeleton = self.animation.spine.skeleton
    local x = skeleton.x
    local y = skeleton.y
    ctx.particles:emit('dust', x, y, 15 + (self.air.lastVelocity / 100))
  end
  ctx.sound:play('impact', function(sound)
    sound:setVolume(1)
  end)
end

function Pigeon.air:update()
  local left, right = false, true
  local vx, vy = self.body:getLinearVelocity()

  if vy > 0 then
    self.crushGrace = .1
  end

  if self.jumped and self.grounded and vy >= 0 then
    return self:changeState('walk').update(self)
  end

  if left or right then
    self:move()
  else
    self.body:setLinearVelocity(0, vy)
  end

  --[[if love.keyboard.isDown(' ') then
    if self.fuel > 0 and not self.grounded then
      if (vy > 0 or math.abs(vy) < self.maxFlySpeed) then
        self.fuel = math.max(self.fuel - 33 * ls.tickrate, 0)

        local bonusBoost = vy > 0 and vy / 2 or 0
        self.body:applyLinearImpulse(0, -(self.rocketForce + bonusBoost))
      end

      if self.animation.state.name ~= 'fly' and self.animation.state.name ~= 'flyStart' then
        self.animation:set('flyStart')
      end

      self.jumped = true
    end
  end]]

  if (self.animation.state.name == 'fly' or self.animation.state.name == 'flyStart') and (not love.keyboard.isDown(' ') or self.fuel < 1) then
    self.animation:set('flyEnd')
  end

  self.air.lastVelocity = vy
end

Pigeon.peck = {}
function Pigeon.peck:enter()
  if self.leftWhirr then
    self.leftWhirr:stop()
    self.rightWhirr:stop()
  end
  self.pecks = self.pecks + 1
  ctx.sound:play('charge')
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
  ctx.sound:play('impact')
  ctx.sound:play('crash', function(sound)
    sound:setVolume(.1)
  end)
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
    local dis, dir = math.vector(x1, y1, x2, y2)
    local len = dis
    ctx.world:rayCast(x1, y1, x2, y2, function(fixture, x, y, xn, yn, f)
      if lume.find({fixture:getCategory()}, ctx.categories.ground) then
        len = math.min(len, dis * f)
        return len
      end
      return 1
    end)

    ctx.world:rayCast(x1, y1, x1 + math.cos(dir) * len, y1 + math.sin(dir) * len, function(fixture)
      local object = fixture:getBody():getUserData()
      if object and isa(object, Person) and object.state ~= object.dead then
        object:changeState('dead')
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
