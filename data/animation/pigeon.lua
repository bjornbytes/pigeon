local Pigeon = extend(Animation)

Pigeon.scale = .4
Pigeon.default = 'idle'
Pigeon.states = {}

Pigeon.states.idle = {
  loop = true
}

Pigeon.states.walk = {
  loop = true,
  speed = .85,
  mix = {
    walk = .2
  }
}

Pigeon.states.peck = {
  loop = false,
  speed = 1
}

Pigeon.states.jump = {
  loop = false,
  speed = .85
}

Pigeon.states.fly = {
  loop = false
}

Pigeon.states.laserStart = {
  loop = false,
  speed = 1
}

Pigeon.states.laserCharge = {
  loop = true
}

Pigeon.states.laserEnd = {
  loop = false
}

return Pigeon
