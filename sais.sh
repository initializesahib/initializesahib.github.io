#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

echo "${bold}Sahib's Arch Installer Script${normal}"
echo "'if you don't have to do it again, do it once'"
echo "= = = = = = = = = ="
echo "${bold}Requirements for installation:${normal}"
echo "An internet connection"
echo "Pre-setup partitions (minimum: root and swap)"
echo "An EFI System Partition formatted as FAT32"
echo "Being in the United States of America"
echo "A NVIDIA card / Intel Graphics (AMD support planned)"
echo "${bold}NOTE${normal}: This installer currently does not support more than 3 partitions (root, home, and swap)."
echo
echo "If you do not meet the installation requirements above, please hit CTRL+C."
echo "Otherwise, hit ENTER to continue."
read -r >> /dev/null
echo "${bold}Consent accepted.${normal}"
echo

echo "${bold}[1/2 / 3]${normal} Collecting Information"
read -r -p "Path to ${bold}root${normal} partition: " root
read -r -p "Path to ${bold}swap${normal} partition: " swap
read -r -p "Path to ${bold}home${normal} partition [type in ${bold}exactly${normal} none if you want to mount]: " home
read -r -p "Path to your ${bold}ESP${normal} (EFI System Partition): " esp
read -r -p "Your ${bold}username${normal}: " username
read -r -p "The system's ${bold}hostname${normal}: " hostname
read -r -p "Would you like ${bold}NVIDIA${normal} support? Type in ${bold}exactly${normal} 'yes' or 'no', this script does not handle other inputs: " nvidia
echo
echo "${bold}You have chosen${normal}"
echo "${bold}Root${normal} ${root}"
echo "${bold}Swap${normal} ${swap}"
if [[ "$home" == "none" ]]; then
  echo "${bold}Home${normal} No separate home partition"
else
  echo "${bold}Home${normal} ${home}"
fi
echo "${bold}ESP${normal} ${esp}"
echo "${bold}Username${normal} ${username}"
echo "${bold}Hostname${normal} ${hostname}"
if [[ "$nvidia" == "yes" ]]; then
  echo "${bold}Graphics card${normal} NVIDIA"
else
  echo "${bold}Graphics card${normal} Intel"
fi
echo
read -r -p "Press ENTER if this information looks correct. Press CTRL+C to abort."
clear
echo "${bold}WARNING${normal}"
echo "Proceeding from this point on will result in ${bold}immediate${normal} system changes."
echo "This installer will format your partitions and attempt to install Arch Linux."
echo "Any malformed inputs earlier will result in a corrupted system / failure to properly install."
echo "I am not liable for any damage done to your system as a result of this script."
echo "This was made for me because I am lazy."
echo "${bold}PLEASE PRESS ENTER 7 TIMES TO CONTINUE INSTALLATION.${normal}"
read -r -p "[1/7] Press ENTER if you would like to install. Press CTRL+C to abort."
read -r -p "[2/7] Press ENTER if you would like to install. Press CTRL+C to abort."
read -r -p "[3/7] Press ENTER if you would like to install. Press CTRL+C to abort."
read -r -p "[4/7] Press ENTER if you would like to install. Press CTRL+C to abort."
read -r -p "[5/7] Press ENTER if you would like to install. Press CTRL+C to abort."
read -r -p "[6/7] Press ENTER if you would like to install. Press CTRL+C to abort."
read -r -p "[7/7] Press ENTER if you would like to install. Press CTRL+C to abort."
clear
echo

echo "${bold}[2/2 / 3]${normal} Installing System"
echo "${bold}>>>${normal} Formatting partitions..."
mkfs.ext4 ${root} >> /dev/null
mkswap ${swap} >> /dev/null
if [[ "$home" == "none" ]]; then
  echo "${bold}>>>${normal} No home partition given, skipping..."
else
  mkfs.ext4 ${home} >> /dev/null
fi
echo "${bold}>>>${normal} Mounting partitions..."
mount ${root} /mnt >> /dev/null
mkdir /mnt/boot >> /dev/null
mount ${esp} /mnt/boot >> /dev/null
swapon ${swap} >> /dev/null
if [[ "$home" == "none" ]]; then
  echo "${bold}>>>${normal} No home partition given, skipping..."
else
  mkdir /mnt/home
  mount ${home} /mnt/home >> /dev/null
fi
echo "${bold}>>>${normal} Sorting mirrors..."
pacman -Syy --noconfirm >> /dev/null
pacman -S --noconfirm pacman-contrib >> /dev/null
curl -s "https://www.archlinux.org/mirrorlist/?country=US&protocol=https&use_mirror_status=on" | sed -e 's/^#Server/Server/' -e '/^#/d' | rankmirrors -n 6 - > /etc/pacman.d/mirrorlist 
echo "${bold}>>>${normal} Installing system..."
if [[ "$nvidia" == "yes" ]]; then
  pacstrap /mnt base base-devel e2fsprogs diffutils linux linux-firmware less man-db man-pages ntfs-3g perl sysfsutils efibootmgr git intel-ucode grub sudio vim wpa_supplicant dialog networkmanager libarchive nvidia nvidia-utils nvidia-settings
else
  pacstrap /mnt base base-devel e2fsprogs diffutils linux linux-firmware less man-db man-pages ntfs-3g perl sysfsutils efibootmgr git intel-ucode grub sudio vim wpa_supplicant dialog networkmanager libarchive
fi
genfstab -U /mnt >> /mnt/etc/fstab
cp stage3.sh /mnt
clear
echo "${bold}Stages 1 and 2 complete!${normal}"
echo "The script will now chroot into the installed system."
echo "Please run /mnt/stage3.sh to continue."
arch-chroot /mnt

