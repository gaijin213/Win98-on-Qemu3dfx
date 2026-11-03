# Windows 98 SE with Hardware 3D Acceleration (`qemu-3dfx` + SoftGPU) on Arch Linux

Complete, reproducible guide, configs, and scripts for running **Windows 98 SE** on **Arch Linux** with hardware-accelerated **OpenGL**, **DirectDraw / Direct3D (DX6–DX9)**, and **3dfx Glide** passthrough using the **JHRobotics ICD-enabled `qemu-3dfx`** fork, a **no-PnP-BIOS SeaBIOS** build, **SoftGPU**, **AC97 audio**, and **Samba 4 SMBv1 network shares** (local `/home/user` + Synology NAS).

> **Everything you need is provided in this repository and its [GitHub Releases](https://github.com/gaijin213/Win98-on-Qemu3dfx/releases/tag/v1.0.0).** The launcher scripts (`install.sh`, `resume-tcg.sh`, `run.sh`), the no-PnP SeaBIOS (`bios-nopnp.bin`), the driver disc (`3dfx-ac97-drivers.iso`), and the desktop shortcut (`win98-softgpu.desktop`) are directly in the repo tree, while the large ISOs (`win98qi_v1.1.0_stock.iso`, `softgpu.iso`) and precompiled Arch Linux `qemu-system-i386` binary are attached to the [**v1.0.0 Release**](https://github.com/gaijin213/Win98-on-Qemu3dfx/releases/tag/v1.0.0).

---

## 0. Required Files, Links & Checksums

### A. Files Included Directly in This Repository

| File | Size | SHA-256 | Purpose |
| :--- | :--- | :--- | :--- |
| [`README.md`](README.md) | — | — | Complete build, installation, configuration, and tuning guide. |
| [`bios-nopnp.bin`](bios-nopnp.bin) | 256 KB | `13faa266712b9f3cc74765fd08080307474ac49c10028163f0034e222c58a604` | Prebuilt SeaBIOS with `CONFIG_PNPBIOS=n` (fixes Win98 mis-detecting the PCI bus as `"Plug and Play BIOS"`). |
| [`3dfx-ac97-drivers.iso`](3dfx-ac97-drivers.iso) | 8.8 MB | `f8ed56e00e26f46046ff2acd0a94f1694f6a1cedc8aa3bd63e4486f15f31607e` | Custom helper ISO: `3DFX\` (`fxmemmap.vxd`, `glide.dll`, `glide2x.dll`, `glide3x.dll`, `opengl32.dll`) + `AC97\` (Intel/Realtek AC97 Win98 WDM audio driver `WDMA_INT.INF`). |
| [`install.sh`](install.sh) | 2.0 KB | — | Step 4 — initial OS install (`accel=tcg`, boots from CD `-boot order=d`, creates `20G` `win98-softgpu.qcow2`). |
| [`resume-tcg.sh`](resume-tcg.sh) | 1.4 KB | — | Step 4/5/6 — HDD boot (`accel=tcg`, `-boot order=c`) while completing Win98 setup and installing drivers under TCG. |
| [`run.sh`](run.sh) | 1.4 KB | — | Step 7 — daily driver launcher (`accel=kvm`, `-cpu pentium3,sse2=on,sse3=on`, `-m 512`, fullscreen SDL, auto-refreshed NAS + home SMB shares). |
| [`win98-softgpu.desktop`](win98-softgpu.desktop) | 318 B | — | KDE / freedesktop Start Menu launcher (`Development;Emulator;` categories). |

### B. Large ISOs & Prebuilt Binary (GitHub Release + Upstream Links)

Because GitHub limits files in Git commits to 100 MB, the large ISOs are hosted in this repository's [**GitHub Release `v1.0.0`**](https://github.com/gaijin213/Win98-on-Qemu3dfx/releases/tag/v1.0.0) alongside their official upstream sources:

| File | Size | Direct Repo Release Link | Upstream / Official Source | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| **`win98qi_v1.1.0_stock.iso`** | 674 MB | [Download from Release v1.0.0](https://github.com/gaijin213/Win98-on-Qemu3dfx/releases/download/v1.0.0/win98qi_v1.1.0_stock.iso) | [Windows 98 QuickInstall (`oerg866/win98-quickinstall`)](https://github.com/oerg866/win98-quickinstall) / [Archive.org Mirror](https://archive.org/details/win98-quickinstall) | Bootable Windows 98 SE QuickInstall ISO (SHA-256: `7df4d4ccc3bee09303f42eb4d02da22911b4c6f2b4b6f97d928202017b5aad7e`). |
| **`softgpu.iso`** | 456 MB | [Download from Release v1.0.0](https://github.com/gaijin213/Win98-on-Qemu3dfx/releases/download/v1.0.0/softgpu.iso) | [JHRobotics SoftGPU `0.8.2025.53` Release](https://github.com/JHRobotics/softgpu/releases/tag/v0.8.2025.53) | SoftGPU `0.8.2025.53` installer (`softgpu.exe`, DirectX 9.0c, WineD3D, Mesa9x, `qemumini.drv`/`qemumini.vxd`, and `EXTRAS\QEMU3DFX\qmfxgl32.dll` + `icd_enab.reg`). SHA-256: `317a8b055ac99655dbb5978d63d3cff76460e16cadb9378af6e96c53d5934c4d`. |
| **`3dfx-ac97-drivers.iso`** | 8.8 MB | [In Repo Tree](3dfx-ac97-drivers.iso) / [Release v1.0.0](https://github.com/gaijin213/Win98-on-Qemu3dfx/releases/download/v1.0.0/3dfx-ac97-drivers.iso) | Built from [JHRobotics/qemu-3dfx](https://github.com/JHRobotics/qemu-3dfx) wrappers + AC97 WDM driver | Helper ISO containing `3DFX\` Glide/OpenGL wrappers and `AC97\` Windows 98 audio drivers. |
| **`bios-nopnp.bin`** | 256 KB | [In Repo Tree](bios-nopnp.bin) / [Release v1.0.0](https://github.com/gaijin213/Win98-on-Qemu3dfx/releases/download/v1.0.0/bios-nopnp.bin) | Built from [SeaBIOS Git](https://git.seabios.org/seabios.git) (`CONFIG_PNPBIOS=n`) | No-PnP SeaBIOS firmware image. |
| **`qemu-system-i386`** | 84 MB | [Download from Release v1.0.0](https://github.com/gaijin213/Win98-on-Qemu3dfx/releases/download/v1.0.0/qemu-system-i386) | Built from [QEMU 9.2.2](https://download.qemu.org/qemu-9.2.2.tar.xz) + [JHRobotics/qemu-3dfx (`0b399bd`)](https://github.com/JHRobotics/qemu-3dfx/tree/0b399bd) | Precompiled Arch Linux `qemu-system-i386` binary with `0b399bd-` ICD signature & Samba 4 `NT1` SMBv1 patch. |

### C. Upstream Source Repositories & Build Dependencies

| Component | Version / Commit | Link |
| :--- | :--- | :--- |
| **QEMU Source Tarball** | `9.2.2` | <https://download.qemu.org/qemu-9.2.2.tar.xz> |
| **JHRobotics `qemu-3dfx` (ICD-enabled fork)** | Commit `0b399bd` | <https://github.com/JHRobotics/qemu-3dfx> |
| **Upstream `kjliew/qemu-3dfx` (reference)** | — | <https://github.com/kjliew/qemu-3dfx> |
| **SoftGPU** | `v0.8.2025.53` | <https://github.com/JHRobotics/softgpu> |
| **SeaBIOS** | `master` (`CONFIG_PNPBIOS=n`) | <https://git.seabios.org/seabios.git> |
| **Windows 98 QuickInstall** | `v1.1.0` | <https://github.com/oerg866/win98-quickinstall> |

### Quick Download One-Liner (Clone Repo + Fetch Release ISOs)

```bash
git clone https://github.com/gaijin213/Win98-on-Qemu3dfx.git /home/user/qemu-3dfx-vms/win98-softgpu
cd /home/user/qemu-3dfx-vms/win98-softgpu

# Download the two large ISOs from the GitHub Release into the same folder:
wget https://github.com/gaijin213/Win98-on-Qemu3dfx/releases/download/v1.0.0/win98qi_v1.1.0_stock.iso
wget https://github.com/gaijin213/Win98-on-Qemu3dfx/releases/download/v1.0.0/softgpu.iso
chmod +x install.sh resume-tcg.sh run.sh
```

> **Generated at runtime (not in repo):** the VM disk `win98-softgpu.qcow2` (20 GB, automatically created by `install.sh` on first run) and the `nas-link` symlink (auto-refreshed by `run.sh`).

---

## 1. Host Prerequisites & Required Paths (Arch Linux)

### 1.1 Install Arch Linux Host Packages

```bash
sudo pacman -S --needed base-devel git wget rsync ninja meson python \
  glib2 sdl2 sdl2_image mesa libepoxy libslirp samba pipewire pipewire-pulse \
  cdrtools p7zip
```

### 1.2 Required Host Paths

| Purpose | Host Path |
| :--- | :--- |
| `qemu-3dfx` build workspace | `/home/user/qemu-3dfx-project/jhrobotics/` |
| Compiled `qemu-system-i386` binary | `/home/user/qemu-3dfx-project/jhrobotics/build/qemu-system-i386` |
| VM working directory | `/home/user/qemu-3dfx-vms/win98-softgpu/` |
| No-PnP SeaBIOS firmware | `/home/user/qemu-3dfx-vms/win98-softgpu/bios-nopnp.bin` |
| VM virtual disk (20 GB `qcow2`) | `/home/user/qemu-3dfx-vms/win98-softgpu/win98-softgpu.qcow2` |
| Start Menu shortcut | `/home/user/.local/share/applications/win98-softgpu.desktop` |

---

## 2. Step-by-Step Build & Setup Guide

### Step 1 — Build SeaBIOS with `CONFIG_PNPBIOS=n` (`bios-nopnp.bin`)

**Why:** Stock QEMU SeaBIOS advertises a Plug-and-Play BIOS structure that causes Windows 98 SE to misdetect the system bus as `"Plug and Play BIOS"` (yellow `!`) instead of enumerating the `"PCI bus"`. Without proper PCI enumeration, the PCI VGA adapter and AC97 audio device are never properly bound.

**Output:** `/home/user/qemu-3dfx-vms/win98-softgpu/bios-nopnp.bin`

```bash
git clone https://git.seabios.org/seabios.git /tmp/seabios
cd /tmp/seabios
make defconfig
sed -i 's/CONFIG_PNPBIOS=y/# CONFIG_PNPBIOS is not set/' .config
make olddefconfig
make -j"$(nproc)"
cp out/bios.bin /home/user/qemu-3dfx-vms/win98-softgpu/bios-nopnp.bin
```

---

### Step 2 — Build JHRobotics "ICD-Enabled" `qemu-3dfx` (Commit `0b399bd`)

**Why this exact fork & commit:**
- SoftGPU's QEMU-3dfx OpenGL ICD (`qmfxgl32.dll`) checks the commit signature compiled into the host `qemu-system-i386` binary (`0b399bd-`). Upstream `kjliew/qemu-3dfx` lacks the ICD patch and fails the signature check.
- We also patch `net/slirp.c` so QEMU's built-in Samba config (`smb.conf`) supports **Windows 98 SMBv1 (`NT1` + `lanman auth = yes`)** on modern Arch Linux (`Samba 4.25+`), exposes both `[nas]` and `[home]` shares from `10.0.2.4`, and tunes socket buffers for fast file copies.

**Workspace:** `/home/user/qemu-3dfx-project/jhrobotics` → output `/home/user/qemu-3dfx-project/jhrobotics/build/qemu-system-i386`

```bash
mkdir -p /home/user/qemu-3dfx-project
cd /home/user/qemu-3dfx-project
git clone https://github.com/JHRobotics/qemu-3dfx.git jhrobotics
cd jhrobotics
git checkout 0b399bd

mkdir -p build-src
cd build-src
wget https://download.qemu.org/qemu-9.2.2.tar.xz
tar xf qemu-9.2.2.tar.xz
cd qemu-9.2.2
rsync -r ../../qemu-0/hw/3dfx ./hw/
rsync -r ../../qemu-1/hw/mesa ./hw/
patch -p0 -i ../../00-qemu92x-mesa-glide.patch
bash ../../scripts/sign_commit
```

**Samba 4 / Windows 98 SMBv1 patch in `net/slirp.c` (`slirp_smb()`):**
Ensure `slirp_smb()` `chmod`s `s->smb_dir` to `0755` and writes the following under `[global]`:
```ini
netbios name = QEMU
workgroup = WORKGROUP
guest account = user
server min protocol = NT1
client min protocol = NT1
lanman auth = yes
ntlm auth = yes
raw NTLMv2 auth = no
socket options = TCP_NODELAY IPTOS_LOWDELAY SO_RCVBUF=131072 SO_SNDBUF=131072
read raw = yes
write raw = yes
max xmit = 65535
getwd cache = yes
unix extensions = no
follow symlinks = yes
wide links = yes
load printers = no
printing = bsd
disable spoolss = yes
usershare max shares = 0
```
plus `[nas]` (path to your NAS mount), `[home]` (path to `/home/user`), and `[qemu]` (path to `/home/user`).

**Compile:**
```bash
mkdir -p /home/user/qemu-3dfx-project/jhrobotics/build
cd /home/user/qemu-3dfx-project/jhrobotics/build
../build-src/qemu-9.2.2/configure \
  --target-list=i386-softmmu \
  --enable-sdl --enable-opengl --enable-kvm --enable-slirp --disable-werror
ninja qemu-system-i386

# Verify the commit signature is embedded:
strings qemu-system-i386 | grep "0b399bd-"
```

---

### Step 3 — Build `3dfx-ac97-drivers.iso` (already provided)

**Contents:** `3DFX\` (JHRobotics guest wrappers `qmfxgl32.dll`, `fxmemmap.vxd`, `icd-enable.reg`, `testqmfx.exe`, Glide wrappers `glide*.dll`) + `AC97\` (Realtek AC97 Win98 audio driver `wdm_a406`).

---

### Step 4 — Install Windows 98 SE Under TCG (`install.sh` + `resume-tcg.sh`)

**Why TCG first:** Per JHRobotics, Windows 98 SE and its hardware/PCI detection must be installed **without KVM** (`accel=tcg`, `-cpu pentium3`) first, then switched to `accel=kvm` only after the OS and drivers are installed.

**Files/ISOs needed:**
- `install.sh` (creates `20G` `win98-softgpu.qcow2`, boots from CD)
- `resume-tcg.sh` (boots from `C:` after QuickInstall copies files)
- `bios-nopnp.bin`
- `win98qi_v1.1.0_stock.iso` (attached as CD 1)
- `softgpu.iso` (attached as CD 2)
- `3dfx-ac97-drivers.iso` (attached as CD 3)

**Procedure:**
1. Run `./install.sh` to boot `win98qi_v1.1.0_stock.iso`, partition/format `C:`, and copy the Windows 98 SE installation files.
2. When QuickInstall prompts to reboot, close QEMU and run `./resume-tcg.sh` (`-boot order=c`) to complete Windows 98 SE first-boot hardware detection.
3. Open **My Computer → Properties → Device Manager → System devices** and confirm **"PCI bus"** is present with **no** `"Plug and Play BIOS"` warning.

---

### Step 5 — Install AC97 Audio & `qemu-3dfx` OpenGL ICD / Glide Wrappers

**Attached CDs:**
- `softgpu.iso` (drive `D:` during normal boot, or `E:` during initial install)
- `3dfx-ac97-drivers.iso` (drive `E:` during normal boot, or `F:` during initial install)

**Procedure in Windows 98:**
1. **AC97 Audio (`3dfx-ac97-drivers.iso`):** In **Device Manager**, select **PCI Multimedia Audio Device** → **Reinstall/Update Driver** → point to `E:\AC97` (`WDMA_INT.INF`) and reboot if prompted.
2. **3dfx Glide Wrappers & `fxmemmap.vxd` (`3dfx-ac97-drivers.iso`):** Open an MS-DOS Prompt and copy from `E:\3DFX\` to `C:\WINDOWS\SYSTEM`:
   ```bat
   copy E:\3DFX\fxmemmap.vxd C:\WINDOWS\SYSTEM\
   copy E:\3DFX\glide.dll C:\WINDOWS\SYSTEM\
   copy E:\3DFX\glide2x.dll C:\WINDOWS\SYSTEM\
   copy E:\3DFX\glide3x.dll C:\WINDOWS\SYSTEM\
   ```
3. **JHRobotics `qemu-3dfx` OpenGL ICD (`softgpu.iso` → `EXTRAS\QEMU3DFX`):** Copy the signature-matched OpenGL ICD from `D:\EXTRAS\QEMU3DFX\` (or let `softgpu.exe` install it in Step 6):
   ```bat
   copy D:\EXTRAS\QEMU3DFX\qmfxgl32.dll C:\WINDOWS\SYSTEM\
   copy D:\EXTRAS\QEMU3DFX\fxmemmap.vxd C:\WINDOWS\SYSTEM\
   regedit D:\EXTRAS\QEMU3DFX\icd_enab.reg
   ```
   Run `D:\EXTRAS\QEMU3DFX\testqmfx.exe` to verify the rotating OpenGL triangle renders using the host GPU.

---

### Step 6 — Install SoftGPU & Switch Display Driver to `qemumini.drv`

**Attached CD:** `softgpu.iso` (appears in Windows 98 as drive `D:`)

**Procedure in Windows 98:**
1. Open `D:\` (`SOFTGPU`) and run **`softgpu.exe`**. Dismiss the preview notice (**OK**).
2. Select the **`QEMU-3dfx`** preset and adjust radio buttons so `dxdiag` shows DirectDraw/Direct3D acceleration:
   - **Target path:** `C:\drivers\SG25.53`
   - **Install:** DirectX 9, MSVCRT, Driver, Settings (`SSE3` binaries selected automatically on modern Intel/AMD CPUs)
   - **DirectDraw (DX7):** **HAL** (enables DirectDraw & Direct3D acceleration in `dxdiag`)
   - **DirectX 8:** **Wine**
   - **DirectX 9:** **Wine**
   - **OpenGL (`qmfxgl32.dll`):** checked (`Install` unchecked since we already copied the version-matched `qmfxgl32.dll` in Step 5, `Set default` checked)
   - **Glide (OpenGlide):** unchecked (use `qemu-3dfx`'s native Glide passthrough DLLs from Step 5 instead)
3. Click **Install!** and wait for DirectX 9 + file staging to finish, then let Windows reboot.
4. **Crucial fix for QuickInstall ISOs (`boxvmini.drv` → `qemumini.drv`):** Because Windows 98 QuickInstall pre-installs a 2D-only driver (`QEMU SVGA PCI` / `boxvmini.drv`, `DDI Version: unknown`), Windows 98 will keep `boxvmini.drv` bound unless you switch it to `C:\drivers\SG25.53`:
   - Right-click **My Computer → Properties → Device Manager → Display adapters → QEMU SVGA PCI**.
   - Click **Driver → Update Driver... → Next**.
   - Choose **"Display a list of all the drivers in a specific location..." → Next → Have Disk...**.
   - Enter `C:\drivers\SG25.53` and click **OK**.
   - Select **`QEMU STD VGA PCI Adapter`** (Manufacturer: `JHRobotics`) → **Next → Next → Finish** and reboot.
5. After rebooting, run **`dxdiag`** → **Display** tab and verify:
   - **Device Name:** `QEMU STD VGA PCI Adapter` (`JHRobotics`, `128.0 MB`)
   - **Main Driver:** `qemumini.drv` / `qemumini.vxd`
   - **DDI Version:** `9 (or higher)`
   - **DirectDraw Acceleration:** `Enabled`
   - **Direct3D Acceleration:** `Enabled`

---

### Step 7 — Day-to-Day KVM Launch (`run.sh`) & Network Shares

Once installation is complete, launch the VM with KVM enabled using `run.sh` (or via **Application Menu → Development → Windows 98 SoftGPU (qemu-3dfx)**).

**Key QEMU Flags in `run.sh`:**
```bash
/home/user/qemu-3dfx-project/jhrobotics/build/qemu-system-i386 \
  -nodefaults \
  -rtc base=localtime \
  -bios /home/user/qemu-3dfx-vms/win98-softgpu/bios-nopnp.bin \
  -M pc,accel=kvm,hpet=off,usb=on \
  -cpu pentium3,sse2=on,sse3=on \
  -m 512 \
  -drive file=/home/user/qemu-3dfx-vms/win98-softgpu/win98-softgpu.qcow2,format=qcow2,if=ide,index=0,media=disk,cache=writeback,aio=threads \
  -drive file=/home/user/Downloads/softgpu.iso,format=raw,if=ide,index=1,media=cdrom \
  -drive file=/home/user/Downloads/3dfx-ac97-drivers.iso,format=raw,if=ide,index=2,media=cdrom \
  -device VGA,vgamem_mb=64 \
  -device AC97 -audio pipewire \
  -netdev user,id=n0,net=10.0.2.0/24,smb=/home/user \
  -device pcnet,id=nic0,rombar=0,romfile=,netdev=n0 \
  -display sdl \
  -monitor unix:/tmp/opencode/win98_mon.sock,server,nowait \
  -full-screen
```

**Notes on these flags:**
- **Do not** pass `-display sdl,gl=on` — `qemu-3dfx` manages its own OpenGL context on plain `-display sdl`.
- **Do not** attach `-device usb-tablet` — Windows 98 has no built-in USB tablet driver and it breaks PS/2 relative mouse grab.
- **`-cpu pentium3,sse2=on,sse3=on`** (instead of `-cpu host`) exposes a clean Pentium III profile to Windows 98 (avoiding 11th-Gen Intel CPUID quirks) while keeping the SSE2/SSE3 instructions SoftGPU's installed `sse3-w98` DLLs require. `accel=kvm` stays on for full hardware virtualization speed.
- **`-m 512`** — Windows 98 SE has a 512 MB RAM bug (Microsoft KB253912); 1 GB+ causes `VCACHE`/`VMM32` BSODs. 512 MB is the maximum stable ceiling.
- **`cache=writeback,aio=threads`** on the `qcow2` drive prevents the guest from stalling on host `fsync` calls during installers.
- **`smb=/home/user`** on the single NIC serves **both** `\\QEMU\nas` and `\\QEMU\home` from `10.0.2.4` (see Network section below).

---

## 3. Network Shares (`\\QEMU\nas` and `\\QEMU\home`) — Customize for Your Setup

### How QEMU's built-in Samba works
QEMU's user-mode networking (`slirp`) spawns a tiny `smbd` on `10.0.2.4` (TCP 139 + 445) serving a single `smb.conf` generated at boot from the `smb=` argument. We patched `net/slirp.c` so that `smb.conf` (compiled into `qemu-system-i386`) contains:
- `[global]` with `server min protocol = NT1`, `lanman auth = yes`, `ntlm auth = yes`, `netbios name = QEMU`, `socket options = TCP_NODELAY ... SO_RCVBUF=131072 SO_SNDBUF=131072`, `read raw = yes`, `write raw = yes`, `max xmit = 65535`, `getwd cache = yes`.
- `[nas]` → path to your NAS mount.
- `[home]` → path to `/home/user`.
- `[qemu]` → path to `/home/user` (legacy alias).

Because Windows 98 uses NetBIOS over TCP/IP (TCP 139) and QEMU does **not** run `nmbd` on UDP 137, you must map `10.0.2.4` to `QEMU` in `C:\WINDOWS\LMHOSTS` so Windows 98 can resolve the name.

### Using your own NAS / network (edit these)

The NAS path is resolved automatically in `run.sh` / `install.sh` / `resume-tcg.sh`:
```bash
NAS=$(ls -d /run/user/1000/kio-fuse-*/smb/*192.168.1.101/Main 2>/dev/null | head -1)
if [ -n "$NAS" ]; then
  ln -sfn "$NAS" "$VM_DIR/nas-link"
fi
```

**To use your own NAS / network, change these three things:**

1. **In `run.sh` / `install.sh` / `resume-tcg.sh`** — change the `ls -d` glob to match your NAS mount path:
   - **KDE Dolphin / kio-fuse SMB:** `/run/user/1000/kio-fuse-*/smb/*<YOUR_NAS_IP>/<YOUR_SHARE_NAME>`
   - **GNOME gvfs SMB:** `/run/user/1000/gvfs/smb-share:server=<YOUR_NAS_IP>,share=<YOUR_SHARE_NAME>`
   - **Manual kernel CIFS mount:** mount it yourself first (`sudo mount -t cifs //YOUR_NAS_IP/YOUR_SHARE /mnt/nas -o username=...,password=...`), then point `nas-link` at `/mnt/nas`.
   - **No NAS at all:** delete the `NAS=...` block and the `ln -sfn` line; `\\QEMU\nas` will simply not exist (or point `nas-link` at any folder you like).
2. **In `net/slirp.c`** (the `[nas]` section) — change:
   ```ini
   path=/home/user/qemu-3dfx-vms/win98-softgpu/nas-link
   ```
   to wherever you want `\\QEMU\nas` to resolve on the host. If you don't need a NAS share, remove the whole `[nas]` block.
3. **In `run.sh`** — the `smb=/home/user` argument serves `/home/user` as `\\QEMU\home` (and `[qemu]`). Change it if you want a different host folder exposed.

### One-time Windows 98 setup (persists across reboots)
```bat
echo 10.0.2.4 QEMU #PRE >> C:\WINDOWS\LMHOSTS
nbtstat -R
net use Z: \\QEMU\nas
net use Y: \\QEMU\home
```
To auto-reconnect `Z:` and `Y:` at every Windows 98 login, right-click **My Computer → Map Network Drive...**, map `Z:` to `\\QEMU\nas` and `Y:` to `\\QEMU\home`, and check **Reconnect at logon**.

### Transfer-speed tips
- `\\QEMU\nas` goes through `kio-fuse` (DBus/FUSE) → Samba → QEMU slirp → emulated 10 Mbps PCnet NIC. For large game folders (100 MB+), either stage them in `/home/user` (`\\QEMU\home`, bypassing kio-fuse) or pack them into an ISO on the host (`mkisofs -o game.iso /path/to/game`) and mount as a CD-ROM drive (reads at 100+ MB/s via IDE DMA with zero network overhead).

---

## 4. Performance Tuning (Why It's Fast Now)

These four changes turned a hanging/slow VM into a fast one. Apply all of them:

### 4.1 Enable DMA on the Hard Drive & CD-ROM (inside Windows 98)
By default, Windows 98 accesses the HDD and CD-ROM in **PIO mode**, firing a CPU interrupt for every sector. Under KVM, every PIO transfer forces a hypervisor VM-exit; during a file copy or installer, tens of thousands of VM-exits per second overwhelm `VMM32` and freeze/BSOD the guest.
- Right-click **My Computer → Properties → Device Manager** tab.
- Expand **Disk drives** → double-click **GENERIC IDE DISK TYPE47** → **Settings** tab → check **`DMA`** → **OK**.
- Expand **CDROM** → double-click each **QEMU CD-ROM** → **Settings** tab → check **`DMA`** → **OK**.
- Reboot Windows 98.

### 4.2 Cap `vcache` at 64 MB in `SYSTEM.INI` (inside Windows 98)
Even with 512 MB RAM, when copying a large file from the network or running a large installer, Windows 98's `VCACHE` (file cache) grows dynamically until it fills every page of RAM and exhausts the kernel System Arena.
- Click **Start → Run** → type `sysedit` (or `notepad C:\WINDOWS\SYSTEM.INI`) → **Enter**.
- Find the **`[vcache]`** section and add `MaxFileCache=65536`:
  ```ini
  [vcache]
  MaxFileCache=65536
  ```
- Save and reboot.

### 4.3 Use `-cpu pentium3,sse2=on,sse3=on` with `accel=kvm`
- `-cpu host` exposes 11th-Gen Intel Tiger Lake CPUID features/MSRs that Windows 98's 1999 kernel wasn't written for, causing hangs.
- A bare `-cpu pentium3` only supports SSE1 and would crash SoftGPU's `sse3-w98` DLLs (`mesa3d.dll` / `wined3d.dll`) with an `Invalid Instruction` fault.
- **`-cpu pentium3,sse2=on,sse3=on`** gives Windows 98 a clean Pentium III profile while keeping the SSE2/SSE3 instructions SoftGPU needs. `accel=kvm` stays on for full hardware virtualization speed.

### 4.4 `cache=writeback,aio=threads` on the `qcow2` drive
- Prevents the guest from stalling on host `fsync` calls during installers.

### 4.5 Samba `NT1` + socket tuning (compiled into `qemu-system-i386`)
- Upgraded from `LANMAN1` to `NT1` (Windows 98 SE natively supports `NT LM 0.12`, enabling 64 KB `LARGE_READX` transfers) plus `TCP_NODELAY`, `SO_RCVBUF=131072`, `SO_SNDBUF=131072`, `read raw = yes`, `write raw = yes`, `max xmit = 65535`, `getwd cache = yes`.

### 4.6 Keep RAM at 512 MB (`-m 512`)
- Windows 98 SE has a 512 MB RAM bug (Microsoft KB253912); 1 GB+ causes `VCACHE`/`VMM32` BSODs. 512 MB is the maximum stable ceiling and is more than any Win98 game can use.

---

## 5. Display Sharpness (Optional)

Your Windows 98 framebuffer goes through two non-integer resamplings before reaching the screen if the guest resolution doesn't match the panel:
- Set Windows 98 to **`1920×1080`** (SoftGPU's `QEMU STD VGA PCI Adapter` already includes `1920×1080` in its mode table: right-click **Desktop → Properties → Settings → Screen area → 1920 by 1080 pixels**).
- Prevent KDE Wayland `125%` double-scaling: set **KDE System Settings → Display & Monitor → Legacy Applications (X11): "Apply scaling themselves"**, or set `SDL_RENDER_SCALE_QUALITY=0` (nearest-neighbor) for sharp pixels instead of bilinear blur.

---

## 6. Final Touches & Checklist

1. **Install the Desktop Shortcut (KDE / Freedesktop Start Menu):**
   ```bash
   mkdir -p ~/.local/share/applications
   cp win98-softgpu.desktop ~/.local/share/applications/
   update-desktop-database ~/.local/share/applications 2>/dev/null || true
   ```
2. **Verify `dxdiag` Acceleration Inside Windows 98:**
   - **Start → Run → `dxdiag`** → **Display** tab:
     - **Device Name:** `QEMU STD VGA PCI Adapter` (`JHRobotics`, `128.0 MB`)
     - **Main Driver:** `qemumini.drv` / `qemumini.vxd` (`DDI Version: 9`)
     - **DirectDraw Acceleration:** `Enabled` (Test DirectDraw passes)
     - **Direct3D Acceleration:** `Enabled` (Test Direct3D DX7/DX8/DX9 spinning cube passes)
3. **Verify OpenGL ICD & 3dfx Glide:**
   - Run `D:\EXTRAS\QEMU3DFX\testqmfx.exe` and `D:\EXTRAS\QEMU3DFX\wglinfo.exe` to confirm host GPU OpenGL renderer passthrough.
4. **Verify DMA & `VCACHE`:**
   - **Device Manager → Disk drives & CDROM:** confirm **`DMA`** is checked on all IDE drives.
   - **`C:\WINDOWS\SYSTEM.INI`:** confirm `MaxFileCache=65536` is under `[vcache]`.
5. **Verify Network Shares:**
   - `Z:` mapped to `\\QEMU\nas` and `Y:` mapped to `\\QEMU\home` via `C:\WINDOWS\LMHOSTS` (`10.0.2.4 QEMU #PRE`).

---

## 7. Repository & Release Contents Recap

- [`README.md`](README.md) — Complete build, configuration, and tuning guide.
- [`bios-nopnp.bin`](bios-nopnp.bin) — Prebuilt SeaBIOS with `CONFIG_PNPBIOS=n`.
- [`3dfx-ac97-drivers.iso`](3dfx-ac97-drivers.iso) — 3dfx Glide wrappers + AC97 WDM audio driver disc.
- [`install.sh`](install.sh) — Step 4 initial OS install script (`accel=tcg`, `-boot order=d`).
- [`resume-tcg.sh`](resume-tcg.sh) — Step 4/5/6 HDD boot script (`accel=tcg`, `-boot order=c`).
- [`run.sh`](run.sh) — Step 7 daily driver launcher (`accel=kvm`, `-cpu pentium3,sse2=on,sse3=on`, `-m 512`, `cache=writeback,aio=threads`, fullscreen SDL, auto-refreshed NAS + home SMB shares via `NT1`).
- [`win98-softgpu.desktop`](win98-softgpu.desktop) — KDE / freedesktop Start Menu launcher (`Development;Emulator;` categories).
- [**`win98qi_v1.1.0_stock.iso`** (Release v1.0.0)](https://github.com/gaijin213/Win98-on-Qemu3dfx/releases/download/v1.0.0/win98qi_v1.1.0_stock.iso) — Windows 98 SE QuickInstall ISO (674 MB).
- [**`softgpu.iso`** (Release v1.0.0)](https://github.com/gaijin213/Win98-on-Qemu3dfx/releases/download/v1.0.0/softgpu.iso) — SoftGPU `0.8.2025.53` installer ISO (456 MB).
- [**`qemu-system-i386`** (Release v1.0.0)](https://github.com/gaijin213/Win98-on-Qemu3dfx/releases/download/v1.0.0/qemu-system-i386) — Precompiled Arch Linux `qemu-system-i386` binary with `0b399bd-` ICD signature & Samba 4 `NT1` SMBv1 patch (84 MB).