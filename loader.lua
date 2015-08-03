data = {}
data.load = function()

  -- Media
	local function lookup(ext, fn)
		local function halp(s, k)
			local base = s._path .. '/' .. k
      local function extLoad(ext)
        if love.filesystem.exists(base .. ext) then
          s[k] = fn(base .. ext)
        elseif love.filesystem.isDirectory(base) then
          local t = {}
          t._path = base
          setmetatable(t, {__index = halp})
          s[k] = t
        else
          return false
        end

        return true
      end

      if type(ext) == 'table' then
        lume.each(ext, function(e) return extLoad(e) end)
      else
        extLoad(ext)
      end

			return rawget(s, k)
		end

		return halp
	end

  data.media = {}
	data.media.graphics = setmetatable({_path = 'media/graphics'}, {__index = lookup({'.png', '.dds'}, love.graphics and love.graphics.newImage or f.empty)})

  -- Data
  local function load(dir, type, fn)
    local id = 1
    local function halp(dir, dst)
      for _, file in ipairs(love.filesystem.getDirectoryItems(dir)) do
        path = dir .. '/' .. file
        if love.filesystem.isDirectory(path) then
          dst[file] = {}
          halp(path, dst[file])
        elseif file:match('%.lua$') and not file:match('^%.') then
          local obj = love.filesystem.load(path)()
          assert(obj, path .. ' did not return a value')
          obj.code = obj.code or file:gsub('%.lua', '')
          obj.id = id
          obj = lume.call(fn, obj) or obj
          data[type][id] = obj
          dst[obj.code] = obj
          id = id + 1
        end
      end
    end

    data[type] = {}
    halp(dir, data[type])
  end

  load('data/animation', 'animation', function(animation)

    -- Set up lazy loading for images
    local code = animation.code
    animation.graphics = setmetatable({_path = 'media/skeletons/' .. code}, {
      __index = lookup({'.png', '.dds'}, function(path)
        local img = love.graphics.newImage(path)
        if path:match('%.dds') then img:setMipmapFilter('nearest', 1) end
        return img
      end)
    })

    -- Set up static spine data structures
    local s = {}
    s.__index = s
    if love.filesystem.exists('media/skeletons/' .. code .. '/' .. code .. '.atlas') then
      s.atlas = spine.Atlas.new('media/skeletons/' .. code .. '/' .. code .. '.atlas')
      s.atlasAttachmentLoader = spine.AtlasAttachmentLoader.new(s.atlas)
    end
    s.json = spine.SkeletonJson.new(s.atlasAttachmentLoader)
    s.skeletonData = s.json:readSkeletonDataFile('media/skeletons/' .. code .. '/' .. code .. '.json')
    s.animationStateData = spine.AnimationStateData.new(s.skeletonData)

    -- Reverse-index keys (sorted for consistent order)
    local keys = lume.keys(animation.states)
    table.sort(keys)

    for i = 1, #keys do
      local state = animation.states[keys[i]]
      animation.states[i] = state
      state.index = i
      state.name = keys[i]
    end

    -- Set mixes
    for i = 1, #animation.states do
      table.each(animation.states, function(state)
        if state.index ~= i then
          s.animationStateData:setMix(animation.states[i].name, state.name, Animation.defaultMix)
        end
      end)

      table.each(animation.states[i].mix or {}, function(time, to)
        s.animationStateData:setMix(animation.states[i].name, to, time)
      end)
    end

    animation.spine = s

    return animation
  end)

  load('data/particle', 'particle')
end

