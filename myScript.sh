#!/bin/bash

#get a list of all packages
dpkg --get-selections | sed "s/.*deinstall//" | sed "s/install$//g" > ~/Desktop/pkglist

#delete all known good packages off the list
for file in `cat ~/Desktop/good_pkglist.txt`
 do
   grep -v  ${file}  ~/Desktop/pkglist > ~/Desktop/temp.txt
   mv -f ~/Desktop/temp.txt ~/Desktop/pkglist
 done

#search through the list for a list of various bad packages
if grep "apache2" ~/Desktop/pkglist
then
    apt-get -y purge apache2
    grep -v "apache2" ~/Desktop/pkglist > ~/Desktop/temp.txt
    mv -f ~/Desktop/temp.txt ~/Desktop/pkglist
fi

if grep "bind9" ~/Desktop/pkglist
then
    apt-get -y purge bind9
    grep -v "bind9" ~/Desktop/pkglist > ~/Desktop/temp.txt
    mv -f ~/Desktop/temp.txt ~/Desktop/pkglist
fi

if grep "nginx" ~/Desktop/pkglist
then
    apt-get -y purge nginx
    grep -v "nginx" ~/Desktop/pkglist > ~/Desktop/temp.txt
    mv -f ~/Desktop/temp.txt ~/Desktop/pkglist
fi

if grep "wesnoth" ~/Desktop/pkglist
then
    apt-get -y purge wesnoth*
    grep -v "wesnoth" ~/Desktop/pkglist > ~/Desktop/temp.txt
    mv -f ~/Desktop/temp.txt ~/Desktop/pkglist
fi

if grep "netcat" ~/Desktop/pkglist
then
    apt-get -y purge netcat
    grep -v "netcat" ~/Desktop/pkglist > ~/Desktop/temp.txt
    mv -f ~/Desktop/temp.txt ~/Desktop/pkglist
fi

if grep "frostwire" ~/Desktop/pkglist
then
    apt-get -y purge frostwire
    grep -v "frostwire" ~/Desktop/pkglist > ~/Desktop/temp.txt
    mv -f ~/Desktop/temp.txt ~/Desktop/pkglist
fi

if grep "telnet" ~/Desktop/pkglist
then
    apt-get -y purge telnet
    grep -v "telnet" ~/Desktop/pkglist > ~/Desktop/temp.txt
    mv -f ~/Desktop/temp.txt ~/Desktop/pkglist
fi

#if grep "ftp" ~/Desktop/pkglist
#then
#    apt-get -y purge ftp
#    grep -v "ftp" ~/Desktop/pkglist > ~/Desktop/temp.txt
#    mv -f ~/Desktop/temp.txt ~/Desktop/pkglist
#fi


#turn on firewall
ufw enable


#turn off guests
grep -v "allow-guest=" /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf > ~/Desktop/temp.txt
mv -f ~/Desktop/temp.txt /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf
echo "allow-guest=false" >> /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf

#set password min and max days
sed "s/PASS_MAX_DAYS.*/PASS_MAX_DAYS 30/" /etc/login.defs > ~/Desktop/temp.txt
mv -f ~/Desktop/temp.txt /etc/login.defs
sed "s/PASS_MIN_DAYS.*/PASS_MIN_DAYS 3/" /etc/login.defs > ~/Desktop/temp.txt
mv -f ~/Desktop/temp.txt /etc/login.defs

#install and set up ssh
apt-get install ssh
if grep "PermitRootLogin" /etc/ssh/sshd_config
then
    sed "s/PermitRootLogin yes/PermitRootLogin no/" /etc/ssh/sshd_config > ~/Desktop/temp.txt
    mv -f ~/Desktop/temp.txt /etc/ssh/sshd_config
else
    echo "PermitRootLogin no" >> /etc/ssh/sshd_config
fi


#prevent external connections (remote desktop)
echo "-:root:ALL EXCEPT LOCAL" >> /etc/security/access.conf


#get a list of users (with a few extras)
grep "/home/" /etc/passwd | sed "s/:.*//" > ~/Desktop/myUserList

#get rid of the extra users from the list
grep -v "guest" ~/Desktop/myUserList > ~/Desktop/temp.txt
mv -f ~/Desktop/temp.txt ~/Desktop/myUserList
grep -v "syslog" ~/Desktop/myUserList > ~/Desktop/temp.txt
mv -f ~/Desktop/temp.txt ~/Desktop/myUserList
grep -v "usbmux" ~/Desktop/myUserList > ~/Desktop/temp.txt
mv -f ~/Desktop/temp.txt ~/Desktop/myUserList

#remove my name from the list
myUsers=$(who | awk ‘{print $1;}’)
grep -v $myUsers ~/Desktop/myUserList > ~/Desktop/temp.txt
mv -f ~/Desktop/temp.txt ~/Desktop/myUserList

#change the password for everyone on the list to a seure password
for file in `cat ~/Desktop/myUserList`
 do
   echo -e "Cyb3rP4triot\!\nCyb3rP4triot\!" | passwd $file
 done

#prevent root logins
usermod -L root

#shutdown ipv4 and ipv6
echo 'net.ipv4.ip_forward = 0' >> /etc/sysctl.conf
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf

#securing cookies
sysctl -w net.ipv4.tcp_syncookies=1

#maybe aoutomate the search process for stuff like .txt files and output it to a text file on the desktop
find | grep .txt >> ~/Desktop/FlaggedFiles.txt
find | grep .jpg >> ~/Desktop/FlaggedFiles.txt
find | grep .png >> ~/Desktop/FlaggedFiles.txt
find | grep .mp3 >> ~/Desktop/FlaggedFiles.txt
find | grep .mp4 >> ~/Desktop/FlaggedFiles.txt
find | grep .mov >> ~/Desktop/FlaggedFiles.txt
find | grep .pdf >> ~/Desktop/FlaggedFiles.txt


#sed "s/PermitRootLogin */PermitRootLogin no/" ~/Desktop/die.txt > ~/Desktop/temp.txt