--*******************************
-- DataDef - create schema enforced JSON format
--
-- Usage:
--      Initialize DataDef:
--          local dd = require("datadef")
--
--      Create an empty configuration (schema is stored in "schema.json" and data is stored in "data.json"):
--          dd.new()
--
--      Create an empty configuration with custom file names:
--          dd.new("custom_schema.json","custom_data.json")
--
--      Read configuration from default filenames:
--          dd.read()
--
--      Read configuration from default filenames:
--          dd.read("custom_schema.json","custom_data.json")
--
--      Create a new schema:
--          local s = {}
--          s.age = "StringType"
--          s.age = "NumberType"
--          s.name = "StringType"
--          dd.setschema(s)
--
--      Add a data row:
--          dd.insert({name="Dan",age=32})
--          dd.insert({name="Jane",age=75})
--
--      Write data and schema to files:
--          dd.write()
--*******************************

local json = require("dkjson")

local tab2str = function(t)
    local fs = ""
    for k,v in pairs(t) do
        fs = fs .. k .. ":" .. v .. " , "
    end
    return fs
end

local load_json = function(f)
    local file = io.open(f,"r")

    if not file then
        return
    end

    jstr = file:read("*a")
    file:close()

    local data, _, _ = json.decode(jstr)
    return data
end

local dump_json = function(t,f)
    local jstr = json.encode(t)

    local file,_ = io.open(f,"w")

    if file then
        file:write(jstr)
        file:close()
    end
end

local file_exists = function(f)
    local h = io.open(f,"r")
    if h then
        h:close()
        return true
    else
        return false
    end
end



M = {}
local M_VALIDTYPES = { StringType = "string", NumberType = "number", BooleanType = "boolean"}
local M_FIELDS = {}
local M_DATA = nil
local M_SCHEMA_FILE = ""
local M_DATA_FILE = ""


M._fieldexists = function(f)
    e = false
    for k,_ in pairs(M_FIELDS) do
        if k == f then
            e = true
        end
    end
    return e
end

M._checkfieldtype = function(t)
    v = false
    for k,_ in pairs(M_VALIDTYPES) do
        if k == t then
            v = true
        end
    end
    return v
end

M._checkdatatype = function(f,v)
    if type(v) == M_VALIDTYPES[M_FIELDS[f]] then
        return true
    else
        return false
    end
end

M._checkchema = function(f)
    for _,k in pairs(f) do
        if not M._checkfieldtype(k) then
            return false
        end
    end

    return true
end

M._validrecord = function(r)
    ok = true
    for k,v in pairs(r) do
        if not M._checkfieldtype(M_FIELDS[k]) or not M._fieldexists(k) or not M._checkdatatype(k,v) then
            ok = false
        end
    end
    
    return ok
end

M.getschema = function()
    return M_FIELDS
end

M.setschema = function(f)
    if M._checkchema(f) then
        M_FIELDS = f
    else
        local fs = tab2str(f)
        print("Schema error (" .. fs .. ")")
    end
end

M.getdata = function()
    return M_DATA
end

M.addfield = function(n,t)
    if not M._checkfieldtype(t) then
        print("Incorrect field type (" .. n .. ":" .. t .. ")")
    elseif M._fieldexists(n) then
        print("Fields Exists (" .. n .. ")")
    else
        M_FIELDS[n] = t
    end
end

M.insert = function(r)
    if not M._validrecord(r) then
        local ds = tab2str(r)
        print("Invalid record (" .. df .. ")")
    elseif type(r) ~= "table" then
        print("Row is not a table")
    else
        table.insert(M_DATA,r)
    end
end

M.new = function(sf,df)
    M_FIELDS = {}
    M_DATA = {}
    M_SCHEMA_FILE = sf or "schema.json"
    M_DATA_FILE = df or "data.json"
end

M.read = function(sf,df)
    M_SCHEMA_FILE = sf or "schema.json"
    M_DATA_FILE = df or "data.json"

    if file_exists(M_SCHEMA_FILE) then
        M_FIELDS = load_json(M_SCHEMA_FILE)
    end

    if file_exists(M_DATA_FILE) then
        M_DATA = load_json(M_DATA_FILE)
    end
end

M.write = function()
    dump_json(M_FIELDS,M_SCHEMA_FILE)
    dump_json(M_DATA,M_DATA_FILE)
end

return M