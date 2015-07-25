Hud = class()

function Hud:init()
  self.font = love.graphics.newFont(12)
  ctx.event:emit('view.register', {object = self, mode = 'gui'})
end

function Hud:gui()
  local g = love.graphics
  g.setColor(255, 255, 255)
  g.setFont(self.font)
  g.print(ctx.pigeon.fuel, 0, 0)

  if ctx.pigeon.state == ctx.pigeon.laser then
    local percent = math.min(ctx.pigeon.laser.charge / (ctx.pigeon.laser.active and ctx.pigeon.laserDuration or ctx.pigeon.laserChargeDuration), 1)
    local x, y = ctx.view:screenPoint(ctx.pigeon.body:getX(), ctx.pigeon.body:getY() - 100)
    local w, h = 80, 5
    g.setColor(255, 255, 255, 80)
    g.rectangle('fill', x - w / 2, y - h / 2, w * percent, h)
    g.setColor(255, 255, 255)
    g.rectangle('line', x - w / 2, y - h / 2, w, h)
  end
end
