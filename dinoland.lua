Dinoland = extend(Map)
Dinoland.width = 2400
Dinoland.height = 600

function Dinoland:init()
  self.zones = {}

  return Map.init(self)
end