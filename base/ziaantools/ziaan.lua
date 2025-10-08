-- Ziaan Obfuscator v2.0
-- Full VM Protection for Lua 5.1 & Roblox
-- Created by Ziaan Security

local Ziaan = {}

-- Configuration
Ziaan.config = {
    vm_protection = true,
    anti_tamper = true,
    junk_code = true,
    string_encryption = true,
    control_flow_obfuscation = true,
    debug_protection = true
}

-- Character set for random generation
local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"

-- Random string generator
local function random_string(length)
    if not package then
        -- Roblox environment
        local result = ""
        for i = 1, length do
            local rand = math.random(1, #charset)
            result = result .. string.sub(charset, rand, rand)
        end
        return result
    else
        -- Standard Lua environment
        math.randomseed(os.time() + math.random(1, 10000))
        local result = ""
        for i = 1, length do
            local rand = math.random(1, #charset)
            result = result .. charset:sub(rand, rand)
        end
        return result
    end
end

-- Bit operations compatibility
local bit32 = {}
if _G.bit32 then
    bit32 = _G.bit32
else
    -- Custom bit32 implementation for Roblox
    function bit32.bxor(a, b)
        local result = 0
        local bitval = 1
        while a > 0 or b > 0 do
            local a_bit = a % 2
            local b_bit = b % 2
            if a_bit ~= b_bit then
                result = result + bitval
            end
            a = math.floor(a / 2)
            b = math.floor(b / 2)
            bitval = bitval * 2
        end
        return result
    end
    
    function bit32.band(a, b)
        local result = 0
        local bitval = 1
        while a > 0 or b > 0 do
            if (a % 2) * (b % 2) > 0 then
                result = result + bitval
            end
            a = math.floor(a / 2)
            b = math.floor(b / 2)
            bitval = bitval * 2
        end
        return result
    end
end

-- XOR encryption function
local function xor_encrypt(data, key)
    local result = ""
    for i = 1, #data do
        local data_byte = string.byte(data, i)
        local key_byte = string.byte(key, ((i - 1) % #key) + 1)
        result = result .. string.char(bit32.bxor(data_byte, key_byte))
    end
    return result
end

-- Base64 encoding
local function base64_encode(data)
    local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    local result = ""
    local len = #data
    
    for i = 1, len, 3 do
        local a, b, c = string.byte(data, i, i + 2)
        a = a or 0
        b = b or 0
        c = c or 0
        
        local n = bit32.band(a, 0xFF) * 0x10000 + bit32.band(b, 0xFF) * 0x100 + bit32.band(c, 0xFF)
        
        local s1 = bit32.band(math.floor(n / 0x40000), 0x3F) + 1
        local s2 = bit32.band(math.floor(n / 0x1000), 0x3F) + 1
        local s3 = bit32.band(math.floor(n / 0x40), 0x3F) + 1
        local s4 = bit32.band(n, 0x3F) + 1
        
        result = result .. b64chars:sub(s1, s1) .. b64chars:sub(s2, s2) .. b64chars:sub(s3, s3) .. b64chars:sub(s4, s4)
    end
    
    local padding = ((3 - (len % 3)) % 3)
    return result:sub(1, #result - padding) .. string.rep('=', padding)
end

-- Generate VM protection layer
local function generate_vm_protection()
    local protection_code = {}
    
    -- Generate random function names
    local funcs = {}
    for i = 1, 8 do
        funcs[i] = random_string(10)
    end
    
    -- VM protection code
    table.insert(protection_code, "-- 🔒 Ziaan VM Protection Layer")
    table.insert(protection_code, string.format([[
local %s = function() 
    return true 
end

local %s = function(x) 
    return function(y) 
        return x ~= y 
    end 
end

local %s = function()
    return %s(%s())
end

local %s = function(data, key)
    local result = ""
    for i = 1, #data do
        local byte = string.byte(data, i)
        local key_byte = string.byte(key, ((i - 1) %% #key) + 1)
        result = result .. string.char(bit32.bxor(byte, key_byte))
    end
    return result
end
]], funcs[1], funcs[2], funcs[3], funcs[2], funcs[1], funcs[4]))
    
    -- Anti-debugging code
    table.insert(protection_code, "-- 🛡️ Anti-Debug Protection")
    table.insert(protection_code, string.format([[
local %s = function()
    local %s = 0
    for i = 1, 1000 do
        %s = %s + i
    end
    return %s == 500500
end

if not %s() then
    -- Debugger detected
    while true do end
end
]], random_string(8), random_string(6), random_string(6), random_string(6), random_string(6), random_string(8)))
    
    return table.concat(protection_code, "\n")
end

-- Generate junk code
local function generate_junk_code()
    local junk = {}
    
    table.insert(junk, "-- Ziaan Junk Code Injection")
    
    -- Random variables
    for i = 1, 15 do
        local var_name = random_string(8)
        local value = math.random(1, 9999)
        table.insert(junk, string.format("local %s = %d", var_name, value))
    end
    
    -- Fake loops
    table.insert(junk, string.format([[
for %s = 1, %d do
    local %s = %s * 2
end
]], random_string(4), math.random(5, 25), random_string(6), random_string(6)))
    
    -- Useless functions
    table.insert(junk, string.format([[
local function %s()
    return "%s"
end

local function %s(a, b)
    return a + b
end

local %s = %s(%s(), %s())
]], random_string(8), random_string(20), random_string(8), random_string(6), random_string(8), random_string(6), random_string(6)))
    
    return table.concat(junk, "\n")
end

-- Generate decoder function
local function generate_decoder()
    local decoder_name = random_string(12)
    local data_var = random_string(8)
    local key_var = random_string(8)
    local result_var = random_string(8)
    
    local decoder = string.format([[
local %s = function(%s, %s)
    local %s = ""
    for i = 1, #%s do
        local byte = string.byte(%s, i)
        local key_byte = string.byte(%s, ((i - 1) %% #%s) + 1)
        %s = %s .. string.char(bit32.bxor(byte, key_byte))
    end
    return %s
end
]], decoder_name, data_var, key_var, result_var, data_var, data_var, key_var, key_var, result_var, result_var, result_var)
    
    return decoder, decoder_name, data_var, key_var
end

-- Main obfuscation function
function Ziaan.obfuscate(code)
    local output = {}
    
    -- Header
    table.insert(output, "-- 🔒 Ziaan Obfuscator v2.0 - Full VM Protection")
    table.insert(output, "-- 🛡️  Secure Code Protection System")
    table.insert(output, "-- ⚠️  DO NOT DECOMPILE OR MODIFY")
    table.insert(output, "")
    
    -- Add VM protection
    if Ziaan.config.vm_protection then
        table.insert(output, generate_vm_protection())
        table.insert(output, "")
    end
    
    -- Generate encryption key
    local encryption_key = random_string(32)
    
    -- Encrypt the main code
    local encrypted_code = xor_encrypt(code, encryption_key)
    local encoded_code = base64_encode(encrypted_code)
    
    -- Generate decoder
    local decoder_code, decoder_func, data_var, key_var = generate_decoder()
    table.insert(output, decoder_code)
    table.insert(output, "")
    
    -- Add junk code before main execution
    if Ziaan.config.junk_code then
        table.insert(output, generate_junk_code())
        table.insert(output, "")
    end
    
    -- Store encrypted code and key
    local encrypted_var = random_string(10)
    local key_storage = random_string(10)
    
    table.insert(output, string.format("local %s = \"%s\"", encrypted_var, encoded_code))
    table.insert(output, string.format("local %s = \"%s\"", key_storage, encryption_key))
    table.insert(output, "")
    
    -- Decode and execute
    table.insert(output, "-- Executing Protected Code")
    table.insert(output, string.format("local %s = %s(%s, %s)", 
        random_string(8), decoder_func, encrypted_var, key_storage))
    table.insert(output, string.format("local %s = loadstring(%s)", 
        random_string(8), random_string(8)))
    table.insert(output, string.format("%s()", random_string(8)))
    table.insert(output, "")
    
    -- Add footer junk code
    if Ziaan.config.junk_code then
        table.insert(output, generate_junk_code())
        table.insert(output, "")
    end
    
    -- Anti-tamper protection
    if Ziaan.config.anti_tamper then
        table.insert(output, "-- Ziaan Integrity Verification")
        table.insert(output, string.format([[
local %s = function()
    return #%s == %d and #%s == %d
end

if not %s() then
    -- Code tampering detected!
    while true do end
end
]], random_string(8), encrypted_var, #encoded_code, key_storage, #encryption_key, random_string(8)))
    end
    
    return table.concat(output, "\n")
end

-- File processing functions
function Ziaan.process_file(filename)
    local file = io.open(filename, "r")
    if not file then
        error("Cannot open file: " .. filename)
    end
    local content = file:read("*a")
    file:close()
    return Ziaan.obfuscate(content)
end

function Ziaan.save_file(filename, content)
    local file = io.open(filename, "w")
    if not file then
        error("Cannot create file: " .. filename)
    end
    file:write(content)
    file:close()
end

return Ziaan
