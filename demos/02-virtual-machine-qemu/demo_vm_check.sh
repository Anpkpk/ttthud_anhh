#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="${SCRIPT_DIR}/.vm_demo_tmp"
mkdir -p "${WORK_DIR}"

cleanup() {
    rm -rf "${WORK_DIR}"
}
trap cleanup EXIT

echo "=== [1] Kiểm tra hỗ trợ ảo hóa phần cứng (VT-x / AMD-V & KVM) ==="
VIRT_FLAG=$(grep -m1 -oE 'vmx|svm' /proc/cpuinfo || echo "none")
echo "CPU Virtualization Flag : ${VIRT_FLAG}"
if [ -e /dev/kvm ]; then
    ls -l /dev/kvm
else
    echo "/dev/kvm không tồn tại"
fi

echo ""
echo "=== [2] Phiên bản QEMU Hypervisor ==="
qemu-system-x86_64 --version
qemu-img --version

echo ""
echo "=== [3] Demo Thin-Provisioned Disk (QCOW2) & Snapshot ==="
BASE_IMG="${WORK_DIR}/vm-base.qcow2"
SNAP_IMG="${WORK_DIR}/vm-snapshot.qcow2"

qemu-img create -f qcow2 "${BASE_IMG}" 10G
qemu-img create -f qcow2 -b "${BASE_IMG}" -F qcow2 "${SNAP_IMG}"

echo "--- Thông tin ổ đĩa gốc (ảo 10 GiB nhưng kích thước thật trên đĩa cực nhỏ): ---"
qemu-img info "${BASE_IMG}"

echo "--- Thông tin ổ đĩa snapshot (Copy-on-Write dựa trên backing file): ---"
qemu-img info "${SNAP_IMG}"

echo "--- Kích thước chiếm dụng thực tế trên filesystem: ---"
ls -lh "${WORK_DIR}"
