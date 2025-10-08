#!/bin/bash

echo "Installing Ziaan Obfuscator..."

# Check if Lua is installed
if ! command -v lua &> /dev/null; then
    echo "❌ Lua is not installed. Please install Lua 5.1 or later."
    exit 1
fi

# Create directories if they don't exist
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/share/ziaan

# Copy files
cp ziaan.lua $PREFIX/share/ziaan/
cp cli.lua $PREFIX/bin/ziaan

# Make executable
chmod +x $PREFIX/bin/ziaan

# Create configuration
echo "Creating configuration..."

echo "#!/bin/bash" > $PREFIX/bin/ziaan-cli
echo "lua $PREFIX/bin/ziaan \"\$@\"" >> $PREFIX/bin/ziaan-cli
chmod +x $PREFIX/bin/ziaan-cli

echo ""
echo "✅ Ziaan Obfuscator installed successfully!"
echo ""
echo "Usage:"
echo "  ziaan input.lua output.lua"
echo "  ziaan-cli input.lua output.lua"
echo ""
echo "Examples:"
echo "  ziaan script.lua protected_script.lua"
echo "  ziaan game.lua protected_game.lua --no-junk"
echo ""
echo "Restart your terminal or run: source ~/.bashrc"
