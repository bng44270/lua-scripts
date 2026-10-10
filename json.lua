local json = require("dkjson")
local M = {}

M.loads = function(jstr)
    local data, _, _ = json.decode(jstr)
    return data
end

M.dumps = function(t)
    return json.encode(t)
end

M.load = function(f)
    local file = io.open(f,"r")

    if not file then
        return
    end

    jstr = file:read("*a")
    file:close()

    return M.loads(jstr)
end

M.dump = function(t,f)
    local jstr = M.dumps(t)

    local file,_ = io.open(f,"w")

    if file then
        file:write(jstr)
        file:close()
    end
end

return M