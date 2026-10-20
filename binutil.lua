--*******************************
-- Binary Operations by byte, word, and double-word
--
-- Operations:
--
--      - AND
--      - OR
--      - NAND
--      - NOR
--      - XOR
--      - NOT
--
-- Usage:
--          local bin = require("binutil")
--
--          local result = bin.byteand(143,76)                      -- result = 12
--          local result = bin.wordand(12143,23676)                 -- result = 3180
--          local result = bin.doublewordand(34765123,972349872)    -- result = 1073408
--
--          -- Note that the following methods follow the above two-argument form
--          --     - byteor
--          --     - wordor
--          --     - doublewordor
--          --     - bytenor
--          --     - wordnor
--          --     - doublewordnor
--          --     - bytenand
--          --     - wordnand
--          --     - doublewordnand
--          --     - bytexor
--          --     - wordxor
--          --     - doublewordxor
--          --
--          -- Except for the "NOT" methods:
--
--          local result = bin.bytenot(93)               -- result = 162
--          local result = bin.wordnot(42753)            -- result = 22782
--          local result = bin.doublewordnot(32872846)   -- result = 4262094449
--*******************************

M = {}

M._getbits = function(l)
    local b = {}

    for i = l,1,-1 do
        local n = 2^(i-1)
        table.insert(b,n)
    end

    return b
end

M._binor = function(bits,a,b)
    local val = 0

    for i = 1,#bits do
        if a >= bits[i] or b >= bits[i] then
            val = val + bits[i]
        end
        if a >= bits[i] then
            a = a - bits[i]
        end
        if b >= bits[i] then
            b = b - bits[i]
        end
    end

    return val
end

M._binand = function(bits,a,b)
    local val = 0

    for i = 1,#bits do
        if a >= bits[i] and b >= bits[i] then
            val = val + bits[i]
        end
        if a >= bits[i] then
            a = a - bits[i]
        end
        if b >= bits[i] then
            b = b - bits[i]
        end
    end

    return val
end

M._binnor = function(bits,a,b)
    local val = 0

    for i = 1,#bits do
        if not (a >= bits[i] or b >= bits[i]) then
            val = val + bits[i]
        end
        if a >= bits[i] then
            a = a - bits[i]
        end
        if b >= bits[i] then
            b = b - bits[i]
        end
    end
    
    return val
end

M._binnand = function(bits,a,b)
    local val = 0

    for i = 1,#bits do
        if not (a >= bits[i] and b >= bits[i]) then
            val = val + bits[i]
        end
        if a >= bits[i] then
            a = a - bits[i]
        end
        if b >= bits[i] then
            b = b - bits[i]
        end
    end

    return val
end

M._binxor = function(bits,a,b)
    local val = 0

    for i = 1,#bits do
        if (a >= bits[i] or b >= bits[i]) and (not (a >= bits[i] and b >= bits[i])) then
            val = val + bits[i]
        end
        if a >= bits[i] then
            a = a - bits[i]
        end
        if b >= bits[i] then
            b = b - bits[i]
        end
    end

    return val
end

M._binnot = function(bits,a)
    local val = 0

    for i = 1,#bits do
        if not (a >= bits[i]) then
            val = val + bits[i]
        else
            a = a - bits[i]
        end  
    end

    return val
end

M.byteor = function(a,b)
    local bits = M._getbits(8)
    
    if a > 255 or b > 255 then
        error("Expected 8-bit values")
    end
    
    return M._binor(bits,a,b)
end

M.wordor = function(a,b)
    local bits = M._getbits(16)
    
    if a > 65535 or b > 65535 then
        error("Expected 16-bit values")
    end
    
    return M._binor(bits,a,b)
end

M.doublewordor = function(a,b)
    local bits = M._getbits(32)
    
    if a > 65535 or b > 65535 then
        error("Expected 32-bit values")
    end
    
    return M._binor(bits,a,b)
end

M.byteand = function(a,b)
    local bits = M._getbits(8)
    
    if a > 255 or b > 255 then
        error("Expected 8-bit values")
    end
    
    return M._binand(bits,a,b)
end

M.wordand = function(a,b)
    local bits = M._getbits(16)
    
    if a > 65535 or b > 65535 then
        error("Expected 16-bit values")
    end
    
    return M._binand(bits,a,b)
end

M.doublewordand = function(a,b)
    local bits = M._getbits(32)
    
    if a > 4294967295 or b > 4294967295 then
        error("Expected 32-bit values")
    end
    
    return M._binand(bits,a,b)
end

M.bytenor = function(a,b)
    local bits = M._getbits(8)
    
    if a > 255 or b > 255 then
        error("Expected 8-bit values")
    end
    
    return M._binnor(bits,a,b)
end

M.wordnor = function(a,b)
    local bits = M._getbits(16)
    
    if a > 65535 or b > 65535 then
        error("Expected 16-bit values")
    end
    
    return M._binnor(bits,a,b)
end

M.doublewordnor = function(a,b)
    local bits = M._getbits(32)
    
    if a > 4294967295 or b > 4294967295 then
        error("Expected 16-bit values")
    end
    
    return M._binnor(bits,a,b)
end

M.bytenand = function(a,b)
    local bits = M._getbits(8)
    
    if a > 255 or b > 255 then
        error("Expected 8-bit values")
    end
    
    return M._binnand(bits,a,b)
end

M.wordnand = function(a,b)
    local bits = M._getbits(16)
    
    if a > 65535 or b > 65535 then
        error("Expected 16-bit values")
    end
    
    return M._binnand(bits,a,b)
end

M.doublewordnand = function(a,b)
    local bits = M._getbits(32)
    
    if a > 4294967295 or b > 4294967295 then
        error("Expected 8-bit values")
    end
    
    return M._binnand(bits,a,b)
end

M.bytexor = function(a,b)
    local bits = M._getbits(8)
    
    if a > 255 or b > 255 then
        error("Expected 8-bit values")
    end
    
    return M._binxor(bits,a,b)
end

M.wordxor = function(a,b)
    local bits = M._getbits(16)
    
    if a > 65535 or b > 65535 then
        error("Expected 16-bit values")
    end
    
    return M._binxor(bits,a,b)
end

M.doublewordxor = function(a,b)
    local bits = M._getbits(32)
    
    if a > 4294967295 or b > 4294967295 then
        error("Expected 32-bit values")
    end
    
    return M._binxor(bits,a,b)
end

M.bytenot = function(a)
    local bits = M._getbits(8)
    
    if a > 255 then
        error("Expected 8-bit values")
    end
    
    return M._binnot(bits,a)
end

M.wordnot = function(a)
    local bits = M._getbits(16)
    
    if a > 65535 then
        error("Expected 16-bit values")
    end
    
    return M._binnot(bits,a)
end

M.doublewordnot = function(a)
    local bits = M._getbits(32)
    
    if a > 4294967295 then
        error("Expected 32-bit values")
    end
    
    return M._binnot(bits,a)
end


return M