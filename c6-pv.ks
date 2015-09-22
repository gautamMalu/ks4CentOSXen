#version=RHEL7
# System authorization information
auth --enableshadow --passalgo=sha512
url --url http://mirror.centos.org/centos/6/os/x86_64/
text
# Run the Setup Agent on first boot
firstboot --enable
# Keyboard layouts
keyboard us
# System language
lang en_US.UTF-8

network  --bootproto=dhcp --device=eth0 --ipv6=auto --activate
network  --hostname=localhost.localdomain
# Root password
rootpw --iscrypted $6$5.3h9SNTNmaIsD6S$lQYgTj.pMZGbl6VzEEjSos1Bf7FKC8GmVoSNyvhPA8X5OmvFareJXGKJ3g.J8JtQbUyUpArcSEP2QWdVKgcrp0
# System timezone
timezone America/New_York --isUtc
# System bootloader configuration
#bootloader --append="console=hvc0"--location=mbr --driveorder=xvda
bootloader --append="console=hvc0" --location=mbr
zerombr
clearpart --all
# Disk partitioning information
part pv.123 --fstype="lvmpv"  --size=3587
part /boot --fstype="ext4" --size=500
volgroup centos --pesize=4096 pv.123
logvol /  --fstype="ext4" --size=3324 --name=root --vgname=centos
logvol swap  --fstype="swap" --size=256 --name=swap --vgname=centos

 
%packages --nobase
@core
%end


%post --log=/var/log/anaconda/ks.post.log
#!/bin/bash
# removing HWADDR line from network config file
# as mac address keeps changing with when it will be
# used as Xen PV guest
dev=`ip route show | grep 'default' | awk '{print $5}'`
/bin/sed -i '/HWADDR/d' /etc/sysconfig/network-scripts/ifcfg-$dev

#adding firstboot.sh file to set new root password
echo '#''!''/''bin''/''sh' >> /etc/profile.d/firstboot.sh
echo 'if' 'cat' '/''etc''/''issue' '|' 'grep' '-''q' '"''Login''"'';' 'then' >> /etc/profile.d/firstboot.sh
echo "  "'sed' '-i' "'"'/password/'',''$d'"'" '/etc/rc.d/rc.local' >> /etc/profile.d/firstboot.sh
echo "  "'sed' '-i' "'"'/Login/'',''$d'"'" '/etc/issue' >> /etc/profile.d/firstboot.sh
echo "  "'rm' '/''etc''/''profile.d''/''firstboot.sh' >> /etc/profile.d/firstboot.sh
echo 'fi' >> /etc/profile.d/firstboot.sh
echo "Added firstboot.sh"



echo "#" "setting a random password on fist boot" >> /etc/rc.d/rc.local
echo 'pass''=''$(dd if=/dev/urandom count=50|md5sum)' >> /etc/rc.d/rc.local
echo "echo" '$pass | passwd --stdin root' >> /etc/rc.d/rc.local
echo "echo" '"Login as root with password $pass"' '>>' '/etc/issue' >> /etc/rc.d/rc.local
echo "echo" '"Please change your password after login"' '>>' '/etc/issue' >> /etc/rc.d/rc.local

chmod +x /etc/rc.d/rc.local
echo "added modifiled rc.local for firstboot setup"

%end
