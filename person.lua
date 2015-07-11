Person = class()

function Person:init(x, y, dir)
  self.x = x
  self.y = y
  self.direction = dir
  self.w = 20
  self.h = 40

  self.body = love.physics.newBody(ctx.world, self.x - self.w / 2, self.y - self.h / 2, 'dynamic')
  self.shape = love.physics.newRectangleShape(self.w, self.h)
  self.fixture = love.physics.newFixture(self.body, self.shape)

  self.body:setUserData(self)

  self.body:setMass(10)
end

function Person:update()
  self.body:applyLinearImpulse(300 * self.direction * ls.tickrate, 0)
end

function Person:draw()
  local g = love.graphics
  g.setColor(255, 255, 255)
  drawPhysicsObject('line', self)
end

function Person:die()
  self.body:destroy()
end
