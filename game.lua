Game = class()

function Game:load()
  self.world = love.physics.newWorld(0, 98)
  self.map = Map(ctx)
  self.pigeon = Pigeon()
  self.people = {}
  self.hud = Hud()
end

function Game:update()
  self.pigeon:update()
  lume.each(self.people, function(person)
    person:update()
  end)

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
end

function Game:draw()
  flux.update(ls.dt)
  self.map:draw()
  self.pigeon:draw()
  lume.each(self.people, function(person)
    person:draw()
  end)
  self.hud:draw()
end

function Game:keypressed(key)
  if key == 'escape' then
    love.event.quit()
  end
end
