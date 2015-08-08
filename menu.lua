Menu = class()
Menu.categories = {
  ground = 1,
  building = 2,
  person = 3,
  pigeon = 4,
  oneWayPlatform = 5,
  debris = 6
}

function Menu:load()
  self.worldIndex = 1
  self.levelIndex = 1

  self.world = love.physics.newWorld(0, 1000)
  self.map = Map()
  self.map.name = 'dinoland'
  self.enemies = Manager()

  for i = 1, 20 do
    ctx.enemies:add(Caveman, {x = 0 + love.math.random() * love.graphics.getWidth(), y = self.map.height - self.map.ground.height})
  end

  joystick = #love.joystick.getJoysticks() > 0 and love.joystick.getJoysticks()[1]

  self.selectedButton = 'play'
end

function Menu:update()
  self.map:update()
  self.enemies:update()
  self.world:update(ls.tickrate)

  if joystick and joystick:isGamepadDown('start') then
    self:keypressed(' ')
  end
end

function Menu:draw()
  local g = love.graphics
  g.push()
  g.translate(0, -300)
  self.map:draw()
  ctx.enemies:each(function(enemy)
    enemy:draw()
  end)
  g.pop()

  g.setColor(0, 0, 0, 100)
  g.rectangle('fill', 0, 0, g.getDimensions())

  g.setColor(255, 255, 255)
  g.print('FOWL PLAY\npress space', g.getWidth() / 2 - g.getFont():getWidth('PIGEON') / 2, 200)
end

function Menu:keypressed(key)
  if key == 'escape' then love.event.quit() end

  if key == 'left' then

  elseif key == 'right' then

  elseif key == ' ' then
    local world = ({'Dinoland', 'Kingdumb'})[self.worldIndex]
    Context:remove(ctx)
    Context:add(Game, world, self.levelIndex)
    return
  end
end
