Game = class()

Game.categories = {
  ground = 1,
  building = 2,
  person = 3,
  pigeon = 4,
  oneWayPlatform = 5,
  debris = 6
}

function Game:load()
  self.event = Event()
  self.world = love.physics.newWorld(0, 1000)
  self.view = View()
  self.map = Dinoland()
  self.pigeon = Pigeon()
  self.enemies = Manager()
  self.buildings = Manager()
  self.projectiles = Manager()
  self.hud = Hud()
  self.goal = Goal()

  self.map:spawnHuts()

  self.world:setContactFilter(function(fixtureA, fixtureB)
    local a, b = fixtureA:getBody():getUserData(), fixtureB:getBody():getUserData()
    if not a or not b then return true end
    local resultA = f.exe(a.collideWith, a, b, fixtureA, fixtureB)
    local resultB = f.exe(b.collideWith, b, a, fixtureB, fixtureA)
    return resultA or resultB
  end)
end

function Game:update()
  self.debug = love.keyboard.isDown('`')

  self.pigeon:update()
  self.enemies:update()
  self.buildings:update()
  self.projectiles:update()
  self.map:update()
  self.world:update(ls.tickrate)
  self.view:update()
  self.hud:update()

  lurker.update()
end

function Game:draw()
  flux.update(ls.dt)
  self.view:draw()
  self.goal:draw()
end

function Game:keypressed(key)
  if key == 'escape' then
    love.event.quit()
  end

  self.pigeon:keypressed(key)
end
