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
  self.map = Map(ctx)
  self.pigeon = Pigeon()
  self.people = Manager()
  self.buildings = Manager()
  self.projectiles = Manager()
  self.hud = Hud()
  self.goal = Goal()

  --self.people:add(Caveman, {x = 500, y = 300})
  self.buildings:add(Building, {x = 600, width = 200, height = 80})
end

function Game:update()
  self.pigeon:update()
  self.people:update()
  self.buildings:update()
  self.projectiles:update()
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
