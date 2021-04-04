#!/bin/bash

join_domain(){

usermod -aG winbindd_priv freerad
mkdir /var/lib/samba/winbindd_privileged
chown root:winbindd_priv /var/lib/samba/winbindd_privileged
chmod 750 /var/lib/samba/winbindd_privileged

echo Please provide your DNS-Domain:
read DOMAIN
echo Please provide your NETBIOS-Domain:
read NETBIOS

echo Preparing smb.conf...
cat << EOF > /etc/samba/smb.conf
[global]
workgroup = $NETBIOS
realm = $DOMAIN
server role = member server
EOF
echo Preparing freeradius modules...
sed -i s/LMN/$NETBIOS/g /etc/freeradius/3.0/mods-enabled/mschap
sed -i s/LMN/$NETBIOS/g /etc/freeradius/3.0/mods-enabled/ntlm_auth
echo Joining domain...
net ads join -U $JOIN_USER && touch /var/lib/samba/domjoin.log
}

[ ! -e /var/lib/samba/domjoin.log ] && join_domain
winbindd -i &
freeradius -X &

while sleep 60
do
unset fail
ps -aux | grep winbindd | grep -v grep || fail=1
ps -aux | grep freeradius | grep -v grep || fail=1
[ $fail ] && echo 'Something went wrong, exiting' && exit 1
done
