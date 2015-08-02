Hud = class()

function Hud:init()
  self.font = love.graphics.newFont('media/fonts/BebasNeueBold.otf', 24)
  ctx.event:emit('view.register', {object = self, mode = 'gui'})
end

function Hud:gui()
  local g = love.graphics
  local w, h = g.getDimensions()
  if ctx.debug then
    local x, y = ctx.view:worldPoint(love.mouse.getPosition())
    g.setFont(self.font)
    g.setColor(0, 0, 0)
    g.print(x .. ', ' .. y, 3, 3)
    g.setColor(255, 255, 255)
    g.print(x .. ', ' .. y, 2, 2)
    x, y = love.mouse.getPosition()
    g.line(x, 0, x, h)
    g.line(0, y, w, y)
  end
end
