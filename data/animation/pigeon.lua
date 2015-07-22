local Pigeon = extend(Animation)

Pigeon.scale = .5
Pigeon.default = 'idle'
Pigeon.states = {}

Pigeon.states.idle = {
  loop = true
}

Pigeon.states.walk = {
  loop = true
}

Pigeon.states.peck = {
  loop = false
}

Pigeon.states.jump = {
  loop = false
}

Pigeon.states.fly = {
  loop = false
}

Pigeon.states.laser = {
  loop = false
}

return Pigeon
