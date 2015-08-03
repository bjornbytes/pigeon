local Dust = class()
Dust.image = data.media.graphics.particles.smoke
Dust.max = 64
Dust.blendMode = 'additive'

Dust.options = {}
Dust.options.particleLifetime = {.5}
Dust.options.colors = {{80, 40, 0, 100}, {80, 40, 0, 0}}
Dust.options.sizes = {.6, 1}
Dust.options.sizeVariation = .1
Dust.options.areaSpread = {'normal', 24, 16}
Dust.options.rotation = {0, 2 * math.pi}

return Dust
