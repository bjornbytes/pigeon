Pigeon = class()

function Pigeon:init()
  self.x = 0
  self.y = 500
  self.w = 20
  self.h = 40
  self.speed = 100
  self.direction = 0
  self.laser = false

  self.lives = 3
  self.health = 100
  self.maxHealth = 100
end

function Pigeon:update()
  if love.keyboard.isDown('left') then
    self.x = self.x - self.speed * ls.tickrate
    self.direction = -1
  elseif love.keyboard.isDown('right') then
    self.x = self.x + self.speed * ls.tickrate
    self.direction = 1
  end

  self.laser = love.keyboard.isDown(' ')

  if self.laser then
    local kills = 0
    lume.each(ctx.people, function(person, i)
      local x1, x2 = self.x, self.x + 1000 * self.direction
      if person.x > math.min(x1, x2) and person.x < math.max(x1, x2) then
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
    love.graphics.setColor(255, 0, 0)
    love.graphics.line(self.x, self.y, self.x + 1000 * self.direction, self.y)
  end
end
