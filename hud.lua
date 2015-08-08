Hud = class()

Hud.bonuses = {
  wreckingBall = {
    name = 'Wrecking Ball',
    description = 'Kill all buildings',
    score = 100000,
    color = 'silver',
    check = function()
      local aliveBuilding = false
      table.each(ctx.buildings.objects, function(building)
        if not building.destroyed then
          aliveBuilding = true
        end
      end)

      return not aliveBuilding
    end
  },
  bigBadPigeon = {
    name = 'Big Bad Pigeon',
    description = 'Kill no buildings',
    score = 50000,
    color = 'bronze',
    check = function()
      return ctx.stats.buildingsDestroyed == 0
    end
  },
  genocide = {
    name = 'Genocide',
    description = 'Kill all people',
    score = 250000,
    color = 'gold',
    check = function()
      local aliveBuilding = false
      table.each(ctx.buildings.objects, function(building)
        if not building.destroyed then
          aliveBuilding = true
        end
      end)

      local alivePerson = false
      table.each(ctx.enemies.objects, function(person)
        if person.state ~= 'dead' then
          alivePerson = true
        end
      end)

      return not aliveBuilding and not alivePerson
    end
  },
  hopper = {
    name = 'Hopper',
    description = 'Don\'t stop jumping',
    score = 100000,
    color = 'silver',
    check = function()
      return ctx.pigeon.stepsTaken == 0
    end
  },
  woodpecker = {
    name = 'Woodpecker',
    description = 'Kill everything by pecking',
    score = 250000,
    color = 'gold',
    check = function()
      return ctx.nonPeckKill == false and ctx.pigeon.pecks > 0
    end
  },
  verticallyChallenged = {
    name = 'Vertically Challenged',
    description = 'Don\'t jump',
    score = 25000,
    color = 'bronze',
    check = function()
      return ctx.pigeon.jumps == 0
    end
  },
  stiff = {
    name = 'Stiff Neck',
    description = 'Don\'t peck',
    score = 25000,
    color = 'bronze',
    check = function()
      return ctx.pigeon.pecks == 0
    end
  },
  pacifist = {
    name = 'Pacifist',
    description = 'Don\'t kill anything',
    score = 500000,
    color = 'gold',
    check = function()
      return ctx.stats.buildingsDestroyed == 0 and ctx.stats.peopleKilled == 0
    end
  },
  scrub = {
    name = 'Scrub',
    description = 'Get a max combo of 25 or less',
    score = 50000,
    color = 'bronze',
    check = function()
      return ctx.stats.maxCombo <= 25
    end
  },
  badass = {
    name = 'Badass',
    description = 'Get a max combo of 100 or higher',
    score = 100000,
    color = 'silver',
    check = function()
      return ctx.stats.maxCombo >= 100
    end
  },
  korean = {
    name = 'Korean',
    description = 'Get the highest possible max combo',
    score = 500000,
    color = 'gold',
    check = function()
      return ctx.stats.maxCombo >= ctx.stats.maxMaxCombo
    end
  },
  fabulous = {
    name = 'Fabulous',
    description = 'End the game in turbo mode',
    score = 100000,
    color = 'silver',
    check = function()
      return ctx.pigeon.rainbowShitTimer > 0
    end
  },
  youTried = {
    name = 'You Tried',
    description = 'Get no medals',
    score = 250000,
    color = 'silver',
    postCheck = function()
      return #ctx.hud.win.bonuses == 0
    end
  }
}

function Hud:init()
  ctx.event:emit('view.register', {object = self, mode = 'gui'})

  self.score = 0
  self.scoreDisplay = self.score

  self.startTimer = 3
  self.goTimer = 1.5

  self.bubble = {}
  self:resetBubble()

  self.rainbowShitCounter = 0
  self.rainbowShitDisplay = 0
  self.prevRainbowShitDisplay = 0

  self.win = {}
  self.win.active = false
  self.win.width = 800
  self.win.height = 500
  self.win.x = -400
  self.win.prevx = self.win.x

  self.deathBulge = 0
end

function Hud:update()
  self.prevRainbowShitDisplay = self.rainbowShitDisplay

  self.bubble.prevy = self.bubble.y
  self.bubble.prevScale = self.bubble.scale
  self.bubble.prevTimer = self.bubble.timer

  self.startTimer = timer.rot(self.startTimer, function()
    ctx.pigeon:changeState('walk')
    ctx.startTick = ls.tick
  end)

  if self.startTimer == 0 then
    self.goTimer = timer.rot(self.goTimer)
  end

  if self.bubble.active then
    self.bubble.y = math.lerp(self.bubble.y, self.bubble.targetY, 12 * ls.tickrate)
    self.bubble.scale = math.lerp(self.bubble.scale, self.bubble.targetScale, 12 * ls.tickrate)

    self.bubble.amountDisplay = math.lerp(self.bubble.amountDisplay, self.bubble.amount, 12 * ls.tickrate)

    self.bubble.timer = timer.rot(self.bubble.timer, function()
      self.score = self.score + self.bubble.amount * self.bubble.multiplier
      ctx.stats.maxCombo = math.max(ctx.stats.maxCombo, self.bubble.multiplier)
      self:resetBubble()
    end)
  end

  if self.win.active then
    self.win.prevx = self.win.x
    self.win.x = math.lerp(self.win.x, love.graphics.getWidth() / 2, 8 * ls.tickrate)
  end

  self.rainbowShitDisplay = math.lerp(self.rainbowShitDisplay, self.rainbowShitCounter, 8 * ls.tickrate)

  self.scoreDisplay = math.lerp(self.scoreDisplay, self.score, 5 * ls.tickrate)

  self.deathBulge = math.lerp(self.deathBulge, 0, 8 * ls.tickrate)
end

function Hud:gui()
  local g = love.graphics
  local gw, gh = g.getDimensions()
  if ctx.debug then
    local x, y = ctx.view:worldPoint(love.mouse.getPosition())
    g.setFont('media/fonts/handDrawnShapes.ttf', 24)
    g.setColor(0, 0, 0)
    g.print(x .. ', ' .. y, 9, 9)
    g.setColor(255, 255, 255)
    g.print(x .. ', ' .. y, 8, 8)
    x, y = love.mouse.getPosition()
    g.line(x, 0, x, gh)
    g.line(0, y, gw, y)
  end

  if not self.win.active then
    g.setFont('media/fonts/handDrawnShapes.ttf', 24)
    g.setColor(0, 0, 0, 150)
    local str = math.round(self.scoreDisplay)
    local w = math.max(g.getFont():getWidth(str), 80)
    local h = g.getFont():getHeight()
    g.rectangle('fill', 0, 0, w + 16, h + 16)
    g.setColor(255, 255, 255)
    g.print(str, 8, 8)
  end

  if self.bubble.active then
    local y, scale = math.lerp(self.bubble.prevy, self.bubble.y, ls.accum / ls.tickrate), math.lerp(self.bubble.prevScale, self.bubble.scale, ls.accum / ls.tickrate)
    g.setFont('media/fonts/BebasNeueBold.otf', math.max(math.round(scale / .01) * .01 * 24, 1))
    local alpha = math.clamp(math.lerp(self.bubble.prevTimer, self.bubble.timer, ls.accum / ls.tickrate), 0, 1)
    g.setColor(0, 0, 0, 128 * alpha)
    local amount = math.round(self.bubble.amountDisplay)
    local str = amount .. (self.bubble.multiplier > 1 and (' X ' .. self.bubble.multiplier) or '')
    local textWidth = g.getFont():getWidth(str)
    g.print(str, gw / 2 - textWidth / 2 + 1, y + 1)
    g.setColor(255, 255, 255, 255 * alpha)
    g.print(str, gw / 2 - textWidth / 2, y)
  end

  local baseWidth = 20
  local baseHeight = 100

  if ctx.pigeon.rainbowShitTimer > 0 then
    love.math.setRandomSeed(math.max(love.timer.getTime() * ctx.pigeon.rainbowShitTimer - self.scoreDisplay, 1))
    local prc = math.min(ctx.pigeon.rainbowShitTimer / 5, 1)
    g.setColor(128 + love.math.random() * 127, 128 + love.math.random() * 127, 128 + love.math.random() * 127)
    g.rectangle('fill', 2, 50 + baseHeight * (1 - prc), baseWidth, baseHeight * prc)
  else
    g.setColor(255, 0, 0)
  end

  local baseWidth = 20
  local baseHeight = 100
  g.rectangle('line', 2, 50, baseWidth, baseHeight)
  local prc = math.clamp(math.lerp(self.prevRainbowShitDisplay, self.rainbowShitDisplay, ls.accum / ls.tickrate) / Pigeon.rainbowShitThreshold, 0, 1)
  g.setColor(255, 0, 0)
  g.rectangle('fill', 2, 50 + baseHeight * (1 - prc), baseWidth, baseHeight * prc)

  if self.startTimer > 0 then
    local str = math.ceil(self.startTimer)
    g.setFont('media/fonts/handDrawnShapes.ttf', 80)
    g.setColor(0, 0, 0)
    g.print(str, gw / 2 - g.getFont():getWidth(str) / 2 + 2, 200 - g.getFont():getHeight() / 2 + 2)
    g.setColor(255, 255, 255)
    g.print(str, gw / 2 - g.getFont():getWidth(str) / 2, 200 - g.getFont():getHeight() / 2)
  elseif self.goTimer > 0 then
    local str = 'GO!'
    local alpha = 255 * math.clamp(self.goTimer, 0, 1)
    g.setFont('media/fonts/handDrawnShapes.ttf', 80)
    g.setColor(0, 0, 0, alpha)
    g.print(str, gw / 2 - g.getFont():getWidth(str) / 2 + 2, 200 - g.getFont():getHeight() / 2 + 2)
    g.setColor(255, 255, 255, alpha)
    g.print(str, gw / 2 - g.getFont():getWidth(str) / 2, 200 - g.getFont():getHeight() / 2)
  end

  if self.win.active then
    g.setColor(0, 0, 0, 100)
    local x = math.lerp(self.win.prevx, self.win.x, ls.accum / ls.tickrate)
    local w, h = self.win.width, self.win.height
    w = gw
    g.rectangle('fill', 0, 0, gw, gh)
    g.setFont('media/fonts/handDrawnShapes.ttf', 40)
    local str = 'Congration you done it!'
    local yy = 64
    g.setColor(0, 0, 0)
    g.print(str, x - g.getFont():getWidth(str) / 2 + 2, yy + 2)
    g.setColor(255, 255, 255)
    g.print(str, x - g.getFont():getWidth(str) / 2, yy)
    yy = yy + g.getFont():getHeight() + 10

    local str = math.round(self.scoreDisplay)
    g.setColor(0, 0, 0)
    g.print('Your score:', x - g.getFont():getWidth('Your score:') / 2 + 2, yy + 2)
    g.setColor(255, 255, 255)
    g.print('Your score:', x - g.getFont():getWidth('Your score:') / 2, yy)
    yy = yy + g.getFont():getHeight() + 15

    g.setFont('media/fonts/handDrawnShapes.ttf', 48)
    g.setColor(0, 0, 0)
    g.print(str, x - g.getFont():getWidth(str) / 2 + 2, yy + 2)
    g.setColor(255, 255, 255)
    g.print(str, x - g.getFont():getWidth(str) / 2, yy)
    yy = yy + g.getFont():getHeight() + 32

    g.setFont('media/fonts/runescape.ttf', 16)
    local xx = gw / 4 - 100
    local d = (gw / 2) - x
    local yy = gh * .7
    local function printShadow(str, x, y, off)
      off = off or 1
      g.setColor(0, 0, 0)
      g.print(str, x - d + off, y + off)
      g.setColor(255, 255, 255)
      g.print(str, x - d, y)
    end

    printShadow('Time:', xx, yy)
    local t = math.floor(ctx.stats.time)
    local seconds = math.floor(t % 60)
    local minutes = math.floor(t / 60)
    if minutes < 10 then minutes = '0' .. minutes end
    if seconds < 10 then seconds = '0' .. seconds end
    printShadow(minutes .. ':' .. seconds, xx + 150, yy)
    yy = yy + g.getFont():getHeight() + 6

    printShadow('Max Combo:', xx, yy)
    printShadow(ctx.stats.maxCombo, xx + 150, yy)
    yy = yy + g.getFont():getHeight() + 6

    printShadow('People Killed:', xx, yy)
    printShadow(ctx.stats.peopleKilled .. ' (' .. (ctx.stats.peoplePercentage * 100) .. '%)', xx + 150, yy)
    yy = yy + g.getFont():getHeight() + 6

    xx = gw * .75 - 100
    yy = gh * .7

    printShadow('Buildings Destroyed:', xx, yy)
    printShadow(ctx.stats.buildingsDestroyed .. ' (' .. (ctx.stats.buildingPercentage * 100) .. '%)', xx + 150, yy)
    yy = yy + g.getFont():getHeight() + 6

    printShadow('Pecks:', xx, yy)
    printShadow(ctx.pigeon.pecks, xx + 150, yy)
    yy = yy + g.getFont():getHeight() + 6

    printShadow('Jumps:', xx, yy)
    printShadow(ctx.pigeon.jumps, xx + 150, yy)
    yy = yy + g.getFont():getHeight() + 6

    --
    local ct = #self.win.bonuses
    local inc = 200
    local xx = x - (inc * (ct - 1) / 2)
    while inc * ct > gw do
      inc = inc - 10
    end
    local mx, my = love.mouse.getPosition()
    local flyoutService = nil
    g.setFont('media/fonts/handDrawnShapes.ttf', 24)
    for i = 1, ct do
      local name = self.win.bonuses[i]
      local bonus = self.bonuses[name]
      local image = data.media.graphics.ui[bonus.color]
      local scale = 80 / image:getHeight()
      g.setColor(255, 255, 255)
      g.draw(image, xx, gh / 2 - 20, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)
      local str = bonus.name
      g.setColor(0, 0, 0)
      g.print(str, xx - g.getFont():getWidth(str) / 2 + 2, gh / 2 - 20 + 60 + 2)
      g.setColor(255, 255, 255)
      g.print(str, xx - g.getFont():getWidth(str) / 2, gh / 2 - 20 + 60)
      if math.inside(mx, my, xx - image:getWidth() * scale / 2, gh / 2 - 20 - image:getHeight() * scale / 2, image:getWidth() * scale, image:getHeight() * scale) then
        flyoutService = bonus.description .. '\n' .. '+' .. bonus.score
      end
      xx = xx + inc
    end

    g.setFont('media/fonts/runescape.ttf', 16)
    if flyoutService then
      g.setColor(0, 0, 0, 200)
      local w = g.getFont():getWidth(flyoutService) + 8
      local h = g.getFont():getHeight() * 2 + 8
      g.rectangle('fill', mx + 8, my + 8, w, h)
      g.setColor(255, 255, 255)
      g.print(flyoutService, mx + 12, my + 12)
    end

    local alpha = math.abs(math.sin((ls.tick + ls.accum / ls.tickrate) / 25))
    local str = 'Press ' .. (joystick and 'A' or 'space') .. ' to continue'
    g.setFont('media/fonts/handDrawnShapes.ttf', 30)
    g.setColor(0, 0, 0, alpha * 255)
    g.print(str, x - g.getFont():getWidth(str) / 2 + 2, gh - 55 + 2)
    g.setColor(255, 255, 255, alpha * 255)
    g.print(str, x - g.getFont():getWidth(str) / 2, gh - 55)

    g.setFont('media/fonts/runescape.ttf', 16)
    local str = 'Press T to tweet your score!'
    g.setColor(0, 0, 0)
    g.print(str, x - g.getFont():getWidth(str) / 2 + 1, gh - 24 + 1)
    g.setColor(255, 255, 255)
    g.print(str, x - g.getFont():getWidth(str) / 2, gh - 24)
  end

  if ctx.map.name == 'dinoland' and ctx.map.index == 1 then
    local x, y = ctx.view:screenPoint(1067 / 2, ctx.map.height - 40)
    local str = 'Up = Jump, Space = Peck'
    g.setFont('media/fonts/handDrawnShapes.ttf', 30)
    g.setColor(0, 0, 0)
    g.print(str, x - g.getFont():getWidth(str) / 2 + 1, y - g.getFont():getHeight() / 2 + 1)
    g.setColor(255, 255, 255)
    g.print(str, x - g.getFont():getWidth(str) / 2, y - g.getFont():getHeight() / 2)
  end
end

function Hud:paused()
  self.prevRainbowShitDisplay = self.rainbowShitDisplay

  self.bubble.prevy = self.bubble.y
  self.bubble.prevScale = self.bubble.scale
  self.bubble.prevTimer = self.bubble.timer

  if self.win.active then
    self.win.prevx = self.win.x
  end
end

function Hud:resetBubble()
  self.bubble.active = false
  self.bubble.amount = 0
  self.bubble.amountDisplay = self.bubble.amount
  self.bubble.timer = 0
  self.bubble.multiplier = 0
  self.bubble.targetY = 200
  self.bubble.y = self.bubble.targetY
  self.bubble.prevy = self.bubble.y
  self.bubble.targetScale = 1
  self.bubble.scale = self.bubble.targetScale
  self.bubble.prevScale = self.bubble.scale
  self.rainbowShitCounter = 0
end

function Hud:addScore(amount, kind, cause)
  if cause == 'peck' then
    amount = amount * 2
  end

  self.bubble.active = true
  self.bubble.timer = 3
  self.bubble.amount = self.bubble.amount + amount
  self.bubble.multiplier = self.bubble.multiplier + 1
  self.bubble.scale = self.bubble.scale + .2
  self.bubble.targetScale = self.bubble.targetScale + .1
  self.bubble.targetY = math.lerp(self.bubble.targetY, 50, .15)
  self.bubble.prevTimer = self.bubble.timer

  if kind == 'person' then
    self.rainbowShitCounter = self.bubble.multiplier --self.rainbowShitCounter + 1
    if self.rainbowShitCounter % 50 == 0 then
      --self.rainbowShitCounter = 0
      ctx.pigeon:activateRainbowShit()
    end
  end
end

function Hud:activateWin()
  self.score = self.score + self.bubble.amount * self.bubble.multiplier
  ctx.stats.maxCombo = math.max(ctx.stats.maxCombo, self.bubble.multiplier)
  self:resetBubble()

  ctx.stats.peoplePercentage = lume.round(ctx.stats.peopleKilled / ctx.stats.originalPeople, .01)
  ctx.stats.buildingPercentage = lume.round(ctx.stats.buildingsDestroyed / ctx.stats.originalBuildings, .01)
  ctx.stats.time = (ls.tick - ctx.startTick) * ls.tickrate

  self.win.active = true
  self.win.bonuses = {}
  collectgarbage()
  table.each(self.bonuses, function(bonus, name)
    if bonus.check and bonus.check() then
      table.insert(self.win.bonuses, name)
      self.score = self.score + bonus.score
    end
  end)
  table.each(self.bonuses, function(bonus, name)
    if bonus.postCheck and bonus.postCheck() then
      table.insert(self.win.bonuses, name)
      self.score = self.score + bonus.score
    end
  end)
  self.scoreDisplay = 0
end

function Hud:share()
  local level = ctx.map.name == 'dinoland' and 1 or 2
  level = tostring(level) .. '-' .. tostring(ctx.map.index)
  local url = 'http://twitter.com/intent/tweet?text=I%20got%20a%20new%20highscore%20of%20' .. math.round(self.scoreDisplay) .. '%20points%20on%20level%20' .. level .. '%20of%20%23FowlPlay!%20%23RobotPigeon'
  love.system.openURL(url)
end
