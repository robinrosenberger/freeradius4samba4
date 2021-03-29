# freeradius4samba4
This is a Freeradius Docker-container authorizing against an AD-Domain. Developed for linuxmuster7, but should work in any samba4 environment.
## Usage
Start the container using the `-it` and `--init` flags. The former to enable entering the join password, the latter to clean up pid files that would prevent starting winbindd after a reboot. Example:
```
docker run \
-it --init \
-e DC1=linuxmuster \
-e DC2=lan \
-e JOIN_USER=global-admin \
-p 1812:1812/udp
-v radius-samba-lib:/var/lib/samba/
-v radius-samba-conf:/etc/samba/
-v radius-conf:/etc/freeradius/3.0/
--name my-radius-server \
freeradius4samba4
```
The environment variables DC1 and DC2 make your DNS domainname, which you attempt to join as JOIN_USER. The values in the example are the defaults and match the defaults for linuxmuster7. Adjust to your needs.
For compatibility with linuxmuster7-webui's wifi access control, only users in a group called 'wifi' will be authorized. If you run a standard DC, either create that group and use it or remove/change the `--require-membership-of=` part of the uncommented call to `ntlm_auth` in the mschap and ntlm_auth module-configurations packed in the config.tar before building.
## Known limitations
- The container joins the domain as full-fledged DC, running as RODC resulted in authentication errors during testing. Any input on that matter is welcome.
- Freeradius pulls lots of dependencies during installation (looking at you, systemd...), but --no-install-recommends makes samba fail to join the domain. Maybe seperate the layers, but thats up to experimenting
- The container has only been tested in virtual environments using radtest for verification, no real hardware yet.
