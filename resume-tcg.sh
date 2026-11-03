#!/usr/bin/env bash
# Step 1b: Resume the existing Windows 98 install (boot from HDD, not CD),
# still on TCG + no-PnP BIOS until SoftGPU is installed and confirmed working.
set -e
VM_DIR="$(cd "$(dirname "$0")" && pwd)"
QEMU=/home/user/qemu-3dfx-project/jhrobotics/build/qemu-system-i386
BIOS="$VM_DIR/bios-nopnp.bin"
DISK="$VM_DIR/win98-softgpu.qcow2"
find_iso() { for d in "$VM_DIR" "/home/user/Desktop/3dfx win 98 on arch" "/home/user/Downloads"; do [ -f "$d/$1" ] && { echo "$d/$1"; return; }; done; echo "$VM_DIR/$1"; }
SOFTGPU="$(find_iso softgpu.iso)"
DRIVERS="$(find_iso 3dfx-ac97-drivers.iso)"
NAS=$(ls -d /run/user/1000/kio-fuse-*/smb/*192.168.1.101/Main 2>/dev/null | head -1)
if [ -n "$NAS" ]; then
  ln -sfn "$NAS" "$VM_DIR/nas-link"
fi
HOME_DIR=/home/user

"$QEMU" \
  -nodefaults \
  -rtc base=localtime \
  -bios "$BIOS" \
  -M pc,accel=tcg,hpet=off,usb=on \
  -cpu pentium3 \
  -m 1024 \
  -boot order=c \
  -drive file="$DISK",format=qcow2,if=ide,index=0,media=disk \
  -drive file="$SOFTGPU",format=raw,if=ide,index=1,media=cdrom \
  -drive file="$DRIVERS",format=raw,if=ide,index=2,media=cdrom \
  -device VGA,vgamem_mb=64 \
  -device AC97 -audio pipewire \
  -netdev user,id=n0,net=10.0.2.0/24,smb="$HOME_DIR" \
  -device pcnet,id=nic0,rombar=0,romfile=,netdev=n0 \
  -display sdl \
  -monitor unix:/tmp/opencode/win98_mon.sock,server,nowait \
  -full-screen
