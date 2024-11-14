#!/bin/bash

# Форматирование разделов
echo "==> Форматирование разделов"
mkfs.fat -F32 /dev/sda1
mkfs.ext4 /dev/sda2
mkfs.ext4 /dev/sda3

# Монтирование разделов
echo "==> Монтирование разделов"
rm -rf /mnt
mkdir /mnt
mount /dev/sda2 /mnt
mkdir /mnt/boot
mkdir /mnt/home
mount /dev/sda1 /mnt/boot
mount /dev/sda3 /mnt/home

# Установка базовой системы
echo "==> Установка базовой системы"
pacstrap /mnt base base-devel linux linux-firmware 

# Генерация fstab
echo "==> Генерация fstab"
genfstab -U /mnt >> /mnt/etc/fstab

# Переход в chroot окружение
echo "==> Переход в chroot окружение"
arch-chroot /mnt /bin/bash <<EOF

# Установка и настройка загрузчика
echo "==> Установка и настройка загрузчика"
pacman -S --noconfirm grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Создание пользователя
echo "==> Создание пользователя"
useradd -m -G wheel -s /bin/bash datleeey
echo "datleeey:7421" | chpasswd
echo "root:7421" | chpasswd

# Настройка sudo
echo "==> Настройка sudo"
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# Установка дополнительных пакетов
echo "==> Установка GDM и NetworkManager"
pacman -S --noconfirm gdm networkmanager gnome amd-ucode pipewire pipewire-pulse pipewire-alsa pipewire-jack git bluez bluez-utils
pacman -S nvidia nvidia-settings nvidia-utils --neeeded
pacman -S obs discord telegram-desktop


# Включение служб
systemctl enable gdm
systemctl enable NetworkManager

EOF

echo "==> Установка завершена. Перезагрузите систему."
