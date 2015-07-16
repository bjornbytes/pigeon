Map = class()
Map.width = 1600
Map.height = 600

function Map:init()
  self.ground = {}
  self.ground.height = 100
  self.ground.body = love.physics.newBody(ctx.world, self.width / 2, self.height - self.ground.height / 2, 'static')
  self.ground.shape = love.physics.newRectangleShape(self.width, self.ground.height)

  self.ground.fixture = love.physics.newFixture(self.ground.body, self.ground.shape)

  ctx.view.xmax = self.width
  ctx.view.ymax = self.height
  ctx.event:emit('view.register', {object = self})
end

function Map:draw()
  local g = love.graphics
  g.setColor(0, 50, 0)
  g.rectangle('fill', 0, 0, self.width, self.height)

  g.setColor(100, 80, 0)
  physics.draw('fill', self.ground)
end
