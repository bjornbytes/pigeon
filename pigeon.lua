Pigeon = class()

function Pigeon:init()
  self.x = 0
  self.y = 500
  self.w = 20
  self.h = 40
  self.speed = 100
  self.direction = {x = 1, y = 0}
  self.laser = false

  self.lives = 3
  self.health = 100
  self.maxHealth = 100
end

function Pigeon:update()
  if love.keyboard.isDown('left') then
    self.x = self.x - self.speed * ls.tickrate
    self.direction.x = -1
  elseif love.keyboard.isDown('right') then
    self.x = self.x + self.speed * ls.tickrate
    self.direction.x = 1
  end

  if love.keyboard.isDown('up') then
    self.direction.y = -1
  elseif love.keyboard.isDown('down') then
    self.direction.y = 1
  else
    self.direction.y = 0
  end

  self.laser = love.keyboard.isDown(' ')

  if self.laser then
    local kills = 0

    local x1, y1 = self.x, self.y
    local x2, y2 = self.x + self.direction.x * 1000, self.y + self.direction.y * 1000

    lume.each(ctx.people, function(person, i)
      if math.hlora(x1, y1, x2, y2, person.x - person.w / 2, person.y - person.h / 2, self.w, self.h) then
        kills = kills + 1
        table.remove(ctx.people, i)
      end
    end)

    if kills > 0 then
      self.w = self.w + 5 * kills
      self.h = self.h + 10 * kills
    end
  end

  if self.health < 0 then
    if self.lives == 0 then
      print('you lose')
      love.event.quit()
      return
    end

    self.health = self.maxHealth
    self.lives = self.lives - 1
  end

  self.health = self.health - 10 * ls.tickrate
end

function Pigeon:draw()
  local g = love.graphics
  g.setColor(255, 255, 255)
  g.rectangle('line', self.x - self.w / 2, self.y - self.h / 2, self.w, self.h)

  if self.laser then
    local x1, y1 = self.x, self.y
    local x2, y2 = self.x + self.direction.x * 1000, self.y + self.direction.y * 1000

    g.setColor(255, 0, 0)
    g.line(x1, y1, x2, y2)
  end
end
