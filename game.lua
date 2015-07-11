Game = class()

function Game:load()
  self.pigeon = Pigeon()
  self.people = {Person()}
  self.hud = Hud()
end

function Game:update()
  self.pigeon:update()
  lume.each(self.people, function(person)
    person:update()
  end)

  if love.math.random() < .5 * ls.tickrate then
    local p = Person()

    if love.math.random() < .5 then
      p.x = 0
      p.direction = 1
    else
      p.x = 800
      p.direction = -1
    end

    lume.push(self.people, p)
  end
end

function Game:draw()
  local g = love.graphics
  flux.update(ls.dt)
  g.setColor(0, 50, 0)
  g.rectangle('fill', 0, 0, 800, 600)
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

  self.pigeon:keypressed(key)
end
