Hud = class()

function Hud:init()
  ctx.event:emit('view.register', {object = self, mode = 'gui'})

  self.score = 0
  self.scoreDisplay = self.score

  self.bubble = {}
  self:resetBubble()
end

function Hud:update()
  self.bubble.prevy = self.bubble.y
  self.bubble.prevScale = self.bubble.scale
  self.bubble.prevTimer = self.bubble.timer

  if self.bubble.active then
    self.bubble.y = math.lerp(self.bubble.y, self.bubble.targetY, 12 * ls.tickrate)
    self.bubble.scale = math.lerp(self.bubble.scale, self.bubble.targetScale, 12 * ls.tickrate)

    self.bubble.amountDisplay = math.lerp(self.bubble.amountDisplay, self.bubble.amount, 12 * ls.tickrate)

    self.bubble.timer = timer.rot(self.bubble.timer, function()
      self.score = self.score + self.bubble.amount * self.bubble.multiplier
      self:resetBubble()
    end)
  end

  self.scoreDisplay = math.lerp(self.scoreDisplay, self.score, 5 * ls.tickrate)
end

function Hud:gui()
  local g = love.graphics
  local gw, gh = g.getDimensions()
  if ctx.debug then
    local x, y = ctx.view:worldPoint(love.mouse.getPosition())
    g.setFont('media/fonts/BebasNeueBold.otf', 24)
    g.setColor(0, 0, 0)
    g.print(x .. ', ' .. y, 3, 3)
    g.setColor(255, 255, 255)
    g.print(x .. ', ' .. y, 2, 2)
    x, y = love.mouse.getPosition()
    g.line(x, 0, x, gh)
    g.line(0, y, gw, y)
  end

  g.setFont('media/fonts/BebasNeueBold.otf', 24)
  g.setColor(0, 0, 0, 150)
  local str = math.round(self.scoreDisplay)
  local w = math.max(g.getFont():getWidth(str), 80)
  local h = g.getFont():getHeight()
  g.rectangle('fill', 0, 0, w + 8, h + 8)
  g.setColor(255, 255, 255)
  g.print(str, 4, 4)

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
end

function Hud:resetBubble()
  self.bubble.active = false
  self.bubble.amount = 0
  self.bubble.timer = 0
  self.bubble.multiplier = 0
  self.bubble.targetY = 300
  self.bubble.y = self.bubble.targetY
  self.bubble.prevy = self.bubble.y
  self.bubble.targetScale = 1
  self.bubble.scale = self.bubble.targetScale
  self.bubble.prevScale = self.bubble.scale
end

function Hud:addScore(amount)
  self.bubble.active = true
  self.bubble.timer = 3
  self.bubble.amount = self.bubble.amount + amount
  self.bubble.amountDisplay = self.bubble.amount
  self.bubble.multiplier = self.bubble.multiplier + 1
  --self.bubble.scale = self.bubble.scale + .2
  self.bubble.targetScale = self.bubble.targetScale + .1
  self.bubble.targetY = math.lerp(self.bubble.targetY, 100, .2)
  self.bubble.prevTimer = self.bubble.timer
end
