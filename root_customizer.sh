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
cp -aT /etc/skel/ /home/liveuser/
chown -R liveuser:users /home/liveuser
chmod 700 /home/liveuser/
# ##########################################################################################################################

# ### Giving root permission for live user /etc/sudoers ####
rm /etc/sudoers
mv /etc/skel/.magpie-settings/sudoers-backup /etc/sudoers
chown -c root:root /etc/sudoers
chmod -c 0440 /etc/sudoers
# ##########################################################

# ############### Importing pacman keys ############
pacman-key --init
pacman-key --populate archlinux
pacman-key --refresh-keys
# ##################################################

# ##################### OS Information ########################
rm /etc/lsb-release
mv /etc/skel/.magpie-settings/lsb-release /etc/lsb-release
rm /usr/lib/os-release
mv /etc/skel/.magpie-settings/os-release /usr/lib/os-release
# #############################################################

# ########## Adding grub-theme to /etc/default/grub file ##########
rm /etc/default/grub
mv /etc/skel/.magpie-settings/etc-default-grub /etc/default/grub
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
pacman -R --noconfirm parole
# #################################################################################################

# ############ Installing custom packages to rootfs ###############
pacman -U --noconfirm /etc/skel/.magpie-packages/*.pkg.tar.xz
# #################################################################

# ### Changing pacman.conf for magpie-mirrrorlist support ##
rm /etc/pacman.conf
cp /etc/skel/.magpie-settings/pacman.conf /etc/
# ##########################################################

# ############################ MagpieOS Install Desktop File #####################################
cp /usr/share/applications/calamares.desktop /home/liveuser/.config/autostart/calamares.desktop
chown liveuser:wheel /home/liveuser/.config/autostart/calamares.desktop
chmod +x /home/liveuser/.config/autostart/calamares.desktop
# ################################################################################################

# ########## Adding custom /etc/nanorc for Nano ########
mv -f /etc/skel/.magpie-settings/etc-nanorc /etc/nanorc
# ######################################################

# ######## Adding custom ntp config ########
rm /etc/ntp.conf
cp /etc/skel/.magpie-settings/ntp.conf /etc/
# ##########################################

# # Fixing xfce cursor theme reset problem on reboot #
rm /etc/environment
cp /etc/skel/.magpie-settings/etc-environment /etc/
# ####################################################

# ######## Copying release info of MagpieOS to livecd ########
rm /etc/arch-release
cp /etc/skel/.magpie-settings/magpie-release /etc/
cp /etc/skel/.magpie-settings/magpie-release /etc/arch-release
# ############################################################

# ######## Adding red lined bash theme for root ##########
rm /root/.bashrc
mv /etc/skel/.magpie-settings/bashrc_root /root/.bashrc
# ########################################################

# ######## Adding custom mkinitcpio config ########
rm /etc/mkinitcpio.conf
mv /etc/skel/.magpie-settings/mkinitcpio.conf /etc/
# #################################################

# ################ Adding lightdm-gtk-greeter config ###############
rm /etc/lightdm/lightdm-gtk-greeter.conf
mv /etc/skel/.magpie-settings/lightdm-gtk-greeter.conf /etc/lightdm/
# ##################################################################

# # adding to autologin group #
groupadd -r autologin
gpasswd -a liveuser autologin
# #############################

# ######################## Cursor theme problem fixing ###########################
cp /etc/skel/.magpie-settings/index.txt /usr/share/icons/default/index.theme
# ################################################################################

# ###### Xfce lockscreen not showing problem fix ########
cp /etc/skel/.magpie-settings/xflock4.sh /usr/bin/xflock4
chmod +x /usr/bin/xflock4
# #######################################################

# ############# Adding Xfce File Manager(Thunar) drive mount without password ##############
cp -f /etc/skel/.magpie-settings/org.freedesktop.UDisks2.policy /usr/share/polkit-1/actions/
# ##########################################################################################

# ###############################
rm -dr /etc/skel/.magpie-settings
rm -dr /etc/skel/.magpie-packages
# ###############################

# ### Tap to click support for gnome settings ####
rm /usr/share/X11/xorg.conf.d/70-synaptics.conf
# ################################################

# ### Fixing Permisssion ##
chmod 755 /
# #########################

# ###############################################################################
systemctl enable pacman-init.service choose-mirror.service NetworkManager lightdm
systemctl enable zramswap ntpd bluetooth org.cups.cupsd
systemctl set-default graphical.target
# ###############################################################################
