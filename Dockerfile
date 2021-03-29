FROM debian
RUN apt-get update && apt-get install freeradius samba winbind -y
EXPOSE 1812/UDP
VOLUME /var/lib/samba/
VOLUME /etc/samba/
VOLUME /etc/freeradius/3.0/
ADD configs.tar /

ENV DC1=linuxmuster
ENV DC2=lan
ENV JOIN_USER=global-admin
ENV ROLE=DC

COPY entrypoint.sh /
CMD ["/entrypoint.sh"]

