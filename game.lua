Game = class()

function Game:load()
  self.event = Event()
  self.world = love.physics.newWorld(0, 1000)
  self.view = View()
  self.map = Map(ctx)
  self.pigeon = Pigeon()
  self.people = {}
  self.buildings = {}
  self.hud = Hud()

  lume.push(self.buildings, Building(650, 60, 100), Building(800, 60, 200))
end

function Game:update()
  self.pigeon:update()
  lume.each(self.people, function(person)
    person:update()
  end)

  --[[lume.each(self.buildings, function(building)
    building:update()
  end)]]

  if love.math.random() < .7 * ls.tickrate then
    local x, dir

    if love.math.random() < .5 then
      x = 0
      dir = 1
    else
      x = 800
      dir = -1
    end

    lume.push(self.people, Person(x, 400, dir))
  end

  self.world:update(ls.tickrate)
  self.view:update()
end

function Game:draw()
  flux.update(ls.dt)
  self.view:draw()
end

function Game:keypressed(key)
  if key == 'escape' then
    love.event.quit()
  end
end
