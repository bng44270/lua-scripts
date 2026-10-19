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
--      Query rows:
--          local result = dd.query({name="Dan"})   --name is "Dan"
--          local result = dd.query({name="^J"})    --name begins with "J"
--          local result = dd.query({age=90})       --age is 75
--          -- result is a new DataDef instance
--
--      Add a data row:
--          dd.insert({name="Dan",age=32})
--          dd.insert({name="Jane",age=75})
--
--      Update a row:
--          dd.update({name="Dan"},{age=35})    --sets age to 35 where name is "Dan"
--
--      Write data and schema to files:
--          dd.write()
--*******************************

local json = require("dkjson")

local tab2str = function(t)
    local fs = ""
    for k,v in pairs(t) do
        local usev = ""
        if type(v) == "string" then
            usev = "\"" .. v .. "\""
        else
            usev = v
        end
        fs = fs .. k .. ":" .. usev .. " , "
    end
    fs,_ = fs:gsub(" , $","")
    return ("{" .. fs .. "}")
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

M._init = function(sf,df)
    M.VALIDTYPES = { StringType = "string", NumberType = "number", BooleanType = "boolean"}
    M.SCHEMA_FILE = sf or "schema.json"
    M.DATA_FILE = df or "data.json"
end

M._getdatatype = function(s)
    local t = ""
    for k,v in pairs(M.VALIDTYPES) do
        if s == v then
            t = k
        end
    end
    return t
end

M._fieldexists = function(f)
    e = false
    for k,_ in pairs(M.FIELDS) do
        if k == f then
            e = true
        end
    end
    return e
end

M._checkfieldtype = function(t)
    v = false
    for k,_ in pairs(M.VALIDTYPES) do
        if k == t then
            v = true
        end
    end
    return v
end

M._checkdatatype = function(f,v)
    if type(v) == M.VALIDTYPES[M.FIELDS[f]] then
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
        if not M._checkfieldtype(M.FIELDS[k]) or not M._fieldexists(k) or not M._checkdatatype(k,v) then
            ok = false
        end
    end
    
    return ok
end

M._getcount = function()
    return #M.DATA
end

M.getschema = function()
    return M.FIELDS
end

M.setschema = function(f)
    if M._checkchema(f) then
        M.FIELDS = f
    else
        local fs = tab2str(f)
        error("Schema error (" .. fs .. ")")
    end
end

M.addfield = function(n,t)
    if not M._checkfieldtype(t) then
        error("Incorrect field type (" .. n .. ":" .. t .. ")")
    elseif M._fieldexists(n) then
        error("Fields Exists (" .. n .. ")")
    else
        M.FIELDS[n] = t
    end
end

M.update = function(q,u)
    for i = 1,#M.DATA do
        local recmatch = true
        for qk,qv in pairs(q) do
            if not M._fieldexists(qk) then
                error("Field does not exist (" .. qk .. ")")
            end

            if M.DATA[i][qk] ~= qv and not M.DATA[i][qk]:match(qv) then
                recmatch = false
                break
            end
        end

        if recmatch then
            for uk,uv in pairs(u) do
                if not M._fieldexists(uk) then
                    error("Field does not exist (" .. uk .. ")")
                end
                if not M._checkdatatype(uk,uv) then
                    error("Invalid data type (" .. uk .. ":" .. M._getdatatype(type(uv)) .. ")")
                end

                M.DATA[i][uk] = uv
            end
        end
    end
end

M.query = function(q,sf,df)
    local use_data = M.DATA
    local use_schema = M.FIELDS
    
    local query_result = require("datadef")
    local use_schema_file = sf or "q_schema.json"
    local use_data_file = df or "q_data.json"
    query_result.new(use_schema_file,use_data_file)
    query_result.setschema(use_schema)
    
    for i = 1,#use_data do
        local recmatch = true
        for qk,qv in pairs(q) do
            if not M._fieldexists(qk) then
                error("Field does not exist (" .. qk .. ")")
            end
            if use_data[i][qk] ~= qv and not use_data[i][qk]:match(qv) then
                recmatch = false
                break
            end
        end

        if recmatch then
            query_result.insert(use_data[i])
        end
    end
    
    return query_result
end

M.insert = function(r)
    if type(r) ~= "table" then
        print("Row is not a table")
    elseif not M._validrecord(r) then
        local ds = tab2str(r)
        print("Invalid record (" .. ds .. ")")
    else
        table.insert(M.DATA,r)
    end
end

M.new = function(sf,df)
    M._init(sf,df)
    M.FIELDS = {}
    M.DATA = {}
end

M.read = function(sf,df)
    M._init(sf,df)

    if file_exists(M.SCHEMA_FILE) then
        M.FIELDS = load_json(M.SCHEMA_FILE)
    else
        error("File not found (" .. M.SCHEMA_FILE .. ")")
    end

    if file_exists(M.DATA_FILE) then
        M.DATA = load_json(M.DATA_FILE)
    else
        error("File not found (" .. M.DATA_FILE .. ")")
    end
end

M.write = function()
    dump_json(M.FIELDS,M.SCHEMA_FILE)
    dump_json(M.DATA,M.DATA_FILE)
end

return M