--*******************************
-- Base64 Encoding/Decoding library
--
-- Usage:
--          local base64 = require("base64")
--
--          local encstr = base64.encode("This is a test String")
--          -- encstr = "VGhpcyBpcyBhIHRlc3QgU3RyaW5nCg=="
--
--          local decstr = base64.decode("VGhpcyBpcyBhIHRlc3QgU3RyaW5nCg==")
--          -- decstr = "This is a test String"
--*******************************

local char2bin = function(c)
    local b = {}
    local n = c:byte()
    local bytes = {128,64,32,16,8,4,2,1}
    for i = 1,#bytes do
        if n >= bytes[i] then
            table.insert(b,"1")
            n = n - bytes[i]
        else
            table.insert(b,"0")
        end
    end

    return table.concat(b,"")
end

local binbyte2char = function(b)
    return string.char(tonumber(b,2))
end

local int2sixbit = function(n)
    local b = {}
    local bytes = {32,16,8,4,2,1}
    for i = 1,#bytes do
        if n >= bytes[i] then
            n = n - bytes[i]
            table.insert(b,"1")
        else
            table.insert(b,"0")
        end
    end
    return table.concat(b,"")
end

local sixbit2int = function(b)
    local n = 0
    local bytes = {32,16,8,4,2,1}
    for i = 1,#bytes do
        if b:sub(i,i) == '1' then
            n = n + bytes[i]
        end
    end
    return n
end

M = {}
M.encode = function(s)
    local b64map = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'}
    local binar = {}
    for i = 1,#s do
        local c = s:sub(i,i)
        table.insert(binar,char2bin(c))
    end

    local binstr = table.concat(binar,"")
    
    local xtrabits = (#binstr % 6)
    local padlen = 0
    if xtrabits == 2 then
        padlen = 4
    else
        padlen = 2
    end

    for i = 1,padlen do
        binstr = binstr .. "0"
    end

    local padstr = ""
    for i = 1,(padlen / 2) do
        padstr = padstr .. "="
    end

    local b64data = {}
    for i = 1,#binstr,6 do
        local b64c = binstr:sub(i,i+5)
        table.insert(b64data,b64map[sixbit2int(b64c)+1])
    end
    
    return (table.concat(b64data,"") .. padstr)
end

M.decode = function(s)
    local b64map = {A=0,B=1,C=2,D=3,E=4,F=5,G=6,H=7,I=8,J=9,K=10,L=11,M=12,N=13,O=14,P=15,Q=16,R=17,S=18,T=19,U=20,V=21,W=22,X=23,Y=24,Z=25,a=26,b=27,c=28,d=29,e=30,f=31,g=32,h=33,i=34,j=35,k=36,l=37,m=38,n=39,o=40,p=41,q=42,r=43,s=44,t=45,u=46,v=47,w=48,x=49,y=50,z=51}
    local binar = {}

    local pad = s:match("^[^=]+([=]*)$")

    local unpads = s:sub(1,#s-#pad)

    for i = 1,#unpads do
        local b64bin = ""

        if unpads:sub(i,i) == "+" then
            b64bin = int2sixbit(62)
        elseif unpads:sub(i,i) == "/" then
            b64bin = int2sixbit(63)
        elseif unpads:sub(i,i) == "0" then
            b64bin = int2sixbit(52)
        elseif unpads:sub(i,i) == "1" then
            b64bin = int2sixbit(53)
        elseif unpads:sub(i,i) == "2" then
            b64bin = int2sixbit(54)
        elseif unpads:sub(i,i) == "3" then
            b64bin = int2sixbit(55)
        elseif unpads:sub(i,i) == "4" then
            b64bin = int2sixbit(56)
        elseif unpads:sub(i,i) == "5" then
            b64bin = int2sixbit(57)
        elseif unpads:sub(i,i) == "6" then
            b64bin = int2sixbit(58)
        elseif unpads:sub(i,i) == "7" then
            b64bin = int2sixbit(59)
        elseif unpads:sub(i,i) == "8" then
            b64bin = int2sixbit(60)
        elseif unpads:sub(i,i) == "9" then
            b64bin = int2sixbit(61)
        else
            b64bin = int2sixbit(b64map[unpads:sub(i,i)])
        end

        table.insert(binar,b64bin)
    end


    local binstr = table.concat(binar,"")
    local unpadbin = binstr:sub(1,#binstr-(#pad*2))
    
    local decstr = {}
    for i = 1,#unpadbin,8 do
        local binsub = unpadbin:sub(i,i+7)
        local asciichar = binbyte2char(binsub)
        table.insert(decstr,asciichar)
    end

    return table.concat(decstr,"")
end
   
return M
