#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="/usr/bin/cosmic-comp"
BACKUP="/usr/bin/cosmic-comp.original"

REAL_USER="${SUDO_USER:-$USER}"
if [ "$REAL_USER" = "root" ] || [ -z "$REAL_USER" ]; then
    REAL_USER=$(logname 2>/dev/null || who | awk '{print $1}' | head -n1 || echo "$USER")
fi
REAL_HOME=$(eval echo "~$REAL_USER")

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🌌 INSTALADOR OFICIAL DE COSMIC FX (Pop!_OS 24.04 / COSMIC)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Comprobar privilegios de superusuario
if [ "$EUID" -ne 0 ]; then
    echo "⚠️  Este instalador requiere permisos de administrador para instalar en /usr/bin."
    echo "   Por favor ejecuta: sudo $0"
    exit 1
fi

RELEASE_BIN=""
# 1. Buscar binario local
if [ -f "$DIR/bin/cosmic-comp" ]; then
    RELEASE_BIN="$DIR/bin/cosmic-comp"
elif [ -f "$DIR/../cosmic-lab/cosmic-comp/target/release/cosmic-comp" ]; then
    RELEASE_BIN="$DIR/../cosmic-lab/cosmic-comp/target/release/cosmic-comp"
fi

# 2. Si no existe localmente, intentar descargar desde GitHub Releases
if [ -z "$RELEASE_BIN" ]; then
    echo "🔍 Buscando binario precompilado para Pop!_OS x86_64..."
    DOWNLOAD_URL="https://github.com/fernanditojosesanchez-source/cosmic-fx/releases/latest/download/cosmic-comp"
    mkdir -p "$DIR/bin"
    if command -v curl >/dev/null 2>&1; then
        echo "⬇️  Descargando binario release desde GitHub..."
        if curl -fsSL -o "$DIR/bin/cosmic-comp" "$DOWNLOAD_URL"; then
            chmod +x "$DIR/bin/cosmic-comp"
            RELEASE_BIN="$DIR/bin/cosmic-comp"
        fi
    fi
fi

# 3. Si aún no está disponible, solicitar compilación desde código fuente
if [ -z "$RELEASE_BIN" ] || [ ! -f "$RELEASE_BIN" ]; then
    echo "❌ No se encontró el binario precompilado de cosmic-comp."
    echo "🛠️  Puedes compilarlo fácilmente desde las fuentes ejecutando:"
    echo "   $DIR/build-from-source.sh"
    exit 1
fi

# 4. Respaldo de seguridad del compositor de fábrica de Pop!_OS
if [ ! -f "$BACKUP" ]; then
    echo "🛡️  Creando respaldo de fábrica de tu compositor en $BACKUP..."
    cp -p "$TARGET" "$BACKUP"
    echo "✅ Respaldo creado exitosamente."
else
    echo "🛡️  Respaldo de fábrica verificado en $BACKUP."
fi

# 5. Instalar scripts y herramientas CLI / GUI
echo "⚙️  Instalando utilitarios 'cosmic-fx' y centro de control 'cosmic-fx-gui'..."
mkdir -p "$REAL_HOME/.local/bin" "/usr/local/bin"
cp "$DIR/bin/cosmic-fx" "$REAL_HOME/.local/bin/cosmic-fx"
cp "$DIR/bin/cosmic-fx-gui" "$REAL_HOME/.local/bin/cosmic-fx-gui"
chmod +x "$REAL_HOME/.local/bin/cosmic-fx" "$REAL_HOME/.local/bin/cosmic-fx-gui"
chown "$REAL_USER:$REAL_USER" "$REAL_HOME/.local/bin/cosmic-fx" "$REAL_HOME/.local/bin/cosmic-fx-gui" 2>/dev/null || true

cp "$DIR/bin/cosmic-fx" "/usr/local/bin/cosmic-fx"
cp "$DIR/bin/cosmic-fx-gui" "/usr/local/bin/cosmic-fx-gui"
chmod +x "/usr/local/bin/cosmic-fx" "/usr/local/bin/cosmic-fx-gui"

# 6. Instalar Icono, Lanzador Desktop y AppStream
mkdir -p /usr/share/applications /usr/share/metainfo /usr/share/icons/hicolor/scalable/apps
cp "$DIR/assets/com.system76.CosmicFx.desktop" /usr/share/applications/
cp "$DIR/assets/com.system76.CosmicFx.metainfo.xml" /usr/share/metainfo/
cp "$DIR/assets/com.system76.CosmicFx.svg" /usr/share/icons/hicolor/scalable/apps/
update-desktop-database /usr/share/applications/ 2>/dev/null || true
gtk-update-icon-cache -f /usr/share/icons/hicolor 2>/dev/null || true

# 7. Despliegue atómico del binario del compositor
echo "📦 Desplegando compositor cosmic-comp con cinemática FX..."
cp "$RELEASE_BIN" "${TARGET}.new"
chmod 755 "${TARGET}.new"
mv -f "${TARGET}.new" "$TARGET"

echo ""
echo "🎉 ¡COSMIC FX INSTALADO CON ÉXITO!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎛️  Centro de control gráfico: ejecuta 'cosmic-fx-gui' o ábrelo desde tu App Library."
echo "⚡ Control por terminal: 'cosmic-fx preset snappy | intense | subtle | off'"
echo ""
echo "🔄 Para aplicar los cambios en tu escritorio:"
echo "   Guarda tus trabajos, cierra sesión (Log out) y vuelve a entrar en Pop!_OS."
echo ""
echo "🛡️  Para desinstalar y volver a la versión de fábrica en cualquier momento:"
echo "   sudo $DIR/uninstall.sh"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
