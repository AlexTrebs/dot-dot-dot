#!/bin/bash
set -e

echo "==> Installing Ruby and Rails on Arch Linux"
echo ""

# Install system dependencies
echo "==> Installing system dependencies..."
sudo pacman -S --needed --noconfirm libyaml base-devel openssl zlib readline

# Check if asdf is installed
if ! command -v asdf &> /dev/null; then
    echo "Error: asdf is not installed. Please install asdf-vm first:"
    echo "  sudo pacman -S asdf-vm"
    exit 1
fi

# Install Ruby
echo ""
echo "==> Installing Ruby latest version..."
RUBY_VERSION=$(asdf latest ruby)
echo "Installing Ruby ${RUBY_VERSION}..."
asdf install ruby latest

# Set Ruby version
echo ""
echo "==> Setting Ruby ${RUBY_VERSION} as active version..."
asdf set ruby ${RUBY_VERSION}

# Verify Ruby installation
echo ""
echo "==> Verifying Ruby installation..."
export PATH="$HOME/.asdf/shims:$PATH"
ruby --version
gem --version

# Install Rails
echo ""
echo "==> Installing Rails..."
gem install rails --no-user-install --install-dir "$HOME/.asdf/installs/ruby/${RUBY_VERSION}/lib/ruby/gems/3.4.0"

# Reshim to create Rails shim
echo ""
echo "==> Creating shims..."
asdf reshim ruby

# Verify Rails installation
echo ""
echo "==> Verifying Rails installation..."
rails --version

# Update .bashrc if needed
echo ""
echo "==> Checking .bashrc configuration..."
if ! grep -q "export PATH=\"\$HOME/.asdf/shims:\$PATH\"" ~/.bashrc; then
    echo "Adding asdf shims to .bashrc..."
    echo "" >> ~/.bashrc
    echo "# asdf" >> ~/.bashrc
    echo "export PATH=\"\$HOME/.asdf/shims:\$PATH\"" >> ~/.bashrc
    echo "Added to .bashrc"
else
    echo "asdf shims already in .bashrc"
fi

echo ""
echo "==> Installation complete!"
echo ""
echo "Ruby version: $(ruby --version)"
echo "Gem version: $(gem --version)"
echo "Rails version: $(rails --version)"
echo ""
echo "To use Ruby and Rails in new terminals, run:"
echo "  source ~/.bashrc"
