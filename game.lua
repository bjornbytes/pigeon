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

  self.enemies:add(Caveman, {x = 500, y = 300})
  self.buildings:add(Building, {x = 600, width = 200, height = 80})

  self.world:setContactFilter(function(fixtureA, fixtureB)
    local a, b = fixtureA:getBody():getUserData(), fixtureB:getBody():getUserData()
    if not a or not b then return true end
    f.exe(a.collideWith, a, b, fixtureA, fixtureB)
    f.exe(b.collideWith, b, a, fixtureB, fixtureA)
  end)
end

function Game:update()
  self.pigeon:update()
  self.enemies:update()
  self.buildings:update()
  self.projectiles:update()
  self.map:update()
  self.world:update(ls.tickrate)
  self.view:update()

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
end
