#!/bin/bash
workdir=$(dirname $0)
apt-get update
apt-get install freeradius -y
usermod -aG winbindd_priv freerad
chown root:winbindd_priv /var/lib/samba/winbindd_privileged
chmod 750 /var/lib/samba/winbindd_privileged
tar xf $workdir/configs.tar -C /
NETBIOS=$(cat /etc/samba/smb.conf | grep workgroup | grep -v '#' | cut -d '=' -f2 | tr -d ' ')
sed -i s/LMN/$NETBIOS/g /etc/freeradius/3.0/mods-enabled/mschap
sed -i s/LMN/$NETBIOS/g /etc/freeradius/3.0/mods-enabled/ntlm_auth
sed -i s/mschapv2-and-ntlmv2-only/yes/g /etc/samba/smb.conf
systemctl enable freeradius.service
echo "Restart your samba-service, samba-ad-dc on a domain controller, smbd on a member"
