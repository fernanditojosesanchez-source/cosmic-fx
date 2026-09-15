#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$DIR/build/cosmic-comp"
PATCH_FILE="$DIR/patches/cosmic-comp-fx-cumulative.patch"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🛠️  COMPILADOR DESDE FUENTES: COSMIC COMPOSITOR CON FX"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Verificar herramientas requeridas
if ! command -v git >/dev/null 2>&1; then
    echo "❌ Error: git no está instalado. Ejecuta: sudo apt install git"
    exit 1
fi

if ! command -v cargo >/dev/null 2>&1; then
    echo "❌ Error: cargo (Rust) no está instalado. Por favor instala Rust desde https://rustup.rs"
    exit 1
fi

mkdir -p "$DIR/build"

# 1. Clonar o actualizar repositorio oficial de cosmic-comp
if [ ! -d "$BUILD_DIR/.git" ]; then
    echo "📥 Clonando repositorio oficial de System76 cosmic-comp..."
    git clone --depth 50 https://github.com/pop-os/cosmic-comp.git "$BUILD_DIR"
else
    echo "🔄 Repositorio existente detectado. Actualizando..."
    cd "$BUILD_DIR"
    git fetch origin master
    git reset --hard origin/master
fi

cd "$BUILD_DIR"

# 2. Aplicar el parche acumulativo de Cosmic FX
echo "🩹 Aplicando parche de cinemática y física Cosmic FX..."
git apply --verbose "$PATCH_FILE"

# 3. Compilar en modo Release
echo "⚡ Compilando cosmic-comp en modo Release (esto puede demorar unos minutos)..."
cargo build --release

# 4. Copiar el binario generado a la carpeta bin/ del proyecto
mkdir -p "$DIR/bin"
cp "$BUILD_DIR/target/release/cosmic-comp" "$DIR/bin/cosmic-comp"
chmod +x "$DIR/bin/cosmic-comp"

echo ""
echo "🎉 ¡COMPILACIÓN COMPLETADA CON ÉXITO!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Binario generado en: $DIR/bin/cosmic-comp"
echo "🚀 Ahora puedes instalarlo directamente ejecutando:"
echo "   sudo $DIR/install.sh"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
