all: pjsip-endpoints.conf res_digium_phone_phones.conf res_digium_phone_lines.conf res_digium_phone_line_secret.conf pjsip-auth-dpma.conf res_digium_phone_general.conf res_digium_phone_network_auto.conf

EXTENS=200 299

AUTHNAME=dpmauser

IP=$(shell hostname -i)
CIDR=$(shell ip addr show |fgrep 'inet ' |fgrep -v 127.0.0.1 | sed 's/ *inet \([0-9./]*\).*/\1/')


pjsip-endpoints.conf: FORCE
	echo "; $@ created by Makefile - DO NOT CHANGE" > $@
	(for ext in `seq $(EXTENS)`; do echo -e "[$$ext](endpoint,nat)\nauth=dpma-endpoint-auth\naors=$$ext\n[$$ext](aor)\nmailboxes=$$ext@default\n"; done ) >> $@

res_digium_phone_phones.conf: FORCE
	echo "; $@ created by Makefile - DO NOT CHANGE" > $@
	(for ext in `seq $(EXTENS)`; do echo -e "[$$ext](phone,vm)\nfull_name=Ext$$ext\npin=8$$ext\nline=$$ext\n;line=299\n"; done ) >> $@

res_digium_phone_line_secret.conf: FORCE
	echo "; $@ created by Makefile - DO NOT CHANGE" > $@
	echo -e "; as it contains a plaintext password, do not add this file to git!\n" >> $@
	echo -e "[secret](!)\nauthname=$(AUTHNAME)\nsecret=$$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 |head -n 1)\n" >> $@

res_digium_phone_lines.conf: FORCE
	echo "; $@ created by Makefile - DO NOT CHANGE" > $@
	(for ext in `seq $(EXTENS)`; do echo -e "[$$ext](secret)\ntype=line\n"; done ) >> $@

pjsip-auth-dpma.conf: res_digium_phone_line_secret.conf FORCE
	echo "; $@ created by Makefile - DO NOT CHANGE" > $@
	echo -e "[dpma-endpoint-auth]\ntype=auth\nauth_type=md5\nusername=$(AUTHNAME)\nmd5_cred=$$(echo -n $(AUTHNAME):asterisk:$$(fgrep secret= res_digium_phone_line_secret.conf | cut -d= -f 2) | md5sum | cut -c 1-32)\n" >> $@

res_digium_phone_general.conf: FORCE
	sed -i -e 's|mdns_address=.*|mdns_address=$(IP)|' -e 's|service_name=.*|service_name=$(HOSTNAME)|' $@

res_digium_phone_network_auto.conf: FORCE
	echo "; $@ created by Makefile - DO NOT CHANGE" > $@
	echo -e "[network-lan]\ntype=network\nalias=LAN\ncidr=$(CIDR)" >> $@
	echo -e "registration_address=$(IP)\nregistration_port=5060" >> $@
	echo -e "file_url_prefix=http://$(IP)/digium_phones/" >> $@
	echo -e "ntp_server=0.digium.pool.ntp.org" >> $@
	echo -e "sip_dscp=24\nrtp_dscp=46" >> $@ 
	echo -e "network_vlan_discovery_mode=LLDP\n" >> $@

	echo -e "[network-wan]\ntype=network\nalias=WAN\ncidr=0.0.0.0/0" >> $@
	echo -e "registration_address=$(IP)\nregistration_port=5060" >> $@
	echo -e "file_url_prefix=http://$(IP)/digium_phones/" >> $@
	echo -e "ntp_server=0.digium.pool.ntp.org" >> $@
	echo -e "sip_dscp=24\nrtp_dscp=46" >> $@ 
	echo -e "network_vlan_discovery_mode=LLDP\n" >> $@

FORCE:
