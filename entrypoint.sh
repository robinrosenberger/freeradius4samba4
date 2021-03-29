#!/bin/bash

join_domain(){

rm /etc/samba/* -r
rm /var/lib/samba/* -r

usermod -aG winbindd_priv freerad
mkdir /var/lib/samba/winbindd_privileged
chown root:winbindd_priv /var/lib/samba/winbindd_privileged
chmod 750 /var/lib/samba/winbindd_privileged

samba-tool domain join $DOMAIN $ROLE -U $JOIN_USER && touch /var/lib/samba/domjoin.log
sed -i '6 a ntlm auth = yes' /etc/samba/smb.conf || {
	echo "Could not join domain $DOMAIN, set DOMAIN environment variable to your DNS-Domain"
	exit 1
	}

NETBIOS=$(grep workgroup /etc/samba/smb.conf | cut -d '=' -f2 | tr -d ' ')
sed -i s/LMN/$NETBIOS/g /etc/freeradius/3.0/mods-enabled/mschap
sed -i s/LMN/$NETBIOS/g /etc/freeradius/3.0/mods-enabled/ntlm_auth

}

[ ! -e /var/lib/samba/domjoin.log ] && join_domain
samba -i &
freeradius -X &

while sleep 60
do
unset fail
ps -aux | grep samba | grep -v grep || fail=1
ps -aux | grep freeradius | grep -v grep || fail=1
[ $fail ] && echo 'Something went wrong, exiting' && exit 1
done
