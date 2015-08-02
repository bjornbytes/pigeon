Dinoland = extend(Map)
Dinoland.width = 4800
Dinoland.height = 900
Dinoland.groundHeight = 100

function Dinoland:init()
  self.zones = {}

  self.obstacles = {}

  obstacle = {}
  obstacle.width, obstacle.height = 500, 200
  obstacle.body = love.physics.newBody(ctx.world, 2100, self.height - self.groundHeight - obstacle.height / 2)
  obstacle.shape = love.physics.newRectangleShape(obstacle.width, obstacle.height)
  obstacle.fixture = love.physics.newFixture(obstacle.body, obstacle.shape)
  obstacle.fixture:setCategory(ctx.categories.oneWayPlatform)
  obstacle.body:setUserData(obstacle)
  obstacle.tag = 'platform'

  table.insert(self.obstacles, obstacle)

  local obstacle = {}
  obstacle.width, obstacle.height = 1000, 100
  obstacle.body = love.physics.newBody(ctx.world, 1850, self.height - self.groundHeight - obstacle.height / 2)
  obstacle.shape = love.physics.newRectangleShape(obstacle.width, obstacle.height)
  obstacle.fixture = love.physics.newFixture(obstacle.body, obstacle.shape)
  obstacle.fixture:setCategory(ctx.categories.oneWayPlatform)
  obstacle.body:setUserData(obstacle)
  obstacle.tag = 'platform'

  table.insert(self.obstacles, obstacle)


  Map.init(self)
end

function Dinoland:spawnHuts()
  ctx.buildings:add(Building, {x = 950, y = self.height - self.ground.height})
  ctx.buildings:add(Building, {x = 2000, y = self.height - self.ground.height - 200})
  ctx.buildings:add(Building, {x = 2200, y = self.height - self.ground.height - 200})
  ctx.buildings:add(Building, {x = 2100, y = self.height - self.ground.height})

  for i = 1, 20 do
    ctx.enemies:add(Caveman, {x = 1600 - 150 + love.math.random() * 300, y = self.height - 200})
  end
end
