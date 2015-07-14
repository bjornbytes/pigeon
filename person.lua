Person = class()

Person.category = 3

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
  self.fixture:setFriction(.35)
  self.fixture:setCategory(self.category)
  self.fixture:setMask(self.category)

  self.stable = true
  self.walkTimer = 1
end

function Person:update()
  self.body:setFixedRotation(self.stable)
  self.walkTimer = timer.rot(self.walkTimer, function()
    self.body:applyLinearImpulse(self.direction * 50, -100)
    return .6 + love.math.random() * .2
  end)
end

function Person:draw()
  local g = love.graphics

  g.setColor(255, 255, 255, 35)
  physics.draw('fill', self)

  g.setColor(255, 255, 255)
  physics.draw('line', self)
end

function Person:die()
  self.body:destroy()
end
