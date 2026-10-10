--*******************************
-- Simplified JSON library
-- based on Python json library and powered by dkjson
--
-- Usage:
--          local json = require("json")
--
--          local dict = json.loads("JSON-STRING")
--
--          local person = { name = "Jim", age = 53 }
--          local jstr = json.dumps(person)
--
--          local dict = json.load("/path/to/file.json")
--
--          local person = { name = "Jim", age = 53 }
--          local jstr = json.dumps(person,"/path/to/new.json")
--*******************************

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
