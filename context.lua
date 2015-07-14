Context = {
  list = {},
  started = false
}

function Context:add(obj, ...)
  local c = obj(...)
  table.insert(self.list, c)

  local tmp = ctx
  ctx = c
  lume.call(ctx.load, ctx, ...)
  ctx = tmp

  return c
end

function Context:run(key, ...)
  for i = #self.list, 1, -1 do
    ctx = self.list[i]
    if key == 'update' then
      ctx.tick = (ctx.tick or 0) + 1
    end
    tick = ctx.tick or 0
    if ctx[key] then ctx[key](ctx, ...) end
    ctx = nil
    tick = nil
  end
end

function Context:remove(ctx, ...)
  for i = 1, #self.list do
    if self.list[i] == ctx then
      lume.call(ctx.unload, ctx, ...)
      table.remove(self.list, i)
      collectgarbage()
      return
    end
  end
end

function Context:clear()
  table.each(self.list, f.cur(self.remove, self))
end

function Context:bind(initial, ...)
  love.update = Context.update
  love.draw = Context.draw
  love.quit = Context.quit

  love.handlers = setmetatable({}, {__index = Context})

  if initial then
    Context:add(initial, ...)
  end
end

setmetatable(Context, {
  __index = function(t, k)
    return function(...) return t:run(k, ...) end
  end
})
