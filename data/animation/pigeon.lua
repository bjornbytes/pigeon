local Pigeon = extend(Animation)

Pigeon.scale = .15
Pigeon.default = nil
Pigeon.states = {}

Pigeon.states.idle = {
  loop = true,
  priority = 1
}

Pigeon.states.peck = {
  loop = false,
  priority = 2
}

return Pigeon
