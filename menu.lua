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

  self.selectedIndex = 1

  self.selectedWorld = 'dinoland'
  self.selectedIndex = 1
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
  local gw, gh = love.graphics.getDimensions()
  g.push()
  g.translate(0, -300)
  self.map:draw()
  ctx.enemies:each(function(enemy)
    enemy:draw()
  end)
  g.pop()

  g.setColor(0, 0, 0, 100)
  g.rectangle('fill', 0, 0, g.getDimensions())

  g.setFont('media/fonts/handDrawnShapes.ttf', 100)
  local str = 'FOWL PLAY'
  g.setColor(0, 0, 0)
  g.print(str, g.getWidth() / 2 - g.getFont():getWidth(str) / 2 + 2, 100 + 2)
  g.setColor(255, 255, 255)
  g.print(str, g.getWidth() / 2 - g.getFont():getWidth(str) / 2, 100)

  g.setColor(255, 255, 255)

  local font = g.setFont('media/fonts/handDrawnShapes.ttf', 60)

  --
  local str = 'Play'
  local sw = font:getWidth(str)
  local sh = font:getHeight()
  if self.selectedIndex == 1 then
    g.rectangle('line', gw / 2 - sw / 2 - 10, 250 - 10, sw + 20, sh + 20)
  end

  g.setColor(0, 0, 0)
  g.print(str, gw / 2 - g.getFont():getWidth(str) / 2 + 2, 250 + 2)
  g.setColor(255, 255, 255)
  g.print(str, gw / 2 - g.getFont():getWidth(str) / 2, 250)

  --
  local str = self.worldIndex .. '-' .. self.levelIndex
  local sw = font:getWidth(str)
  local sh = font:getHeight()
  if self.selectedIndex == 2 then
    g.rectangle('line', gw / 2 - sw / 2 - 10, 350 - 10, sw + 20, sh + 20)
  end

  g.setColor(0, 0, 0)
  g.print(str, gw / 2 - sw / 2 + 2, 350 + 2)
  g.setColor(255, 255, 255)
  g.print(str, gw / 2 - sw / 2, 350)

  --
  local str = 'Quit'
  local sw = font:getWidth(str)
  local sh = font:getHeight()
  if self.selectedIndex == 3 then
    g.rectangle('line', gw / 2 - sw / 2 - 10, 450 - 10, sw + 20, sh + 20)
  end

  g.setColor(0, 0, 0)
  g.print(str, gw / 2 - sw / 2 + 2, 450 + 2)
  g.setColor(255, 255, 255)
  g.print(str, gw / 2 - sw / 2, 450)
end

function Menu:keypressed(key)
  if key == 'escape' then love.event.quit() end

  if key == 'up' then
    self.selectedIndex = self.selectedIndex - 1
    if self.selectedIndex <= 0 then self.selectedIndex = 3 end
  elseif key == 'down' then
    self.selectedIndex = self.selectedIndex + 1
    if self.selectedIndex > 3 then self.selectedIndex = 1 end
  elseif key == ' ' or key == 'return' then
    if self.selectedIndex == 1 then
      local world = ({'Dinoland', 'Kingdumb'})[self.worldIndex]
      Context:remove(ctx)
      Context:add(Game, world, self.levelIndex)
      return
    elseif self.selectedIndex == 2 then
      love.event.quit()
    end
  elseif key == 'left' then
    self.levelIndex = self.levelIndex - 1
    if self.levelIndex <= 0 then
      self.levelIndex = 3
      if self.worldIndex == 1 then self.worldIndex = 2
      else self.worldIndex = 1 end
    end
  elseif key == 'right' then
    self.levelIndex = self.levelIndex + 1
    if self.levelIndex > 3 then
      self.levelIndex = 1
      if self.worldIndex == 1 then self.worldIndex = 2
      else self.worldIndex = 1 end
    end
  end
end
