[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/J4C2217YIW)

# patcher
COMFAST CF-WR632AX Factory Patcher

### Download
```shell
wget https://github.com/andros-ua/patcher/raw/refs/heads/main/patch_factory.sh \
-O /tmp/patch_factory.sh && \
chmod +x /tmp/patch_factory.sh

```

### Example run
```shell
root@OpenWrt:~# apk add kmod-mtd-rw
(1/1) Installing kmod-mtd-rw (6.12.87.2021.02.28~e8776739-r1)
  Executing kmod-mtd-rw-6.12.87.2021.02.28~e8776739-r1.post-install
OK: 22.8 MiB in 167 packages
root@OpenWrt:~# insmod mtd-rw i_want_a_brick=1
root@OpenWrt:~# /tmp/patch_factory.sh

+-------------------------------------------------------------+
|     COMFAST CF-WR632AX Wi-Fi EEPROM Patcher v3.3.4          |
+-------------------------------------------------------------+

Dumped /dev/mtd2 to /tmp/Factory.bin.

Backup created: /tmp/Factory.bin.backup

EEPROM has critical calibration data flaw.
Patching is required to fix the issue.

Verifying Factory (/dev/mtd2) dump:
---------------------------------------------------------------
[WARN] 0x0000024C: 0xA4 <> 0x00
[WARN] 0x0000024D: 0xA6 <> 0x00
[WARN] 0x0000024E: 0xA6 <> 0x00
[WARN] 0x0000024F: 0xA6 <> 0x00
[WARN] 0x00000250: 0xA3 <> 0x00
[WARN] 0x00000251: 0x91 <> 0x00
[WARN] 0x00000253: 0x91 <> 0x00
[WARN] 0x00000255: 0x91 <> 0x00
[WARN] 0x00000257: 0x91 <> 0x00
[WARN] 0x00000259: 0x89 <> 0x00
[WARN] 0x00000270: 0x0C <> 0x00
[WARN] 0x000009A0: 0x01 <> 0x00

Applying patches is required.

Proceeding...

Patching /tmp/Factory.bin:
---------------------------------------------------------------
[OK] 0x0000024C: 0x00 -> 0xA4
[OK] 0x0000024D: 0x00 -> 0xA6
[OK] 0x0000024E: 0x00 -> 0xA6
[OK] 0x0000024F: 0x00 -> 0xA6
[OK] 0x00000250: 0x00 -> 0xA3
[OK] 0x00000251: 0x00 -> 0x91
[OK] 0x00000253: 0x00 -> 0x91
[OK] 0x00000255: 0x00 -> 0x91
[OK] 0x00000257: 0x00 -> 0x91
[OK] 0x00000259: 0x00 -> 0x89
[OK] 0x00000270: 0x00 -> 0x0C
[OK] 0x000009A0: 0x00 -> 0x01
---------------------------------------------------------------
Summary: 12 patched, 0 skipped, 0 failed.

Writing to Factory (/dev/mtd2)

Unlocking Factory ...

Writing from /tmp/Factory.bin to Factory ...

Wrote patched file to Factory (/dev/mtd2).

Verifying Factory (/dev/mtd2):
---------------------------------------------------------------
[PASS] 0x0000024C: 0xA4 = 0xA4
[PASS] 0x0000024D: 0xA6 = 0xA6
[PASS] 0x0000024E: 0xA6 = 0xA6
[PASS] 0x0000024F: 0xA6 = 0xA6
[PASS] 0x00000250: 0xA3 = 0xA3
[PASS] 0x00000251: 0x91 = 0x91
[PASS] 0x00000253: 0x91 = 0x91
[PASS] 0x00000255: 0x91 = 0x91
[PASS] 0x00000257: 0x91 = 0x91
[PASS] 0x00000259: 0x89 = 0x89
[PASS] 0x00000270: 0x0C = 0x0C
[PASS] 0x000009A0: 0x01 = 0x01

================================================================
Backup file is located at /tmp/Factory.bin.backup.

Please reboot the device to apply the changes.
================================================================
root@OpenWrt:~#
```
