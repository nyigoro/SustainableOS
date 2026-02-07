#!/system/bin/sh
# =====================================================
# customize.sh — SustainableOS v0.3.1
# Runs during Magisk installation (recovery context)
# =====================================================

ui_print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ui_print "   SustainableOS – Smart Installer v0.3.1"
ui_print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

MODDIR="$MODPATH"
CONF_DIR="$MODDIR/system/etc/sustainableos"

BASE_WL="$CONF_DIR/whitelist.txt"
ACTIVE_WL="$CONF_DIR/whitelist_oem.txt"

# Safety checks
if [ ! -f "$BASE_WL" ]; then
  ui_print "❌ Base whitelist.txt missing!"
  abort "Installation aborted for safety."
fi

# Detect OEM
OEM_RAW="$(getprop ro.product.manufacturer)"
OEM="$(echo "$OEM_RAW" | tr 'A-Z' 'a-z')"

ui_print "- Detected OEM: $OEM_RAW"

# Normalize OEM names
case "$OEM" in
  samsung)
    OEM_KEY="samsung"
    ;;
  xiaomi|redmi|poco)
    OEM_KEY="xiaomi"
    ;;
  vivo|iqoo)
    OEM_KEY="vivo"
    ;;
  tecno|itel|infinix)
    OEM_KEY="tecno"
    ;;
  *)
    OEM_KEY="generic"
    ;;
esac

ui_print "- Using profile: $OEM_KEY"

# Start with base whitelist
cp -f "$BASE_WL" "$ACTIVE_WL"

# Append OEM overlay if exists
OEM_WL="$CONF_DIR/whitelist_$OEM_KEY.txt"
if [ -f "$OEM_WL" ]; then
  ui_print "- Applying $OEM_KEY safety shields"
  echo "" >> "$ACTIVE_WL"
  echo "# ---- $OEM_KEY overlay ----" >> "$ACTIVE_WL"
  cat "$OEM_WL" >> "$ACTIVE_WL"
else
  ui_print "- No OEM overlay found, running Generic mode"
fi

# Permissions (important for recovery context)
chmod 0644 "$ACTIVE_WL"
chmod 0644 "$BASE_WL"

ui_print "✔ Whitelist ready: $(wc -l < "$ACTIVE_WL") protected packages"

ui_print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ui_print " SustainableOS installed successfully"
ui_print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
