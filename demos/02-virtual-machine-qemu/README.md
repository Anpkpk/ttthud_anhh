# Demo 2: Virtual Machine với QEMU / KVM

## Mục tiêu
1. Kiểm tra khả năng ảo hóa phần cứng của CPU (`Intel VT-x` / `AMD-V`) và nhân **KVM** (`/dev/kvm`).
2. Thực hành tạo ổ đĩa ảo **QCOW2** cấp phát mỏng (thin-provisioning) và cơ chế **Backing File / Snapshot**.
3. Nắm được cách khởi chạy một máy ảo hoàn chỉnh bằng `qemu-system-x86_64` (Type 1/2 Hypervisor trên Linux) hoặc VirtualBox.

## Chạy script kiểm tra & demo ổ đĩa ảo
```bash
bash demos/02-virtual-machine-qemu/demo_vm_check.sh
```

## Chạy thử một Guest OS hoàn chỉnh (tùy chọn tải Alpine Linux ~60 MB)
Nếu muốn boot hẳn một hệ điều hành Linux nhẹ bên trong QEMU/KVM:

```bash
# 1. Tải Alpine Linux Virtual ISO (~60 MB)
wget https://dl-cdn.alpinelinux.org/alpine/v3.20/releases/x86_64/alpine-virt-3.20.3-x86_64.iso

# 2. Tạo ổ đĩa ảo 4GB (thực tế chỉ tốn ~200 KB khi mới tạo)
qemu-img create -f qcow2 alpine-disk.qcow2 4G

# 3. Khởi chạy VM với tăng tốc phần cứng KVM, 1GB RAM, 2 vCPU:
qemu-system-x86_64 \
  -enable-kvm \
  -m 1024 \
  -smp 2 \
  -drive file=alpine-disk.qcow2,format=qcow2 \
  -cdrom alpine-virt-3.20.3-x86_64.iso \
  -boot d \
  -nic user,model=virtio-net-pci
```

Khi vào bên trong VM, chạy `uname -a` và `free -h` bạn sẽ thấy Guest VM có **kernel riêng**, **RAM riêng** và **bảng tiến trình hoàn toàn tách biệt** khỏi máy Host.
