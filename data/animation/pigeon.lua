local Pigeon = extend(Animation)

Pigeon.scale = .3
Pigeon.default = 'idle'
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
