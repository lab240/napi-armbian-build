#!/bin/bash
# run-napi-pack.sh — упаковывает napi-файлы из ~/arb в архив для переноса в репо
# Установка:    cp run-napi-pack.sh ~/arb/ && chmod +x ~/arb/run-napi-pack.sh
# Запускать на fazenda: cd ~/arb && ./run-napi-pack.sh
# Архив создаётся в:    ~/tmp/napi-pack-YYYYMMDD-HHMM.tar.gz
set -e

ARB="$HOME/arb"
UP="$ARB/userpatches"
TIMESTAMP=$(date +%Y%m%d-%H%M)
OUT="$HOME/tmp/napi-pack-${TIMESTAMP}.tar.gz"
mkdir -p "$HOME/tmp"

echo "==> Собираем архив: $OUT"
echo ""

TMP=$(mktemp -d)
trap "rm -rf $TMP" EXIT

UP_DST="$TMP/armbian/userpatches"

cp_f() {
    local src="$UP/$1"
    local dst="$UP_DST/$1"
    if [ -e "$src" ]; then
        mkdir -p "$(dirname "$dst")"
        cp "$src" "$dst"
        echo "  [OK] $1"
    else
        echo "  [--] $1 (не найден)"
    fi
}

cp_d() {
    local src="$UP/$1"
    local dst="$UP_DST/$1"
    if [ -d "$src" ]; then
        mkdir -p "$dst"
        cp -r "$src/." "$dst/"
        echo "  [OK] $1/"
    else
        echo "  [--] $1/ (не найден)"
    fi
}

# --- userpatches корневые файлы ---
echo "==> userpatches: корневые файлы"
cp_f "customize-image.sh"
cp_f "lib.config"
cp_f "config-default.conf"

# --- kernel ---
echo "==> kernel: mainline 6.12"
cp_f "kernel/archive/rockchip64-6.12/0150-mmc-ignore-sd-read-ext-regs-error.patch"
cp_f "kernel/archive/rockchip64-6.12/dt/rk3568-napi2.dts"
cp_f "kernel/archive/rockchip64-6.12/dt/rk3308-napi-c.dts"

echo "==> kernel: vendor 6.1"
cp_f "kernel/rk35xx-vendor-6.1/0150-mmc-ignore-sd-read-ext-regs-error.patch"
cp_f "kernel/rk35xx-vendor-6.1/dt/rk3568-napi2.dts"

# --- bootscripts ---
echo "==> bootscripts"
cp_f "bootscripts/boot-rockchip64-ttyS0.cmd"

# --- overlays ---
echo "==> overlays: rk3308 (napic)"
cp_d "overlay/overlays-rk3308"

echo "==> overlays: rk3568 (napi2)"
cp_d "overlay/overlays-rk3568"
cp_d "overlay/overlays-rk3568-current"
cp_d "overlay/overlays-rk3568-vendor"

# --- dt-bindings — пакуем как вложенные tar.gz, не раскладываем в репо ---
echo "==> dt-bindings: упаковываем как вложенные tar.gz"
mkdir -p "$UP_DST/overlay"

if [ -d "$UP/overlay/dt-bindings" ]; then
    tar -czf "$UP_DST/overlay/dt-bindings.tar.gz" -C "$UP/overlay" dt-bindings
    echo "  [OK] overlay/dt-bindings → dt-bindings.tar.gz"
else
    echo "  [--] overlay/dt-bindings (не найден)"
fi

if [ -d "$UP/overlay/includes-rk35xx-vendor" ]; then
    tar -czf "$UP_DST/overlay/includes-rk35xx-vendor.tar.gz" -C "$UP/overlay" includes-rk35xx-vendor
    echo "  [OK] overlay/includes-rk35xx-vendor → includes-rk35xx-vendor.tar.gz"
else
    echo "  [--] overlay/includes-rk35xx-vendor (не найден)"
fi

# --- overlay: системные файлы образа ---
echo "==> overlay: системные файлы"
cp_d "overlay/etc"
cp_d "overlay/services"
cp_d "overlay/backgrounds"
cp_d "overlay/lightdm"
cp_d "overlay/xfce-configs"
cp_d "overlay/chromium-configs"

# --- u-boot ---
echo "==> u-boot: napi2"
cp_d "u-boot/legacy/u-boot-radxa-rk35xx"

echo "==> u-boot: napic"
cp_d "u-boot/v2024.10"

# --- board configs ~/arb/config/boards/ ---
echo "==> board configs"
mkdir -p "$TMP/armbian/config/boards"
for f in napi2.csc napic.conf; do
    if [ -f "$ARB/config/boards/$f" ]; then
        cp "$ARB/config/boards/$f" "$TMP/armbian/config/boards/$f"
        echo "  [OK] config/boards/$f"
    else
        echo "  [--] config/boards/$f (не найден)"
    fi
done

# --- утилиты ~/arb (рядом с userpatches) ---
echo "==> утилиты сборки"
for f in run-mynapi.sh check-overlay.sh run-napi-pack.sh run-clean-images.sh run-xz-number.sh; do
    if [ -f "$ARB/$f" ]; then
        cp "$ARB/$f" "$TMP/armbian/$f"
        echo "  [OK] $f"
    else
        echo "  [--] $f (не найден)"
    fi
done

# --- упаковка ---
echo ""
echo "==> Упаковываем..."
tar -czf "$OUT" -C "$TMP" .

echo ""
echo "==> Готово: $OUT"
ls -lh "$OUT"
echo ""
echo "==> Перенести на hp и распаковать в репо:"
echo "    scp dmn-fazenda:~/tmp/$(basename $OUT) ~/prj/napi-boards/"
echo "    cd ~/prj/napi-boards && tar -xzf $(basename $OUT) && rm $(basename $OUT)"
