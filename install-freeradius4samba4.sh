#!/bin/bash
apt-get update
apt-get install freeradius -y
usermod -aG winbindd_priv freerad
chown root:winbindd_priv /var/lib/samba/winbindd_privileged
chmod 750 /var/lib/samba/winbindd_privileged
tar xf configs.tar -C /
NETBIOS=$(grep workgroup /etc/samba/smb.conf | cut -d '=' -f2 | tr -d ' ')
sed -i s/LMN/$NETBIOS/g /etc/freeradius/3.0/mods-enabled/mschap
sed -i s/LMN/$NETBIOS/g /etc/freeradius/3.0/mods-enabled/ntlm_auth
sed -i s/mschapv2-and-ntlmv2-only/yes/g /etc/samba/smb.conf
systemctl enable freeradius.service
