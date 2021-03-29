#!/bin/bash

join_domain(){

sed -i s/LMN/$DC1/g /etc/freeradius/3.0/mods-enabled/mschap
sed -i s/LMN/$DC1/g /etc/freeradius/3.0/mods-enabled/ntlm_auth

rm /etc/samba/* -r
rm /var/lib/samba/* -r

usermod -aG winbindd_priv freerad
mkdir /var/lib/samba/winbindd_privileged
chown root:winbindd_priv /var/lib/samba/winbindd_privileged
chmod 750 /var/lib/samba/winbindd_privileged

samba-tool domain join "$DC1"."$DC2" $ROLE -U $JOIN_USER && touch /var/lib/samba/domjoin.log
sed -i '6 a ntlm auth = yes' /etc/samba/smb.conf || {
	echo "Could not join domain "$DC1"."$DC2", try setting DC1 and DC2 environment variables"
	exit 1
	}
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
