Person = class()

Person.category = 3

function Person:init(x, y, dir)
  self.x = x
  self.y = y
  self.direction = dir

  self.image = data.media.graphics.dinoland[love.math.random() < .5 and 'female' or 'male'].normal
  local widthRatio = self.image:getWidth() / self.image:getHeight()
  self.h = 40
  self.w = self.h * widthRatio
  self.scale = self.h / self.image:getHeight()

  self.body = love.physics.newBody(ctx.world, self.x - self.w / 2, self.y - self.h / 2, 'dynamic')
  self.shape = love.physics.newRectangleShape(self.w, self.h)
  self.fixture = love.physics.newFixture(self.body, self.shape)

  self.body:setUserData(self)

  self.body:setMass(100)
  self.body:setFixedRotation(true)
  self.fixture:setFriction(.35)
  self.fixture:setCategory(self.category)
  self.fixture:setMask(self.category, Building.category)

  self.dead = false
  self.walkTimer = 1

  ctx.event:emit('view.register', {object = self})
end

function Person:update()
  if not self.dead then
    self.walkTimer = timer.rot(self.walkTimer, function()
      self.body:applyLinearImpulse(self.direction * 50, -100)
      return .6 + love.math.random() * .2
    end)
  else
    local x, y = self.body:getLinearVelocity()
    if (math.abs(x) < 1 and math.abs(y) < 1) or (math.abs(x) > 5000 and math.abs(y) > 5000) then
      ctx.people:remove(self)
      self.body:destroy()
      ctx.event:emit('view.unregister', {object = self})
    end
  end
end

function Person:draw()
  local g = love.graphics
  g.draw(self.image, self.body:getX(), self.body:getY(), self.body:getAngle(), self.scale * self.direction, self.scale, self.image:getWidth() / 2, self.image:getHeight() / 2)
end

function Person:die()
  if not self.dead then
    self.dead = true
    self.body:applyLinearImpulse(-500 + love.math.random() * 1000, love.math.random() * -800)
    self.body:applyTorque(-200 * love.math.random() * 400)
    self.body:setFixedRotation(false)
  end
end
