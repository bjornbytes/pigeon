Map = class()
Map.width = 800
Map.height = 600

function Map:init()
  self.ground = {}
  self.ground.height = 100
  self.ground.body = love.physics.newBody(ctx.world, self.width / 2, self.height - self.ground.height / 2, 'static')
  self.ground.shape = love.physics.newRectangleShape(self.width, self.ground.height)

  self.ground.fixture = love.physics.newFixture(self.ground.body, self.ground.shape)
end

function Map:draw()
  local g = love.graphics
  g.setColor(0, 50, 0)
  g.rectangle('fill', 0, 0, self.width, self.height)

  g.setColor(100, 80, 0)
  drawPhysicsObject('fill', self.ground)
end
