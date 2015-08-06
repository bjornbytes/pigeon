local RainbowShit = class()
RainbowShit.image = data.media.graphics.particles.star
RainbowShit.max = 1024
RainbowShit.blendMode = 'additive'

RainbowShit.options = {}
RainbowShit.options.colors = {{255, 255, 255, 80}, {255, 255, 255, 0}}
RainbowShit.options.particleLifetime = {.5}
RainbowShit.options.sizes = {1, .1}
RainbowShit.options.sizeVariation = .4
RainbowShit.options.areaSpread = {'normal', 10, 10}
RainbowShit.options.rotation = {0, 2 * math.pi}
RainbowShit.options.spin = {-10, 10}
RainbowShit.options.speed = {100, 200}

return RainbowShit
