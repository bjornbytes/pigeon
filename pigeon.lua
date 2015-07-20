Pigeon = class()

function Pigeon:init()
  self.x = 0
  self.y = 500
  self.prevx = self.x
  self.prevy = self.y

  self.scale = .3
  self.speed = 200

  self.laser = {
    active = false,
    length = 0,
    angle = 0,
    speed = .2,
    tween = nil
  }

  self.lives = 3
  self.health = 100
  self.maxHealth = 100

  self.animation = data.animation.pigeon()
  self.animation:set('idle')

  self.animation:on('complete', function(event)
    if event.state.name == 'peck' then
      self.animation:set('idle', {force = true})
    end
  end)

  self.animation.spine.skeleton:setToSetupPose()

  ctx.view.target = self

  ctx.event:emit('view.register', {object = self})
end

function Pigeon:update()
  self.prevx = self.x
  self.prevy = self.y

  -- Movement
  self:move()

  -- Laser
  self:updateLaser()

  -- Pecking
  if not self.laser.active and love.keyboard.isDown('down') then self.animation:set('peck') end
  if self.animation.state.name == 'peck' then
    self:killThingsOnBeak()
  end

  -- Death
  if self.health < 0 then
    if self.lives == 0 then
      print('you lose')
      love.event.quit()
      return
    end

    self.health = self.maxHealth
    self.lives = self.lives - 1
    flux.to(self.animation, .6, {scale = self.animation.scale / 2}):ease('elasticin')
  end
end

function Pigeon:draw()
  local g = love.graphics
  local x = lume.lerp(self.prevx, self.x, ls.accum / ls.tickrate)
  local y = lume.lerp(self.prevy, self.y, ls.accum / ls.tickrate)

  if self.laser.active then
    local x2, y2 = x + math.cos(self.laser.angle) * self.laser.length, y + math.sin(self.laser.angle) * self.laser.length

    g.setColor(255, 0, 0)
    g.line(x, y, x2, y2)
  end

  self.animation:draw(x, y)
end

function Pigeon:move()
  if not self.laser.active then
    if self.animation.state.name ~= 'peck' then
      if love.keyboard.isDown('left') then
        self.x = self.x - self.speed * ls.tickrate
        self.animation.flipped = true
      elseif love.keyboard.isDown('right') then
        self.x = self.x + self.speed * ls.tickrate
        self.animation.flipped = false
      end
    end
  end
end

function Pigeon:updateLaser()
  self.laser.active = love.keyboard.isDown(' ')

  if self.laser.active then
    self.laser.tween = flux.to(self.laser, 1, {length = 1000}):ease('expoout')

    if self.laser.length == 0 then
      self.laser.angle = self.animation.flipped and math.pi or 0
    else
      local x1, y1 = self.x, self.y
      local x2, y2 = self.x + math.cos(self.laser.angle) * self.laser.length, self.y + math.sin(self.laser.angle) * self.laser.length

      ctx.world:rayCast(x1, y1, x2, y2, function(fixture)
        local person = fixture:getBody():getUserData()
        if person and not person.dead and person.die then
          self:kill(person)
          return 1
        end
        return -1
      end)
    end

    local diff = self.laser.speed * ls.tickrate * lume.sign(math.pi / 2 - self.laser.angle)
    if love.keyboard.isDown('up') then
      self.laser.angle = self.laser.angle - diff
    elseif love.keyboard.isDown('down') then
      self.laser.angle = self.laser.angle + diff
    end
  else
    if self.laser.tween then
      self.laser.tween:stop()
      self.laser.length = 0
    end
  end
end

function Pigeon:kill(person)
  if person and not person.dead then
    person:die()
    self.health = math.min(self.health + 15, self.maxHealth)
    flux.to(self.animation, .6, {scale = self.animation.scale + .02}):ease('elasticout')
  end
end

-- Kill everything near the beak. Uses very dumb AABB checking but can be improved.
function Pigeon:killThingsOnBeak()
  local spine = self.animation.spine

  spine.skeleton.flipY = true
  spine.skeleton:updateWorldTransform()
  spine.skeletonBounds:update(spine.skeleton)
  spine.skeleton.flipY = false

  for _, slotName in pairs({'beakbottom', 'beaktop'}) do
    local beakSlot = spine.skeleton:findSlot(slotName)
    local beakAttachment = spine.skeleton:getAttachment(beakSlot.data.name, beakSlot.data.name .. '_bb')
    if beakAttachment then
      local polygon = spine.skeletonBounds:getPolygon(beakAttachment)

      if polygon then
        local x1, y1, x2, y2
        for i = 1, #polygon, 2 do
          x1 = math.min(x1 or math.huge, polygon[i])
          x2 = math.max(x2 or -math.huge, polygon[i])
          y1 = math.min(y1 or math.huge, polygon[i + 1])
          y2 = math.max(y2 or -math.huge, polygon[i + 1])
        end

        ctx.world:queryBoundingBox(x1, y1, x2, y2, function(fixture)
          local person = fixture:getBody():getUserData()
          if person and person.die then
            self:kill(person)
            return true
          end
        end)
      end
    end
  end
end
