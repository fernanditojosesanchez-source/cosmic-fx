#!/usr/bin/env bash
set -e

BACKUP="/usr/bin/cosmic-comp.original"
TARGET="/usr/bin/cosmic-comp"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🛡️  DESINSTALADOR Y RESTAURACIÓN A FÁBRICA (Pop!_OS)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$EUID" -ne 0 ]; then
    echo "⚠️  Este script requiere permisos de administrador."
    echo "   Por favor ejecuta: sudo $0"
    exit 1
fi

if [ ! -f "$BACKUP" ]; then
    echo "⚠️  No se encontró el archivo de respaldo en $BACKUP."
    echo "   Si tu compositor actual ya es la versión de fábrica de Pop!_OS, no es necesario restaurar."
    exit 1
fi

echo "📦 Restaurando compositor original de Pop!_OS desde $BACKUP..."
cp "$BACKUP" "${TARGET}.new"
chmod 755 "${TARGET}.new"
mv -f "${TARGET}.new" "$TARGET"

echo "✅ Compositor de fábrica de Pop!_OS restaurado con éxito en $TARGET."
echo ""
echo "🔄 Para aplicar los cambios:"
echo "   Cierra sesión (Log out) y vuelve a iniciar en Pop!_OS."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
