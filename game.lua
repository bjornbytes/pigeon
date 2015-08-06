Game = class()
Game.categories = {
  ground = 1,
  building = 2,
  person = 3,
  pigeon = 4,
  oneWayPlatform = 5,
  debris = 6
}

function Game:load(level, levelIndex)
  self.stats = {
    buildingsDestroyed = 0,
    peopleKilled = 0,
    maxCombo = 0
  }

  self.startTick = ls.tick

  self.event = Event()
  self.world = love.physics.newWorld(0, 1000)
  self.view = View()
  self.map = _G[level](levelIndex)
  self.pigeon = Pigeon()
  self.enemies = Manager()
  self.buildings = Manager()
  self.projectiles = Manager()
  self.hud = Hud()
  self.goal = Goal()
  self.particles = Particles()
  self.sound = Sound()
  self.paused = false

  self.map:spawnHuts()

  ctx.stats.maxMaxCombo = table.count(ctx.enemies.objects) + table.count(ctx.buildings.objects) + (table.count(ctx.buildings.objects) * 6)
  ctx.stats.originalBuildings = table.count(ctx.buildings.objects)
  ctx.stats.originalPeople = table.count(ctx.buildings.objects) * 6 + table.count(ctx.enemies.objects)

  self.backgroundSound = ctx.sound:loop('background', function(sound)
    sound:setVolume(.5)
  end)

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

  if self.paused then
    self.pigeon:paused()
    self.view:update()
    self.buildings:paused()
    self.enemies:paused()
    self.projectiles:paused()
    self.hud:paused()
    return
  end

  self.pigeon:update()
  self.enemies:update()
  self.buildings:update()
  self.projectiles:update()
  self.map:update()
  self.world:update(ls.tickrate)
  self.view:update()
  self.hud:update()

  ls.timescale = love.keyboard.isDown('r') and 5 or 1

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
  elseif key == 'm' then
    ctx.sound:mute()
  elseif key == 'p' then
    self.paused = not self.paused
  elseif (key == 'return' or key == ' ') and ctx.hud.win.active then
    Context:remove(ctx)
    local world
    local index
    if ctx.map.name == 'kingdumb' and ctx.map.index == 3 then
      -- Menu
      return
    elseif ctx.map.name == 'dinoland' and ctx.map.index == 3 then
      world = 'Kingdumb'
      index = 1
    else
      world = (ctx.map.name == 'dinoland') and 'Dinoland' or 'Kingdumb'
      index = ctx.map.index + 1
    end
    Context:add(Game, world, index)
  end

  self.pigeon:keypressed(key)
end
