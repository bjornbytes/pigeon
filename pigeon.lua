Pigeon = class()

function Pigeon:init()
  self.x = 0
  self.y = 500
  self.prevx = self.x
  self.prevy = self.y
  self.w = 20
  self.h = 40
  self.speed = 200
  self.direction = {x = 1, y = 0}
  self.targetDirection = {x = 1, y = 0}
  self.laser = false
  self.laserLength = 0

  self.gravity = 0--180
  self.jumpspeed = 120
  self.vy = 0

  self.lives = 3
  self.health = 100
  self.maxHealth = 100

  self.animation = data.animation.pigeon()
end

function Pigeon:update()
  self.prevx = self.x
  self.prevy = self.y

  -- Movement
  do
    if love.keyboard.isDown('left') then
      self.x = self.x - self.speed * ls.tickrate
      self.targetDirection.x = -1
    elseif love.keyboard.isDown('right') then
      self.x = self.x + self.speed * ls.tickrate
      self.targetDirection.x = 1
    end

    if love.keyboard.isDown('up') then
      self.targetDirection.y = -1
    elseif love.keyboard.isDown('down') then
      self.targetDirection.y = 1
    else
      self.targetDirection.y = 0
    end

    flux.to(self.direction, .4, self.targetDirection):ease('expoout')

    self.vy = self.vy + self.gravity * ls.tickrate
    self.y = self.y + self.vy * ls.tickrate

    if self.y + self.h / 2 > 600 then
      self.vy = math.abs(self.vy) * -1
    end
  end

  local kills = 0

  -- Laser
  do
    self.laser = love.keyboard.isDown(' ')

    if self.laser then
      self.laserTween = flux.to(self, 1, {laserLength = 1000}):ease('expoout')

      if self.laserLength > 0 then
        local x1, y1 = self.x, self.y - self.h / 2
        local x2, y2 = self.x + self.direction.x * self.laserLength, self.y + self.direction.y * self.laserLength - self.h / 2

        ctx.world:rayCast(x1, y1, x2, y2, function(fixture)
          local person = fixture:getBody():getUserData()
          if person and person.die then
            person:die()
            lume.remove(ctx.people, person)
            kills = kills + 1
            return 1
          end
          return -1
        end)
      end

      --[[for i, person in lume.ripairs(ctx.people) do

        local px, py, px2, py2 = person.body:getWorldPoints(person.shape:getPoints())
        local pw, ph = px2 - px, py2 - py
        if math.hlora(x1, y1, x2, y2, px, py, pw, ph) then
          kills = kills + 1
          table.remove(ctx.people, i)
        end
      end]]

    else
      if self.laserTween then
        self.laserTween:stop()
        self.laserLength = 0
      end
    end
  end

  -- Increase size and health on kill
  if kills > 0 then
    flux.to(self, .6, {w = self.w + 5 * kills, h = self.h + 10 * kills}):ease('elasticout')
    self.health = math.min(self.health + 15 * kills, self.maxHealth)
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
    self.w = self.w / 2
    self.h = self.h / 2
  end

  -- Health decay
  self.health = self.health - 10 * ls.tickrate
end

function Pigeon:draw()
  local g = love.graphics
  local x = lume.lerp(self.prevx, self.x, ls.accum / ls.tickrate)
  local y = lume.lerp(self.prevy, self.y, ls.accum / ls.tickrate)
  g.setColor(255, 255, 255)
  g.rectangle('line', x - self.w / 2, y - self.h, self.w, self.h)

  if self.laser then
    local x2, y2 = x + self.direction.x * self.laserLength, y + self.direction.y * self.laserLength

    g.setColor(255, 0, 0)
    g.setLineWidth(self.w / 5)
    g.line(x, y - self.h / 2, x2, y2 - self.h / 2)
    g.setLineWidth(1)
  end

  self.animation:draw(self.x, self.y)
end

function Pigeon:keypressed(key)
  if key == 'z' then
    self.vy = -self.jumpspeed
  end
end
