#!/bin/bash

# ##############################################
set -e -u
sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
locale-gen
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
usermod -s /bin/bash root
cp -aT /etc/skel/ /root/
chmod 700 /root
# ##############################################

# ################################################## Creating liveuser #####################################################
useradd -m -p "" -g users -G "adm,audio,floppy,log,network,rfkill,scanner,storage,optical,power,wheel" -s /bin/bash liveuser
cp -avT /etc/skel/ /home/liveuser/
chown -R liveuser:users /home/liveuser
chmod 700 /home/liveuser/
# ##########################################################################################################################

# ### Giving root permission for live user /etc/sudoers ####
rm -v /etc/sudoers
mv -v /etc/skel/.magpie-settings/sudoers-backup /etc/sudoers
chown -c root:root /etc/sudoers
chmod -c 0440 /etc/sudoers
# ##########################################################

# ############### Importing pacman keys ############
pacman-key --init 
pacman-key --populate archlinux
pacman-key --refresh-keys
# ##################################################

# ##################### OS Information ########################
rm -v /etc/lsb-release
mv -v /etc/skel/.magpie-settings/lsb-release /etc/lsb-release
rm -v /usr/lib/os-release
mv -v /etc/skel/.magpie-settings/os-release /usr/lib/os-release
# #############################################################

# ########## Adding grub-theme to /etc/default/grub file ##########
rm -v /etc/default/grub
mv -v /etc/skel/.magpie-settings/etc-default-grub /etc/default/grub
# #################################################################

# #############################################################################
sed -i 's/#\(PermitRootLogin \).\+/\1yes/' /etc/ssh/sshd_config
sed -i "s/#Server/Server/g" /etc/pacman.d/mirrorlist
sed -i 's/#\(Storage=\)auto/\1volatile/' /etc/systemd/journald.conf
sed -i 's/#\(HandleSuspendKey=\)suspend/\1ignore/' /etc/systemd/logind.conf
sed -i 's/#\(HandleHibernateKey=\)hibernate/\1ignore/' /etc/systemd/logind.conf
sed -i 's/#\(HandleLidSwitch=\)suspend/\1ignore/' /etc/systemd/logind.conf
# #############################################################################

# ############################# Removing packages #################################################
# pacman -R --noconfirm PKG_NAME
# #################################################################################################

# ############ Installing custom packages to rootfs ###############
pacman -U --noconfirm /etc/skel/.magpie-packages/*.pkg.tar.xz
# #################################################################

# ### Changing pacman.conf for magpie-mirrrorlist support ##
rm -v /etc/pacman.conf
cp -v /etc/skel/.magpie-settings/pacman.conf /etc/
# ##########################################################

# ############################ MagpieOS Install Desktop File #####################################
cp -v /usr/share/applications/calamares.desktop /home/liveuser/.config/autostart/calamares.desktop
chown liveuser:wheel /home/liveuser/.config/autostart/calamares.desktop
chmod +x /home/liveuser/.config/autostart/calamares.desktop
# ################################################################################################

# ########## Adding custom /etc/nanorc for Nano ######## 
mv -vf /etc/skel/.magpie-settings/etc-nanorc /etc/nanorc
# ######################################################

# ################### Adding custom lightdm config ####################
rm -v /etc/lightdm/lightdm-gtk-greeter.conf
cp -v /etc/skel/.magpie-settings/lightdm-gtk-greeter.conf /etc/lightdm/
# #####################################################################

# ###############################
rm -dr /etc/skel/.magpie-settings 
rm -dr /etc/skel/.magpie-packages
# ###############################

# ### Tap to click support for gnome settings ####
rm -v /usr/share/X11/xorg.conf.d/70-synaptics.conf
# ################################################

# ### Fixing Permisssion ## 
chmod 755 /
# #########################

# ########################################################################################
systemctl enable pacman-init.service choose-mirror.service NetworkManager lightdm zramswap
systemctl set-default graphical.target
# ########################################################################################

