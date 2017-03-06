#!/bin/bash
GRUBORG="/etc/default/grub.org"
GRUB="/etc/default/grub"
MODPROBE="/etc/modprobe.d"
KERNEL=`uname -r`
OS=`cat /etc/redhat-release | awk -F '[ .]' '{print $1, $2, $7}'`
APPROVED="Red Hat 7"
PATH=/bin/:/usr/bin/:/sbin/
if [ "$OS" = "$APPROVED" ];
then
        echo "$OS is approved, continuing with the script."
        sleep 3
                if [ -s $GRUB ];
                then
                        cp $GRUB $GRUBORG
                        awk '{if ($1 ~ /^GRUB_CMDLINE_LINUX=/) print $0, "rdblacklist=nouveau nouveau.modeset=0"; else print $0}' $GRUBORG > $GRUB
                        touch $MODPROBE/disable-nouveau.conf
                        /bin/printf '#blacklist nouveau driver %s\n blacklist nouveau %s\n options nouveau modeset=0' > $MODPROBE/disable-nouveau.conf
                        chmod 644 $GRUB
                        if [ -s $GRUBORG ];
                        then
                                echo "**** Backing up the initramfs to /boot/initramfs-$KERNEL-nouveau.img ****"
                                mv /boot/initramfs-$(uname -r).img /boot/initramfs-$(uname -r)-nouveau.img
                                echo "Creating the new initramfs."
                                dracut -v /boot/initramfs-$(uname -r).img $(uname -r)
                                echo "**** Downloading Nvidia drivers. *****"
                                wget -O /root/repo/nvidia_latest http://st-uload.llnl.gov/repo/nvidia_latest
                                chmod +x /root/repo/nvidia_latest
                                echo "Removing the Nouvea drivers now."
                                sleep 3
                                yum -y remove xorg-x11-drv-nouveau
                                echo "**** MAKE SURE THIS /etc/default/grub FILE LOOKS GOOD BEFORE YOU REBOOT. ****"
                                cat $GRUB
                                echo "**** If everything looks good then reboot and install the Nvidia drivers. ****"
                else
                        echo "There was no /etc/default/grub found."
                fi
        else
                echo "The file $GRUBORG does not exist, you need this created for a backup."
        fi
else
        echo "This is $OS and this only runs on $APPROVED."
fi
