Kingdumb = extend(Map)
Kingdumb.groundHeight = 100

function Kingdumb:init(index)
  self.zones = {}
  self.name = 'kingdumb'
  self.defaultPersonType = Peasant
  self.index = index

  self.obstacles = {}

  local function makeObstacle(x, y, w, h)
    local obstacle = {}
    obstacle.width, obstacle.height = w, h
    obstacle.body = love.physics.newBody(ctx.world, x, self.height - self.groundHeight - obstacle.height / 2 - y)
    obstacle.shape = love.physics.newRectangleShape(obstacle.width, obstacle.height)
    obstacle.fixture = love.physics.newFixture(obstacle.body, obstacle.shape)
    obstacle.fixture:setCategory(ctx.categories.oneWayPlatform)
    obstacle.body:setUserData(obstacle)
    obstacle.tag = 'platform'
    table.insert(self.obstacles, obstacle)
  end

  if self.index == 1 then
    self.width = 6000
    self.height = 900

    makeObstacle(1700, 0, 200, 200)
    makeObstacle(1400, 0, 800, 100)

    makeObstacle(2450, 0, 200, 200)
    makeObstacle(3000, 0, 200, 350)
    makeObstacle(2900, 0, 400, 250)
    makeObstacle(2750, 0, 600, 100)

    makeObstacle(3800, 0, 400, 100)
    makeObstacle(4500, 0, 200, 200)
    makeObstacle(4300, 0, 200, 100)
    makeObstacle(4100, 0, 200, 200)
  elseif self.index == 2 then
    self.width = 5800
    self.height = 900

    makeObstacle(1700, 0, 400, 300)
    makeObstacle(1500, 0, 100, 200)
    makeObstacle(1500, 0, 600, 100)
  elseif self.index == 3 then
    self.width = 6000
    self.height = 900

    makeObstacle(4200, 0, 600, 100)
  end

  Map.init(self)
end

function Kingdumb:spawnHuts()
  local function makeBuilding(x, y)
    ctx.buildings:add(Building, {x = x, y = self.height - self.ground.height - y})
  end

  if self.index == 1 then
    for i = 1, 30 do
      ctx.enemies:add(Peasant, {x = 800 + love.math.random() * 500, y = self.height - self.ground.height})
    end

    makeBuilding(1200, 100)
    makeBuilding(1950, 0)
    makeBuilding(2175, 0)

    for i = 1, 20 do
      ctx.enemies:add(Peasant, {x = 1300 + love.math.random() * 300, y = self.height - self.ground.height})
    end

    makeBuilding(1700, 200)
    makeBuilding(2450, 200)
    makeBuilding(3000, 350)

    for i = 1, 20 do
      ctx.enemies:add(Peasant, {x = 2800 + love.math.random() * 500, y = self.height - self.ground.height})
    end

    makeBuilding(3700, 0)
    makeBuilding(3900, 100)

    makeBuilding(4500, 200)

    makeBuilding(4700, 100)
    makeBuilding(4800, 100)
    makeBuilding(4900, 100)
    makeBuilding(5000, 100)
    makeBuilding(5100, 100)

    for i = 1, 20 do
      ctx.enemies:add(Peasant, {x = 3900 + love.math.random() * 600, y = self.height - self.ground.height})
    end
  elseif self.index == 2 then
    makeBuilding(1050, 100)
    makeBuilding(1350, 0)
    makeBuilding(1200, 100)

    makeBuilding(2000, 300)

    makeBuilding(2650, 0)

    makeBuilding(3250, 100)
    makeBuilding(3350, 0)
    makeBuilding(3450, 100)
    makeBuilding(3550, 0)
    makeBuilding(3650, 100)

    makeBuilding(4000, 100)
    makeBuilding(4400, 200)
    makeBuilding(4800, 100)

    for i = 1, 20 do
      ctx.enemies:add(Peasant, {x = 1500 + love.math.random() * 300, y = self.height - self.ground.height})
    end

    for i = 1, 10 do
      ctx.enemies:add(Peasant, {x = 1900 + love.math.random() * 200, y = self.height - self.ground.height - 100})
    end

    for i = 1, 20 do
      ctx.enemies:add(Peasant, {x = 2650 + love.math.random() * 400, y = self.height - self.ground.height})
    end

    for i = 1, 20 do
      ctx.enemies:add(Peasant, {x = 4100 + love.math.random() * 600, y = self.height - self.ground.height})
    end

    for i = 1, 20 do
      ctx.enemies:add(Peasant, {x = 4100 + love.math.random() * 600, y = self.height - self.ground.height - 200})
    end
  elseif self.index == 3 then
    makeBuilding(900, 0)
    makeBuilding(1500, 0)
    makeBuilding(2100, 0)

    for i = 1, 15 do
      ctx.enemies:add(Peasant, {x = 1000 + love.math.random() * 400, y = self.height - self.ground.height})
    end

    for i = 1, 15 do
      ctx.enemies:add(Peasant, {x = 1600 + love.math.random() * 400, y = self.height - self.ground.height})
    end

    makeBuilding(2500, 100)
    makeBuilding(2900, 300)
    makeBuilding(3000, 0)
    makeBuilding(3150, 100)
    makeBuilding(3300, 200)

    for i = 1, 20 do
      ctx.enemies:add(Peasant, {x = 2600 + love.math.random() * 800, y = self.height - self.ground.height - 200})
    end

    for i = 1, 8 do
      ctx.enemies:add(Peasant, {x = 3000 + love.math.random() * 300, y = self.height - self.ground.height})
    end

    makeBuilding(3950, 100)
    makeBuilding(4450, 100)

    for i = 1, 10 do
      ctx.enemies:add(Peasant, {x = 4175 + love.math.random() * 50, y = self.height - self.ground.height - 400})
    end

    makeBuilding(5000, 200)

    for i = 1, 35 do
      ctx.enemies:add(Peasant, {x = 4500 + love.math.random() * 600, y = self.height - self.ground.height})
    end
  end
end
