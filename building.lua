Building = class()

Building.category = 4

function Building:init(x, w, h)
  self.x = x
  self.y = ctx.map.height - ctx.map.ground.height
  self.w = w
  self.h = h

  self.body = love.physics.newBody(ctx.world, self.x - self.w / 2, self.y - self.h / 2, 'kinematic')
  self.shape = love.physics.newRectangleShape(self.w, self.h)
  self.fixture = love.physics.newFixture(self.body, self.shape)

  self.body:setUserData(self)

  self.body:setMass(1000)
  self.fixture:setCategory(self.category)
  self.fixture:setMask(self.category, Person.category)

  ctx.event:emit('view.register', {object = self})
end

function Building:draw()
  local g = love.graphics

  g.setColor(128, 128, 128, 35)
  physics.draw('fill', self)

  g.setColor(255, 255, 255)
  physics.draw('line', self)
end

function Building:die()
  self.body:destroy()
  ctx.event:emit('view.unregister', {object = self})
end

