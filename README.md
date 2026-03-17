# Napi-armbian-build

Custom Armbian build configurations, kernel patches, device tree overlays,
and build utilities for **NAPI2** (RK3568) and **NAPI-C** (RK3308) industrial SBCs.

> 📧 To order boards or discuss integration: **dj.novikov@gmail.com**  
> 🔧 Board documentation and GPIO pinouts: **[napi-boards](https://github.com/napilab/napi-boards)**

---

## What's Inside

This repository is a drop-in overlay for the [Armbian build system](https://github.com/armbian/build).
Clone it, copy the files into your Armbian tree, and build — no manual patching needed.

```
napi-armbian-build/
│
├── config/
│   └── boards/
│       ├── napi2.csc               # NAPI2 board config (RK3568J)
│       └── napic.conf              # NAPI-C board config (RK3308)
│
├── userpatches/
│   ├── customize-image.sh          # Image customization: users, packages,
│   │                               #   overlay compilation, desktop tweaks
│   ├── lib.config                  # Armbian lib overrides
│   ├── config-default.conf
│   ├── bootscripts/
│   │   └── boot-rockchip64-ttyS0.cmd
│   ├── kernel/
│   │   ├── archive/rockchip64-6.12/
│   │   │   ├── dt/rk3568-napi2.dts         # NAPI2 DTS, mainline 6.12
│   │   │   ├── dt/rk3308-napi-c.dts        # NAPI-C DTS, mainline 6.12
│   │   │   └── 0150-mmc-ignore-sd-read-ext-regs-error.patch
│   │   └── rk35xx-vendor-6.1/
│   │       ├── dt/rk3568-napi2.dts         # NAPI2 DTS, vendor 6.1
│   │       └── 0150-mmc-ignore-sd-read-ext-regs-error.patch
│   ├── overlay/
│   │   ├── overlays-rk3308/        # NAPI-C device tree overlays
│   │   ├── overlays-rk3568/        # NAPI2 device tree overlays
│   │   ├── overlays-rk3568-current/  # NAPI2 overlays, mainline kernel
│   │   ├── overlays-rk3568-vendor/   # NAPI2 overlays, vendor kernel
│   │   ├── dt-bindings.tar.gz      # DT header includes (packed, ~600 files)
│   │   ├── includes-rk35xx-vendor.tar.gz
│   │   ├── etc/                    # sysctl.d and other system configs
│   │   ├── services/               # systemd units (create-home, getty)
│   │   ├── xfce-configs/           # XFCE desktop tweaks
│   │   ├── lightdm/                # Display manager config
│   │   ├── chromium-configs/
│   │   └── backgrounds/            # Custom wallpaper
│   └── u-boot/
│       ├── legacy/u-boot-radxa-rk35xx/   # NAPI2 U-Boot patches
│       └── v2024.10/                     # NAPI-C U-Boot patches
│
├── run-mynapi.sh                   # Build wrapper (see below)
├── xznapi.sh                       # Compress output image with xz + sha256
├── check-overlay.sh                # Compile single overlay without full kernel build
└── napi-pack.sh                    # Pack this repo into timestamped archive
```

---

## Quick Start

### 1. Setup Armbian build system

```bash
git clone --depth=1 https://github.com/armbian/build ~/arb
```

### 2. Apply napi-armbian-build

```bash
git clone https://github.com/your-org/napi-armbian-build.git
cd napi-armbian-build

cp -r config/  ~/arb/config/
cp -r userpatches/ ~/arb/userpatches/
cp run-mynapi.sh xznapi.sh check-overlay.sh napi-pack.sh ~/arb/
chmod +x ~/arb/*.sh
```

### 3. Build

```bash
cd ~/arb

# NAPI2 — minimal image, mainline kernel 6.12
./run-mynapi.sh --napi2 --current --minimal

# NAPI2 — minimal image, vendor kernel 6.1 (recommended for production)
./run-mynapi.sh --napi2 --vendor --minimal

# NAPI2 — XFCE desktop, vendor kernel
./run-mynapi.sh --napi2 --vendor --desktop

# NAPI-C — minimal image (always current, always minimal)
./run-mynapi.sh --napic

# Kernel only (faster iteration)
./run-mynapi.sh --napi2 --current --kernelonly
```

Output images: `~/arb/output/images/`

---

## Build Scripts

### `run-mynapi.sh`

Wrapper over `compile.sh` with sane defaults for NAPI boards.

```
Options:
  --napi2 / --napic      Select board (default: napi2)
  --current              Mainline kernel 6.12
  --vendor               Rockchip BSP kernel 6.1
  --edge                 Edge kernel
  --minimal              Minimal console image
  --desktop              XFCE desktop (napi2 only)
  --kernelonly           Build kernel package only
  --noclean              Skip cache cleanup (faster rebuilds)
  --skiparmbian          Skip apt.armbian.com (if upstream is down)
  --help                 Show usage
```

### `check-overlay.sh`

Compile a single `.dts` overlay against the kernel headers — without rebuilding the kernel.
Uses the kernel source tree in `~/arb/cache/sources/`.

```bash
./check-overlay.sh lvds          # → /tmp/lvds.dtbo
./check-overlay.sh rs485-uart3   # → /tmp/rs485-uart3.dtbo
```

### `xznapi.sh`

Find a built image by ID fragment, compress with `xz -9 -T8`, generate `sha256`.

```bash
./xznapi.sh 0317    # finds output/images/*0317*.img → *.img.xz + *.img.xz.sha256
```

### `napi-pack.sh`

Pack all napi-relevant files from `~/arb` into a timestamped archive for backup or transfer.

```bash
./napi-pack.sh
# → ~/tmp/napi-pack-20260317-1423.tar.gz
```

---

## Kernel Branches

| Branch    | Kernel | Use case                                                        |
|-----------|--------|-----------------------------------------------------------------|
| `current` | 6.12   | Mainline — upstream development, overlay debugging              |
| `vendor`  | 6.1    | Rockchip BSP — production, MPP hardware video (`/dev/mpp_service`) |

---

## Image Defaults

After build, the image has:

| Parameter     | Value                                                        |
|---------------|--------------------------------------------------------------|
| User          | `napi` (sudo), `root`                                        |
| Root password | `napilinux`                                                  |
| Timezone      | Europe/Moscow                                                |
| Locale        | en_US.UTF-8                                                  |
| Console       | ttyS2, 115200                                                |
| Auto-login    | Disabled                                                     |
| IPv6          | Disabled (sysctl)                                            |
| SSH           | Enabled                                                      |
| First-login wizard | Disabled                                               |
| Pre-installed | vim, net-tools, can-utils, mbpoll, minicom, tcpdump, screen, i2c-tools, python3-pymodbus, mosquitto, mbusd, memtester |
| Desktop (optional) | XFCE, Firefox (non-snap), x11vnc, Mesa/GPU drivers    |

Compiled overlay `.dtbo` files are placed in `/boot/dtb/rockchip/overlay/`.
Source `.dts` files are saved to `/root/dts/`.

---

## Overlays

Enable in `/boot/armbianEnv.txt` after flashing:

```
overlays=rk3568-napi2-rs485-uart3 rk3568-napi2-can0
```

**NAPI2 (RK3568)** — `overlay/overlays-rk3568*/`:

| File                      | Interface       |
|---------------------------|-----------------|
| `rs485-uart3`             | RS485 / UART3   |
| `rk3568-can2`             | CAN 2.0B        |
| `lvds-current`            | LVDS, mainline  |
| `lvds-vendor`             | LVDS, vendor    |
| `i2c4-m1`                 | I2C4            |
| `rtc1338`                 | RTC DS1338      |

**NAPI-C (RK3308)** — `overlay/overlays-rk3308/`:

| File                      | Interface       |
|---------------------------|-----------------|
| `rk3308-uart1/2/3/4`     | UART            |
| `rk3308-i2c1/3`          | I2C             |
| `rk3308-i2c1-ds1307/38`  | I2C + RTC       |
| `rk3308-spi1-w5500`      | SPI Ethernet    |
| `rk3308-usb20-host`      | USB 2.0 Host    |

---

## Related

- **[napi-boards](https://github.com/your-org/napi-boards)** — GPIO pinouts, overlay docs, usage examples
- **[napiworld.ru](https://napiworld.ru/docs/napi2/)** — Official product page (ru)
- **[NapiLinux](https://napilinux.ru)** — Custom OS with NapiConfig web interface
- **[Downloads](https://download.napilinux.ru/)** — Ready-made images

---

## Ordering & Contact

To order NAPI2 / NAPI-C boards or custom carrier boards,
or to discuss integration into your project:

📧 **dj.novikov@gmail.com**

---

`rockchip` `rk3568` `rk3308` `armbian` `embedded-linux` `device-tree` `industrial`
`sbc` `single-board-computer` `rs485` `can-bus` `modbus` `iot-gateway` `lvds` `rockchip-rk3568`