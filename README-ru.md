# Napi-armbian-build

Конфигурации сборки Armbian, патчи ядра, оверлеи device tree
и утилиты сборки для промышленных одноплатных компьютеров **NAPI2** (RK3568) и **NAPI-C** (RK3308).

> 📧 Заказ плат и обсуждение интеграции: **dj.novikov@gmail.com**  
> 🔧 Документация по платам и распиновка GPIO: **[napi-boards](https://github.com/napilab/napi-boards)**

---

## Содержимое

Репозиторий — это готовый оверлей для [системы сборки Armbian](https://github.com/armbian/build).
Склонируйте, скопируйте файлы в дерево Armbian и собирайте — ручное патчение не требуется.

```
napi-armbian-build/
│
├── config/
│   └── boards/
│       ├── napi2.csc               # Конфиг платы NAPI2 (RK3568J)
│       └── napic.conf              # Конфиг платы NAPI-C (RK3308)
│
├── userpatches/
│   ├── customize-image.sh          # Кастомизация образа: пользователи, пакеты,
│   │                               #   компиляция оверлеев, настройка десктопа
│   ├── lib.config                  # Переопределения Armbian lib
│   ├── config-default.conf
│   ├── bootscripts/
│   │   └── boot-rockchip64-ttyS0.cmd
│   ├── kernel/
│   │   ├── archive/rockchip64-6.12/
│   │   │   ├── dt/rk3568-napi2.dts         # DTS NAPI2, mainline 6.12
│   │   │   ├── dt/rk3308-napi-c.dts        # DTS NAPI-C, mainline 6.12
│   │   │   └── 0150-mmc-ignore-sd-read-ext-regs-error.patch
│   │   └── rk35xx-vendor-6.1/
│   │       ├── dt/rk3568-napi2.dts         # DTS NAPI2, vendor 6.1
│   │       └── 0150-mmc-ignore-sd-read-ext-regs-error.patch
│   ├── overlay/
│   │   ├── overlays-rk3308/        # Оверлеи NAPI-C
│   │   ├── overlays-rk3568/        # Оверлеи NAPI2
│   │   ├── overlays-rk3568-current/  # Оверлеи NAPI2, mainline ядро
│   │   ├── overlays-rk3568-vendor/   # Оверлеи NAPI2, vendor ядро
│   │   ├── dt-bindings.tar.gz      # Заголовки DT (упаковано, ~600 файлов)
│   │   ├── includes-rk35xx-vendor.tar.gz
│   │   ├── etc/                    # sysctl.d, источники apt и другие конфиги
│   │   ├── services/               # Юниты systemd (create-home, getty)
│   │   ├── xfce-configs/           # Настройки XFCE
│   │   ├── lightdm/                # Конфиг менеджера входа
│   │   ├── chromium-configs/
│   │   └── backgrounds/            # Обои рабочего стола
│   └── u-boot/
│       ├── legacy/u-boot-radxa-rk35xx/   # Патчи U-Boot для NAPI2
│       └── v2024.10/                     # Патчи U-Boot для NAPI-C
│
├── run-mynapi.sh                   # Обёртка сборки (см. ниже)
├── run-xz-number.sh                # Сжатие образа xz + sha256
├── run-clean-images.sh             # Удаление образов по шаблону
├── check-overlay.sh                # Компиляция отдельного оверлея без полной сборки ядра
└── run-napi-pack.sh                # Упаковка репо в архив с меткой времени
```

---

## Быстрый старт

### 1. Установка системы сборки Armbian

```bash
git clone --depth=1 https://github.com/armbian/build ~/arb
```

### 2. Применение napi-armbian-build

```bash
git clone https://github.com/your-org/napi-armbian-build.git
cd napi-armbian-build

cp -r config/  ~/arb/config/
cp -r userpatches/ ~/arb/userpatches/
cp run-mynapi.sh run-xz-number.sh run-clean-images.sh check-overlay.sh run-napi-pack.sh ~/arb/
chmod +x ~/arb/*.sh
```

### 3. Сборка

```bash
cd ~/arb

# NAPI2 — минимальный образ, mainline ядро 6.12
./run-mynapi.sh --napi2 --current --minimal

# NAPI2 — минимальный образ, vendor ядро 6.1 (рекомендуется для продакшена)
./run-mynapi.sh --napi2 --vendor --minimal

# NAPI2 — десктоп XFCE, vendor ядро
./run-mynapi.sh --napi2 --vendor --desktop

# NAPI-C — минимальный образ (всегда current, всегда minimal)
./run-mynapi.sh --napic

# Только ядро (быстрая итерация)
./run-mynapi.sh --napi2 --current --kernelonly
```

Готовые образы: `~/arb/output/images/`

---

## Скрипты сборки

### `run-mynapi.sh`

Обёртка над `compile.sh` с разумными значениями по умолчанию для плат NAPI.

```
Параметры:
  --napi2 / --napic      Выбор платы (по умолчанию: napi2)
  --current              Mainline ядро 6.12
  --vendor               Rockchip BSP ядро 6.1
  --edge                 Edge ядро
  --minimal              Минимальный консольный образ
  --desktop              Десктоп XFCE (только napi2)
  --kernelonly           Собрать только пакет ядра
  --noclean              Не чистить кеш (быстрее пересборка)
  --skiparmbian          Пропустить apt.armbian.com (если недоступен)
  --help                 Показать справку
```

### `check-overlay.sh`

Компиляция отдельного `.dts` оверлея с использованием заголовков ядра — без пересборки ядра.
Использует исходники ядра из `~/arb/cache/sources/`.

```bash
./check-overlay.sh lvds          # → /tmp/lvds.dtbo
./check-overlay.sh rs485-uart3   # → /tmp/rs485-uart3.dtbo
```

### `run-xz-number.sh`

Поиск собранного образа по фрагменту ID, сжатие `xz -9 -T8`, генерация `sha256`.

```bash
./run-xz-number.sh 0317    # находит output/images/*0317*.img → *.img.xz + *.img.xz.sha256
```

### `run-clean-images.sh`

Удаление образов по одному или нескольким шаблонам. Поддерживает `-y` (без подтверждения)
и `-s` (только показать содержимое).

```bash
./run-clean-images.sh napic vendor    # удалить все образы *napic* или *vendor*
./run-clean-images.sh -s              # показать содержимое output/images/
./run-clean-images.sh -y 25Mar        # удалить без подтверждения
```

### `run-napi-pack.sh`

Упаковка всех файлов, относящихся к NAPI, из `~/arb` в архив с меткой времени
для резервного копирования или переноса.

```bash
./run-napi-pack.sh
# → ~/tmp/napi-pack-20260405-1423.tar.gz
```

---

## Ветки ядра

| Ветка     | Ядро   | Применение                                                      |
|-----------|--------|-----------------------------------------------------------------|
| `current` | 6.12   | Mainline — разработка, отладка оверлеев                         |
| `vendor`  | 6.1    | Rockchip BSP — продакшен, аппаратное видео MPP (`/dev/mpp_service`) |

---

## APT-зеркало и репозиторий Napilab

Сборка по умолчанию использует российское зеркало Armbian (`stpete-mirror.armbian.com`)
во избежание проблем с доступностью `.ua` зеркал.

Образ включает **APT-репозиторий Napilab**, который предоставляет пакеты,
отсутствующие в стандартных репозиториях Ubuntu Noble:

- **mbusd** — демон-шлюз Modbus TCP → RTU
- **mbscan** — сканер устройств Modbus
- **modbus-slave** — эмулятор Modbus slave

Эти пакеты предустановлены в образе и доступны через `apt-get install`.

---

## Параметры образа по умолчанию

После сборки образ содержит:

| Параметр       | Значение                                                     |
|----------------|--------------------------------------------------------------|
| Пользователь   | `napi` (sudo), `root`                                        |
| Пароль root    | `napilinux`                                                  |
| Часовой пояс   | Europe/Moscow                                                |
| Локаль         | en_US.UTF-8                                                  |
| Консоль        | ttyS2, 1500000                                               |
| Автовход       | Отключён                                                     |
| IPv6           | Отключён (sysctl)                                            |
| SSH            | Включён                                                      |
| Мастер первого входа | Отключён                                               |
| Заголовки ядра | Установлены (`linux-headers-${BRANCH}-${LINUXFAMILY}`)       |
| APT-репозитории | Ubuntu Noble + Armbian + Napilab                            |
| Предустановлено | vim, net-tools, can-utils, mbpoll, minicom, tcpdump, screen, i2c-tools, python3-pymodbus, mosquitto, mbusd, memtester, build-essential |
| Десктоп (опционально) | XFCE, Firefox (не snap), x11vnc, драйверы Mesa/GPU  |

Скомпилированные `.dtbo` оверлеи размещаются в `/boot/dtb/rockchip/overlay/`.
Исходные `.dts` файлы сохраняются в `/root/dts/`.

---

## Оверлеи

Включение в `/boot/armbianEnv.txt` после прошивки:

```
overlays=rk3568-napi2-rs485-uart3 rk3568-napi2-can0
```

**NAPI2 (RK3568)** — `overlay/overlays-rk3568*/`:

| Файл                      | Интерфейс       |
|---------------------------|-----------------|
| `rs485-uart3`             | RS485 / UART3   |
| `rk3568-can2`             | CAN 2.0B        |
| `lvds-current`            | LVDS, mainline  |
| `lvds-vendor`             | LVDS, vendor    |
| `i2c4-m1`                 | I2C4            |
| `rtc1338`                 | RTC DS1338      |

**NAPI-C (RK3308)** — `overlay/overlays-rk3308/`:

| Файл                      | Интерфейс       |
|---------------------------|-----------------|
| `rk3308-uart1/2/3/4`     | UART            |
| `rk3308-i2c1/3`          | I2C             |
| `rk3308-i2c1-ds1307/38`  | I2C + RTC       |
| `rk3308-spi1-w5500`      | SPI Ethernet    |
| `rk3308-usb20-host`      | USB 2.0 Host    |

---

## Ссылки

- **[napi-boards](https://github.com/your-org/napi-boards)** — распиновка GPIO, документация по оверлеям, примеры использования
- **[napiworld.ru](https://napiworld.ru/docs/napi2/)** — страница продукта (ru)
- **[NapiLinux](https://napilinux.ru)** — ОС с веб-интерфейсом NapiConfig
- **[Загрузки](https://download.napilinux.ru/)** — готовые образы

---

## Заказ и контакты

Заказ плат NAPI2 / NAPI-C, разработка кастомных плат-носителей,
обсуждение интеграции в ваш проект:

📧 **dj.novikov@gmail.com**

---

`rockchip` `rk3568` `rk3308` `armbian` `embedded-linux` `device-tree` `industrial`
`sbc` `single-board-computer` `rs485` `can-bus` `modbus` `iot-gateway` `lvds` `rockchip-rk3568`
