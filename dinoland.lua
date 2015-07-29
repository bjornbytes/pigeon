Dinoland = extend(Map)
Dinoland.width = 2400
Dinoland.height = 600
Dinoland.groundHeight = 100

function Dinoland:init()
  self.zones = {}

  self.obstacles = {}

  local obstacle = {}
  obstacle.width, obstacle.height = 500, 100
  obstacle.body = love.physics.newBody(ctx.world, 800, self.height - self.groundHeight - obstacle.height / 2)
  obstacle.shape = love.physics.newRectangleShape(obstacle.width, obstacle.height)
  obstacle.fixture = love.physics.newFixture(obstacle.body, obstacle.shape)
  obstacle.fixture:setCategory(ctx.categories.oneWayPlatform)

  table.insert(self.obstacles, obstacle)

  obstacle = {}
  obstacle.width, obstacle.height = 300, 200
  obstacle.body = love.physics.newBody(ctx.world, 1200, self.height - self.groundHeight - obstacle.height / 2)
  obstacle.shape = love.physics.newRectangleShape(obstacle.width, obstacle.height)
  obstacle.fixture = love.physics.newFixture(obstacle.body, obstacle.shape)
  obstacle.fixture:setCategory(ctx.categories.oneWayPlatform)

  table.insert(self.obstacles, obstacle)

  Map.init(self)

  self.decorations = {}
  for i = 1, 10 do
    local obstacle
    if love.math.random() < .75 then
      obstacle = self.ground
    else
      obstacle = self.obstacles[love.math.random(1, #self.obstacles)]
    end

    table.insert(self.decorations, {image = data.media.graphics.dinoland['shrub' .. love.math.random(1, 4)], x = obstacle.body:getX() + love.math.random() * obstacle.width / 2, y = obstacle.body:getY() - obstacle.height / 2, height = 50 + love.math.random() * 60, direction = love.math.random() > .5 and -1 or 1})
  end
end
