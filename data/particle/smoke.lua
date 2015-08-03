local Smoke = class()
Smoke.image = data.media.graphics.particles.smoke
Smoke.max = 64
Smoke.blendMode = 'alpha'

Smoke.options = {}
Smoke.options.particleLifetime = {.5}
Smoke.options.colors = {{0, 0, 0, 15}, {0, 0, 0, 0}}
Smoke.options.sizes = {1, 1.5}
Smoke.options.sizeVariation = .4
Smoke.options.areaSpread = {'normal', 10, 10}
Smoke.options.rotation = {0, 2 * math.pi}
Smoke.options.spin = {-10, 10}
Smoke.options.speed = {100, 200}

return Smoke
