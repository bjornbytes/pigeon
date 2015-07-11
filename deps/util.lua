f = {}
f.exe = function(x, ...) if type(x) == 'function' then return x(...) end return x end
