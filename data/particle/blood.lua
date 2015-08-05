local Blood = class()
Blood.image = data.media.graphics.particles.softCircle
Blood.max = 1024
Blood.blendMode = 'alpha'

Blood.options = {}
Blood.options.particleLifetime = {1}
Blood.options.colors = {{220, 0, 0, 100}}
Blood.options.sizes = {.3}
Blood.options.sizeVariation = .5
Blood.options.areaSpread = {'normal', 4, 4}
Blood.options.direction = -math.pi / 2
Blood.options.spread = math.pi / 4
Blood.options.speed = {500, 800}
Blood.options.linearAcceleration = {0, 1500, 0, 2000}

return Blood
