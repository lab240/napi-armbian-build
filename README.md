# NAPI Armbian Build

This repository contains custom patches and build configurations for creating Armbian images for NAPI-C and NAPI2 single-board computers based on Rockchip SoCs.

## Supported Boards

### NAPI-C/P/Slot
- **SoC**: Rockchip RK3308 (quad-core ARM Cortex-A35)
- **RAM**: 256MB-512MB
- **Features**: WiFi support, minimal headless configuration
- **Board Config**: `config/boards/napic.conf`
- **Documentation**: https://napiworld.ru/docs/napi-intro/

### NAPI2
- **SoC**: Rockchip RK3568 (quad-core ARM Cortex-A55)
- **Features**: Enhanced I/O capabilities, CAN bus support
- **Kernel Support**: Current and vendor 6.1 kernels
- **Documentation**: https://napiworld.ru/docs/napi-intro/

## Repository Structure

```
├── config/
│   └── boards/
│       └── napic.conf              # Board configuration for NAPI-C
├── userpatches/
│   ├── customize-image.sh          # Image customization script
│   ├── kernel/                     # Kernel patches
│   │   ├── spacemit-legacy-6.1/    # SpacemiT K1 patches
│   │   ├── rk35xx-current/         # RK3568 mainline kernel patches
│   │   ├── rk35xx-vendor-6.1/      # RK3568 vendor kernel patches
│   │   └── archive/                # Archived patches
│   ├── u-boot/                     # U-Boot patches
│   │   └── v2024.10/
│   └── overlay/                    # System overlay files
│       ├── overlays/               # Device tree overlays
│       ├── services/               # Systemd service configurations
│       └── etc/                    # System configuration files
```

## Key Features

### Custom Hardware Support
- **NAPI-C**: RK3308-based minimal SBC with WiFi
- **NAPI2**: RK3568-based SBC with enhanced connectivity
- Device tree overlays for UART, I2C, and CAN interfaces
- Custom U-Boot configurations with NAPI-specific defconfigs

### System Customization
- **Pre-installed user**: napi
- **Pre-installed packages**: essential packages included for operation
- **Pre-compiled overlays**: ready-to-use overlay files
- **DTS overlay files**: located in `/root/dts` 
- **Timezone**: Moscow
- **Locale**: en
- **Console speed**: 115200
- **Auto-login**: Disabled for security

### Hardware Overlays
Available device tree overlays in `userpatches/overlay/overlays/`:
- UART interfaces: `rk3308-uart1`, `rk3308-uart2-m0`, `rk3308-uart3-m0`
- I2C with RTC support: `rk3308-i2c1-ds1338`, `rk3308-i2c3-m0`
- USB host: `rk3308-usb20-host`
- CAN bus support (NAPI2): `rk3568-can2`

### Pre-installed Software
- **System Tools**: vim, net-tools, tcpdump, screen, memtester
- **Industrial Tools**: can-utils, mbpoll, minicom
- **Development**: xxd (hex editor)
- **Optional Desktop**: Mesa/GPU drivers (when building desktop images)

## Build Instructions

1. **Setup Armbian Build System**
   ```bash
   git clone https://github.com/armbian/build
   cd build
   ```

2. **Clone This Repository**
   ```bash
   git clone <this-repo-url> napi-armbian-build
   cp -r napi-armbian-build/config/* config/
   cp -r napi-armbian-build/userpatches/* userpatches/
   ```

3. **Build NAPI-C Image**
   ```bash
   ./compile.sh \
     BOARD=napic \
     BRANCH=current \
     RELEASE=noble \
     BUILD_MINIMAL=no \
     BUILD_DESKTOP=no \
     KERNEL_CONFIGURE=no
   ```

4. **Build NAPI2 Image**
   ```bash
   ./compile.sh \
     BOARD=<rk3568-board-name> \
     BRANCH=current \
     RELEASE=noble \
     BUILD_MINIMAL=no \
     BUILD_DESKTOP=no \
     KERNEL_CONFIGURE=no
   ```

## Patch Details

### Kernel Patches
- **RK3308 (NAPI-C)**: Device tree and Makefile modifications for board support
- **RK3568 (NAPI2)**: Enhanced I/O support, CAN bus, additional overlays
- **MMC Fix**: Ignore SD card extended register read errors
- **SpacemiT K1**: Legacy kernel support for K1-based variants

### U-Boot Patches
- Custom defconfig for NAPI boards
- Boot configuration optimized for serial console
- Device tree blob selection for proper hardware initialization

## Configuration Notes

### Memory Optimization
- **CMA Size**: Set to 16MB for boards with limited RAM (512MB or less)
- **Modules Blacklist**: Graphics-related modules disabled for headless operation
- **Performance**: CPU governor and frequency scaling configured per board

### Security Settings
- Root password authentication required
- SSH enabled by default
- No automatic login configured
- Systemd services properly configured

### Networking
- IPv6 disabled by default (sysctl configuration)
- WiFi support for NAPI-C with MAC address fixation
- Ethernet optimization for industrial applications

## Troubleshooting

### Common Issues
1. **Boot Fails**: Check U-Boot configuration and DTB file path
2. **No Serial Output**: Verify console configuration in board config
3. **WiFi Issues**: Ensure MAC address fixation rules are applied
4. **Overlay Not Loading**: Check overlay compilation and armbianEnv.txt

### Debug Information
- Build logs available in Armbian build output
- Runtime information stored in `/root/info.txt`
- Device tree compilation logs in `/root/dts/`

## Contributing

When contributing patches:
1. Follow existing naming conventions (`NNNN-description.patch`)
2. Test patches on actual hardware when possible
3. Document hardware-specific requirements
4. Update this README for new features

## License

This project follows the same licensing terms as the Armbian project. Individual patches may have their own licensing requirements - check patch headers for details.

## Support

For hardware-specific issues with NAPI boards, please contact the board manufacturer.
For Armbian build system issues, refer to the [Armbian documentation](https://docs.armbian.com/).
