#!/usr/bin/env bash
# Step 1: Install Windows 98 using the no-PnP-BIOS SeaBIOS build and WITHOUT
# the CPU accelerator (per JHRobotics/softgpu's documented QEMU-3dfx setup),
# so Windows 98 correctly detects the PCI bus instead of misdetecting it as
# Plug and Play BIOS (which silently blocks DirectDraw/Direct3D acceleration).
set -e
VM_DIR="$(cd "$(dirname "$0")" && pwd)"
QEMU=/home/user/qemu-3dfx-project/jhrobotics/build/qemu-system-i386
BIOS="$VM_DIR/bios-nopnp.bin"
DISK="$VM_DIR/win98-softgpu.qcow2"
# ISOs: prefer the copy shipped next to this script, fall back to ~/Downloads
for f in win98qi_v1.1.0_stock.iso softgpu.iso 3dfx-ac97-drivers.iso; do
  [ -f "$VM_DIR/$f" ] || [ -f "/home/user/Downloads/$f" ] || echo "WARNING: $f not found"
done
find_iso() { for d in "$VM_DIR" "/home/user/Desktop/3dfx win 98 on arch" "/home/user/Downloads"; do [ -f "$d/$1" ] && { echo "$d/$1"; return; }; done; echo "$VM_DIR/$1"; }
WIN98="$(find_iso win98qi_v1.1.0_stock.iso)"
SOFTGPU="$(find_iso softgpu.iso)"
DRIVERS="$(find_iso 3dfx-ac97-drivers.iso)"
NAS=$(ls -d /run/user/1000/kio-fuse-*/smb/*192.168.1.101/Main 2>/dev/null | head -1)
if [ -n "$NAS" ]; then
  ln -sfn "$NAS" "$VM_DIR/nas-link"
fi
HOME_DIR=/home/user

if [ ! -f "$DISK" ]; then
  qemu-img create -f qcow2 "$DISK" 20G
fi

"$QEMU" \
  -nodefaults \
  -rtc base=localtime \
  -bios "$BIOS" \
  -M pc,accel=tcg,hpet=off,usb=on \
  -cpu pentium3 \
  -m 1024 \
  -boot order=d \
  -drive file="$DISK",format=qcow2,if=ide,index=0,media=disk \
  -drive file="$WIN98",format=raw,if=ide,index=1,media=cdrom \
  -drive file="$SOFTGPU",format=raw,if=ide,index=2,media=cdrom \
  -drive file="$DRIVERS",format=raw,if=ide,index=3,media=cdrom \
  -device VGA,vgamem_mb=64 \
  -device AC97 -audio pipewire \
  -netdev user,id=n0,net=10.0.2.0/24,smb="$HOME_DIR" \
  -device pcnet,id=nic0,rombar=0,romfile=,netdev=n0 \
  -display sdl \
  -monitor unix:/tmp/opencode/win98_mon.sock,server,nowait \
  -full-screen
