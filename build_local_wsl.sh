#!/bin/bash
set -e

echo "========================================================"
echo "      Spacewar UEFI Local Builder (WSL / Ubuntu)        "
echo "========================================================"

# Yavaşlıktan kaçınmak için build işlemini Windows dosya sistemi (/mnt/c/...) 
# yerine, direkt Linux'un kendi diski (~/spacewar_build) üzerinde yapacağız.
BUILD_DIR=~/spacewar_build
WINDOWS_DIR=$(pwd)

echo -e "\n[1/5] Ubuntu bagimliliklari kontrol ediliyor..."
sudo apt-get update -y
sudo apt-get install -y --no-install-recommends \
    gcc-aarch64-linux-gnu nasm lld clang llvm uuid-dev build-essential git ca-certificates python3 python3-pip python3-venv dos2unix mono-devel

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

echo -e "\n[2/5] Mu-Silicium Repository Klonlaniyor..."
if [ ! -d "Mu-Silicium" ]; then
    git clone https://github.com/Project-Silicium/Mu-Silicium.git --recursive --depth 1
else
    echo "Mu-Silicium zaten var, guncellenip sifirlaniyor..."
    cd Mu-Silicium
    git fetch --depth 1
    git reset --hard origin/main
    cd ..
fi

echo -e "\n[3/5] Yerel Yamalar Uygulaniyor (Memory & USB Host)..."
# Windows dizinindeki değişikliklerimizi klonlanan Linux dizinine taşıyoruz
cp "$WINDOWS_DIR/UEFI/upstream_overrides/MemoryMapLib.c" \
   Mu-Silicium/Platforms/Nothing/spacewarPkg/Library/MemoryMapLib/MemoryMapLib.c

cp "$WINDOWS_DIR/UEFI/upstream_overrides/ConfigurationMapLib.c" \
   Mu-Silicium/Platforms/Nothing/spacewarPkg/Library/ConfigurationMapLib/ConfigurationMapLib.c

# TrustZone SMC çökmelerini engelleyen sed yamamız
find Mu-Silicium -type f \( -name "*.dsc" -o -name "*.fdf" -o -name "*.inc" \) \
    -exec sed -i '/MinidumpTADxe/d' {} +

echo -e "\n[4/5] Python Build Ortami Kuruluyor..."
# PEP 668 kurallarını aşmak için sanal ortam (venv) kullanıyoruz
python3 -m venv uefi_venv
source uefi_venv/bin/activate
pip install --no-cache-dir -r Mu-Silicium/pip-requirements.txt

echo -e "\n[5/5] UEFI Derleniyor (DEBUG Modu)..."
export CLANGPDB_AARCH64_PREFIX=aarch64-linux-gnu-
cd Mu-Silicium
bash ./build_uefi.sh -d spacewar -r DEBUG

echo "========================================================"
echo "    Derleme Tamamlandi! Dosyalar Windows'a Tasiniyor... "
echo "========================================================"
cp Mu-spacewar*.img "$WINDOWS_DIR/" 2>/dev/null || echo "HATA: Img dosyasi bulunamadi!"
cp Build/build_output.log "$WINDOWS_DIR/build_local.log" 2>/dev/null || true

echo "Islem bitti. Mu-spacewar.img dosyasi su an Windows klasorunde hazir: $WINDOWS_DIR"
