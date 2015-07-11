Person = class()

function Person:init()
  self.x = 800
  self.direction = -1
  self.y = 500
  self.w = 20
  self.h = 40
end

function Person:update()
  self.x = self.x + 100 * self.direction * ls.tickrate
end

function Person:draw()
  local g = love.graphics
  g.setColor(255, 255, 255)
  g.rectangle('line', self.x - self.w / 2, self.y - self.h / 2, self.w, self.h)
end


