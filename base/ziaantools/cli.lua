#!/usr/bin/lua

local Ziaan = require("ziaan")

local function print_banner()
    print([[
    
███████╗██╗ █████╗ █████╗ ███╗   ██╗
╚══███╔╝██║██╔══██╗██╔══██╗████╗  ██║
  ███╔╝ ██║███████║███████║██╔██╗ ██║
 ███╔╝  ██║██╔══██║██╔══██║██║╚██╗██║
███████╗██║██║  ██║██║  ██║██║ ╚████║
╚══════╝╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝
                                     
   Advanced Obfuscator for Lua/Roblox
           Version 2.0
    ]])
end

local function print_help()
    print([[
Usage: ziaan [input_file] [output_file] [options]

Options:
  -h, --help          Show this help message
  -v, --version       Show version information
  --no-vm             Disable VM protection
  --no-junk           Disable junk code injection
  --no-tamper         Disable anti-tamper protection
  --no-debug          Disable anti-debug protection

Examples:
  ziaan script.lua protected_script.lua
  ziaan game.lua protected_game.lua --no-junk
  ziaan -v
    ]])
end

local function main()
    local args = {...}
    
    if #args == 0 or args[1] == "-h" or args[1] == "--help" then
        print_banner()
        print_help()
        return
    end
    
    if args[1] == "-v" or args[1] == "--version" then
        print("Ziaan Obfuscator v2.0")
        print("Full VM Protection for Lua 5.1 & Roblox")
        return
    end
    
    if #args < 2 then
        print("❌ Error: Please specify input and output files")
        print("Usage: ziaan <input> <output>")
        return
    end
    
    local input_file = args[1]
    local output_file = args[2]
    
    -- Process command line options
    for i = 3, #args do
        if args[i] == "--no-vm" then
            Ziaan.config.vm_protection = false
        elseif args[i] == "--no-junk" then
            Ziaan.config.junk_code = false
        elseif args[i] == "--no-tamper" then
            Ziaan.config.anti_tamper = false
        elseif args[i] == "--no-debug" then
            Ziaan.config.debug_protection = false
        end
    end
    
    print_banner()
    print("🔒 Starting Ziaan Obfuscation...")
    print("📁 Input:  " .. input_file)
    print("📁 Output: " .. output_file)
    print("")
    print("⚡ Configuration:")
    print("   VM Protection: " .. (Ziaan.config.vm_protection and "✅ ENABLED" or "❌ DISABLED"))
    print("   Junk Code:     " .. (Ziaan.config.junk_code and "✅ ENABLED" or "❌ DISABLED"))
    print("   Anti-Tamper:   " .. (Ziaan.config.anti_tamper and "✅ ENABLED" or "❌ DISABLED"))
    print("   Debug Protect: " .. (Ziaan.config.debug_protection and "✅ ENABLED" or "❌ DISABLED"))
    print("")
    
    -- Validate input file
    local test_file = io.open(input_file, "r")
    if not test_file then
        print("❌ Error: Cannot read input file: " .. input_file)
        return
    end
    local original_content = test_file:read("*a")
    test_file:close()
    
    -- Process obfuscation
    print("🔄 Obfuscating code...")
    local success, result = pcall(function()
        return Ziaan.obfuscate(original_content)
    end)
    
    if not success then
        print("❌ Obfuscation failed: " .. result)
        return
    end
    
    -- Save obfuscated file
    local save_ok, save_err = pcall(function()
        Ziaan.save_file(output_file, result)
    end)
    
    if not save_ok then
        print("❌ Failed to save output: " .. save_err)
        return
    end
    
    print("")
    print("✅ Obfuscation completed successfully!")
    print("📊 Statistics:")
    print("   Original size:  " .. #original_content .. " bytes")
    print("   Obfuscated size: " .. #result .. " bytes")
    print("   Protection level: 🔒🔒🔒🔒🔒")
    print("🚀 File saved: " .. output_file)
end

-- Run main function
if arg then
    main()
end
