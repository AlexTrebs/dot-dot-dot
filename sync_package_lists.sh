#!/usr/bin/env bash
# Sync package lists between install.sh and archinstall.yaml
set -euo pipefail

# Always run from repo root regardless of where script is called from
cd "$(dirname "$0")"

# Clean up temp files on exit
trap 'rm -f /tmp/install_main.txt /tmp/install_aur.txt /tmp/install_all.txt /tmp/arch_pkg.txt /tmp/unified_packages.txt' EXIT

echo "🔍 Analyzing package lists..."

# Extract packages from install.sh
awk '/^packages=\(/,/^\)/{if($0 ~ /"/) print}' install.sh | \
  grep -oE '"[^"]+"' | tr -d '"' | sort > /tmp/install_main.txt

# Extract AUR packages from install.sh
awk '/^aur_packages=/,/\)/{if($0 ~ /"/) print}' install.sh | \
  grep -oE '"[^"]+"' | tr -d '"' | sort > /tmp/install_aur.txt

# Combine all install.sh packages
cat /tmp/install_main.txt /tmp/install_aur.txt | sort -u > /tmp/install_all.txt

# Extract packages from archinstall.yaml
jq -r '.packages[]' archinstall.yaml | sort > /tmp/arch_pkg.txt

# Find differences
echo ""
echo "📊 Summary:"
echo "  install.sh:        $(wc -l < /tmp/install_all.txt) packages"
echo "  archinstall.yaml:  $(wc -l < /tmp/arch_pkg.txt) packages"
echo ""

missing_from_arch=$(comm -23 /tmp/install_all.txt /tmp/arch_pkg.txt)
missing_from_install=$(comm -13 /tmp/install_all.txt /tmp/arch_pkg.txt)

if [[ -n "$missing_from_arch" ]]; then
  echo "⚠️  Missing from archinstall.yaml:"
  echo "$missing_from_arch" | sed 's/^/   - /'
  echo ""
fi

if [[ -n "$missing_from_install" ]]; then
  echo "⚠️  Missing from install.sh:"
  echo "$missing_from_install" | sed 's/^/   - /'
  echo ""
fi

if [[ -z "$missing_from_arch" ]] && [[ -z "$missing_from_install" ]]; then
  echo "✅ Package lists are in sync!"
  exit 0
fi

# Offer to sync
read -p "Would you like to sync the package lists? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "❌ Sync cancelled"
  exit 0
fi

# Create unified package list (union of both)
cat /tmp/install_all.txt /tmp/arch_pkg.txt | sort -u > /tmp/unified_packages.txt

echo "📝 Updating archinstall.yaml..."
jq --argjson pkgs "$(jq -R -s 'split("\n") | map(select(length > 0))' /tmp/unified_packages.txt)" \
  '.packages = $pkgs' archinstall.yaml > archinstall.yaml.tmp
mv archinstall.yaml.tmp archinstall.yaml

if [[ -n "$missing_from_install" ]]; then
  echo ""
  echo "⚠️  The following packages are in archinstall.yaml but not install.sh:"
  echo "$missing_from_install" | sed 's/^/   - /'
  echo ""
  echo "   Add them manually to the correct section (packages or aur_packages) in install.sh."
  echo "   install.sh was NOT modified automatically — its section structure must be preserved."
fi

echo "✅ archinstall.yaml updated. Review install.sh if packages were listed above."
