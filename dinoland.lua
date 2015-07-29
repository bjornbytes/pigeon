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

  obstacle = {}
  obstacle.width, obstacle.height = 550, 300
  obstacle.body = love.physics.newBody(ctx.world, 550 / 2, self.height - self.groundHeight - obstacle.height / 2)
  obstacle.shape = love.physics.newRectangleShape(obstacle.width, obstacle.height)
  obstacle.fixture = love.physics.newFixture(obstacle.body, obstacle.shape)
  obstacle.fixture:setCategory(ctx.categories.oneWayPlatform)

  table.insert(self.obstacles, obstacle)

  return Map.init(self)
end
