Manager = class()

function Manager:init()
  self.objects = {}
end

function Manager:update()
  table.with(self.objects, 'update')
end

function Manager:paused()
  table.with(self.objects, 'paused')
end

function Manager:add(object)
  lume.call(object.activate, object)
  self.objects[object] = object

  return object
end

function Manager:remove(object)
  if not object then return end
  lume.call(object.deactivate, object)
  self.objects[object] = nil
end

function Manager:get(id)
  return self.objects[id]
end

function Manager:each(fn)
  lume.each(self.objects, fn)
end

function Manager:filter(fn)
  return lume.values(lume.filter(self.objects, fn))
end

function Manager:count()
  if not next(self.objects) then return 0 end
  return lume.count(self.objects)
end
