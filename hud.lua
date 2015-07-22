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
end
