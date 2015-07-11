Game = class()

function Game:load()
  self.pigeon = Pigeon()
  self.people = {Person()}
end

function Game:update()
  self.pigeon:update()
  lume.each(self.people, function(person)
    person:update()
  end)

  if love.math.random() < .5 * ls.tickrate then
    lume.push(self.people, Person())
  end
end

function Game:draw()
  self.pigeon:draw()
  lume.each(self.people, function(person)
    person:draw()
  end)
end

function Game:keypressed(key)
  if key == 'escape' then
    love.event.quit()
  end
end
