Zone = class()

function Zone:init(x)
  self.x = x
  self.enemies = {}
  self.active = true
end

function Zone:update()
  if table.count(self.enemies) == 0 then
    self.active = false
  end
end
