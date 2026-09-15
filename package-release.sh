#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION="${1:-1.0.0}"
RELEASE_NAME="cosmic-fx-v${VERSION}-popos-x86_64"
DIST_DIR="$DIR/dist/$RELEASE_NAME"
TAR_FILE="$DIR/dist/${RELEASE_NAME}.tar.gz"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 EMPAQUETADOR DE RELEASE: $RELEASE_NAME"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Verificar binario release
SRC_BIN=""
if [ -f "$DIR/bin/cosmic-comp" ]; then
    SRC_BIN="$DIR/bin/cosmic-comp"
elif [ -f "$DIR/../cosmic-lab/cosmic-comp/target/release/cosmic-comp" ]; then
    SRC_BIN="$DIR/../cosmic-lab/cosmic-comp/target/release/cosmic-comp"
fi

if [ -z "$SRC_BIN" ] || [ ! -f "$SRC_BIN" ]; then
    echo "❌ Error: Binario optimizado 'cosmic-comp' no encontrado."
    echo "   Por favor compila primero con: ./build-from-source.sh"
    exit 1
fi

rm -rf "$DIST_DIR" "$TAR_FILE"
mkdir -p "$DIST_DIR/bin" "$DIST_DIR/assets"

# Copiar archivos
cp "$SRC_BIN" "$DIST_DIR/bin/cosmic-comp"
cp "$DIR/bin/cosmic-fx" "$DIST_DIR/bin/cosmic-fx"
cp "$DIR/bin/cosmic-fx-gui" "$DIST_DIR/bin/cosmic-fx-gui"
chmod +x "$DIST_DIR/bin"/*

cp -r "$DIR/assets"/* "$DIST_DIR/assets/"
cp "$DIR/install.sh" "$DIST_DIR/install.sh"
cp "$DIR/uninstall.sh" "$DIST_DIR/uninstall.sh"
cp "$DIR/LICENSE" "$DIST_DIR/LICENSE" 2>/dev/null || true
chmod +x "$DIST_DIR"/*.sh

# Generar archivo tar.gz
cd "$DIR/dist"
tar -czvf "$TAR_FILE" "$RELEASE_NAME"
cd "$DIR/dist"
sha256sum "${RELEASE_NAME}.tar.gz" > "${RELEASE_NAME}.tar.gz.sha256"

echo ""
echo "🎉 ¡PAQUETE DE RELEASE GENERADO EXITOSAMENTE!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Archivo tarball: $TAR_FILE"
echo "🔑 Checksum SHA256: $(cat "$DIR/dist/${RELEASE_NAME}.tar.gz.sha256")"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
