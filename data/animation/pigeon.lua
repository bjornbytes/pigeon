local Pigeon = extend(Animation)

Pigeon.scale = .6
Pigeon.default = 'idle'
Pigeon.states = {}

Pigeon.states.idle = {
  loop = true
}

Pigeon.states.walk = {
  loop = true,
  speed = .75
}

Pigeon.states.peck = {
  loop = false,
  speed = 1.5
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
