Game = class()

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

  for i = 1, 5 do
    self.buildings:add(Building(300 + lume.random(self.map.width - 300), lume.random(20, 100), lume.random(60, 300)))
  end

  for i = 1, 50 do
    self.people:add(Person(500 + lume.random(self.map.width - 500), 400, -1))
  end
end

function Game:update()
  self.pigeon:update()
  self.people:update()
  self.buildings:update()
  self.projectiles:update()
  self.world:update(ls.tickrate)
  self.view:update()
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
