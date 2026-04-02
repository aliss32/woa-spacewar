#!/bin/bash
# Hata durumunda dur
set -e

echo "========================================================"
echo "      Spacewar UEFI Local Builder (WSL / Ubuntu)        "
echo "========================================================"

# Windows satır sonlarını (CRLF) Linux tipine (LF) zorla dönüştür (Kendi kendini düzeltme)
sed -i 's/\r$//' "$0"

BUILD_DIR=~/spacewar_build
WINDOWS_DIR="$(pwd)"

echo -e "\n[1/5] Ubuntu bagimliliklari kontrol ediliyor..."
sudo apt-get update -y
sudo apt-get install -y --no-install-recommends \
    gcc-aarch64-linux-gnu nasm lld clang llvm uuid-dev build-essential git ca-certificates python3 python3-pip python3-venv dos2unix mono-devel

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

echo -e "\n[2/5] Mu-Silicium Hazirlaniyor..."
if [ -d "Mu-Silicium" ]; then
    echo "Eski dizin temizleniyor..."
    rm -rf Mu-Silicium
fi

echo "Repository klonlaniyor (depth 1)..."
git clone https://github.com/Project-Silicium/Mu-Silicium.git --recursive --depth 1

echo -e "\n[3/5] Yerel Yamalar Uygulaniyor (Memory & USB Host)..."
# Yamaları Windows dizininden alıp Linux build dizinine kopyalar
cp "$WINDOWS_DIR/UEFI/upstream_overrides/MemoryMapLib.c" \
   "Mu-Silicium/Platforms/Nothing/spacewarPkg/Library/MemoryMapLib/MemoryMapLib.c"

cp "$WINDOWS_DIR/UEFI/upstream_overrides/ConfigurationMapLib.c" \
   "Mu-Silicium/Platforms/Nothing/spacewarPkg/Library/ConfigurationMapLib/ConfigurationMapLib.c"

# TrustZone SMC çökmelerini engelleyen yama
find Mu-Silicium -type f \( -name "*.dsc" -o -name "*.fdf" -o -name "*.inc" \) \
    -exec sed -i '/MinidumpTADxe/d' {} +

echo -e "\n[4/5] Python Ortami Kuruluyor..."
python3 -m venv uefi_venv
source uefi_venv/bin/activate
pip install --no-cache-dir -r Mu-Silicium/pip-requirements.txt

echo -e "\n[5/5] UEFI Derleniyor (DEBUG Modu)..."
export CLANGPDB_AARCH64_PREFIX=aarch64-linux-gnu-
cd Mu-Silicium
# Stuart build sistemini baslat
bash ./build_uefi.sh -d spacewar -r DEBUG

echo "========================================================"
echo "    Derleme Tamamlandi! Dosyalar Windows'a Tasiniyor... "
echo "========================================================"
cp Mu-spacewar*.img "$WINDOWS_DIR/" 2>/dev/null || echo "UYARI: Mu-spacewar*.img bulanamadi, lutfen Build dizinini kontrol edin."
cp Build/build_output.log "$WINDOWS_DIR/build_local.log" 2>/dev/null || true

echo -e "\nIslem bitti! Yeni UEFI imajini 'woa-spacewar' klasorunde bulabilirsin."
