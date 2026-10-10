--**********************************
--Lua Wrapper for SQLite binary 
--
-- Setup:
--
--       local db = require("sqlite")
--       db.connect("/path/to/file.db")
--       
-- Create Table:
--
--       local people_table = { name = "TEXT", age = "INT"}
--       db.new_table("people",people_table)
--
-- Query:
--
--       local p = db.select("people")              --select all fields
--       local p = db.select("people",{"name"})     --select only the "name" fields
--       local p = db.select("people",{},{{"name","LIKE","%an%"}})        --select all fields on records where name contains "an"
--       local p = db.select("people",{"name"},{{"age",">",60}})          --select name field where age > 60
--
-- Insert:
--
--       local rec = { name = "Jim", age = 63 }
--       db.insert("people",rec)
--
-- Update:
--
--       db.update("people",{ age = 40 },{{"name","=","Jim"}})    --update the age to 40 where name = Jim
--
-- Delete:
--
--       db.delete("people")          --delete all entries in table
--       db.delete("people",{{"age","=","100"}})   --delete entries where age = 100
--**********************************

local M = {}
local M_DBFULE = ""
local M_TABLES = {}

M._runsql = function(sql,f)
    local is_select,_ = string.find(sql,'^SELECT')

    if is_select then
        local h = io.popen("sqlite3 -quote -separator '|' " .. M_DBFULE .. " '" .. sql .. "'")
        local recs = {}
        for r in h:lines() do
            local tr = M._split_rec(r)
            table.insert(recs,tr)
        end
        return recs
    else
        local r,_,_ = os.execute("sqlite3 -quote -separator '|' " .. M_DBFULE .. " '" .. sql .. "'")
        if r == 0 then
            return true
        else    
            return false
        end
    end
end

M._table_exists = function(tn)
    found = false
    for k,_ in pairs(M_TABLES) do
        if k == tn then
            found = true
        end
    end
    return found
end

M._split_rec = function(r,f)
    local vals = {}
    for str in string.gmatch(r,"([^|]+)") do
        local q,_ = string.find(str,"^\'")
        if q then
            local s = str:gsub("\'","")
            table.insert(vals,s)
        else
            table.insert(vals,tonumber(str))
        end
    end
    
    return vals
end

M._sqlite_exists = function()
    r,_,_ = os.execute("which sqlite3 > /dev/null")
    if r == 0 then
        return true
    else
        return false
    end
end

M._readconfig = function()
    local d = M._runsql("SELECT sql from sqlite_master;")
    for i = 1,#d do
        local t,fstr = d[i][1]:match("^CREATE TABLE[ \t]+([^%(]+)%(([^%)]+)%)$")
        local fields = {}
        for fd in fstr:gmatch("([^,]+)") do
            local fname = fd:match("^([^ \t]+).*$")
            table.insert(fields,fname)
        end
        M_TABLES[t] = fields
    end
end
    

M.connect = function(f)
    M_DBFULE = f
    M._readconfig()
end

M.get_tables = function()
    return M_TABLES
end

M.new_table = function(tn,f)
    if M._sqlite_exists() and not M._table_exists(tn) then
        use_fields = f or {}

        if #f > 0 then
            local fields = {}

            for i = 1,#use_fields do
                ftxt = use_fields[i][1] .. " " .. use_fields[i][2]
                table.insert(fields,ftxt)
            end

            local fstr = table.concat(fields,",")
            
            local sql = "CREATE TABLE " .. tn .. "(" .. fstr .. ");"

            return M._runsql(sql)
        else
            print("No fields specified")
        end
    else
        print("Binary or table not found")
    end
end

M.select = function(tn,f,q)
    if M._sqlite_exists() and M._table_exists(tn) then
        local use_fields = f or {}
        local use_query = q or {}
            
        local query = {}
        for i = 1,#use_query do
            local s = use_query[i][1] .. " " .. use_query[i][2] .. " "
            local v = use_query[i][3]
            if type(v) == "string" then
                s = s .. "\"" .. v .. "\""
            elseif type(v) == "number" then
                s = s .. tostring(v)
            end
            table.insert(query,s)
        end

        local qstr = ""
        if #query > 0 then
            qstr = " WHERE " .. table.concat(query,"AND")
        end

        local fstr = "*"
        if #use_fields > 0 then
            fstr = table.concat(f,",")
        end

        local sql = "SELECT " .. fstr .. " FROM " .. tn .. qstr .. ";"
        
        return M._runsql(sql)
    else
        print("Binary or table not found")
    end
end

M.delete = function(tn,w)
    if M._sqlite_exists() and M._table_exists(tn) then
        local use_where = w or {}
        local where = {}

        for i = 1,#use_where do
            local s = use_where[i][1] .. " " .. use_where[i][2] .. " "
            local v = use_where[i][3]
            if type(v) == "string" then
                s = s .. "\"" .. v .. "\""
            elseif type(v) == "number" then
                s = s .. tostring(v)
            end
            table.insert(where,s)
        end

        local wstr = " WHERE 1"
        if #use_where > 0 then
            wstr = " WHERE " .. table.concat(where," AND ")
        end


        local sql = "DELETE FROM " .. tn ..  wstr .. ";"
        
        if not M._runsql(sql) then
            print("Error updating record")
        end
    else
        print("Binary or table not found")
    end
end

M.update = function(tn,u,w)
    if M._sqlite_exists() and M._table_exists(tn) then
        local updates = {}

        for k,v in pairs(u) do
            local s = k .. "="
            if type(v) == "string" then
                s = s .. "\"" .. v .. "\""
            elseif type(v) == "number" then
                s = s .. tostring(v)
            end
            table.insert(updates,s)
        end

        local where = {}

        for i = 1,#w do
            local s = w[i][1] .. " " .. w[i][2] .. " "
            local v = w[i][3]
            if type(v) == "string" then
                s = s .. "\"" .. v .. "\""
            elseif type(v) == "number" then
                s = s .. tostring(v)
            end
            table.insert(where,s)
        end

        local upstr = table.concat(updates,",")

        local wstr = ""
        if #w > 0 then
            wstr = " WHERE " .. table.concat(where," AND ")
        end


        local sql = "UPDATE " .. tn .. " SET " .. upstr .. wstr .. ";"
        
        if not M._runsql(sql) then
            print("Error updating record")
        end
    else
        print("Binary or table not found")
    end
end

M.insert = function(tn,t)
    if M._sqlite_exists() and M._table_exists(tn) then
        local fields = {}
        local values = {}
        for k,v in pairs(t) do
            table.insert(fields,k)
            if type(v) == "string" then
                table.insert(values,"\"" .. v .. "\"")
            elseif type(v) == "number" then
                table.insert(values,tostring(v))
            end
        end

        local sql = "INSERT INTO " .. tn .. "(" .. table.concat(fields,",") .. ") VALUES (" .. table.concat(values,",") .. ");"

        if not M._runsql(sql) then
            print("Error inserting record")
        end
    else
        print("Binary or table not found")
    end
end

return M