all: pjsip-endpoints.conf res_digium_phone_phones.conf res_digium_phone_lines.conf res_digium_phone_line_secret.conf pjsip-auth-dpma.conf res_digium_phone_general.conf res_digium_phone_network_auto.conf voicemail-users.conf

AUTHNAME=dpmauser

IP=$(shell ip addr show |fgrep 'inet ' |fgrep -v 127.0.0.1 | sed 's/ *inet \([0-9.]*\).*/\1/')
CIDR=$(shell ip addr show |fgrep 'inet ' |fgrep -v 127.0.0.1 | sed 's/ *inet \([0-9./]*\).*/\1/')

pjsip-endpoints: FORCE
	echo "; $@ created by Makefile - DO NOT CHANGE" > $@
	( read HEADER ; while read LINE ;\
	do \
		echo "$$LINE" |tr ',' '\n' | (\
			read EXT;\
			read PIN;\
			read NAME;\
			read EMAIL;\
			read DID;\
			NAME="$${NAME#\"}";\
			NAME="$${NAME%\"}";\
			echo "[$$EXT](endpoint,nat)";\
			echo "auth=dpma-endpoint-auth";\
			echo "aors=$$EXT";\
			echo "callerid=$$NAME <$$EXT>";\
			echo "[$$EXT](aor)";\
			echo "mailboxes=$$EXT@default";\
			echo "";\
		);\
	done ) < generate/users.csv > $@

res_digium_phone_phones.conf: FORCE
	echo "; $@ created by Makefile - DO NOT CHANGE" > $@
	( read HEADER ; while read LINE ;\
	do \
		echo "$$LINE" |tr ',' '\n' | (\
			read EXT;\
			read PIN;\
			read NAME;\
			read EMAIL;\
			read DID;\
			NAME="$${NAME#\"}";\
			NAME="$${NAME%\"}";\
			echo "[$$EXT](phone,vm)";\
			echo "full_name=$$NAME";\
			echo "pin=$$PIN";\
			echo "line=$$EXT";\
			echo "";\
		);\
	done ) < generate/users.csv > $@

res_digium_phone_lines.conf: FORCE
	echo "; $@ created by Makefile - DO NOT CHANGE" > $@
	( read HEADER ; while read LINE ;\
	do \
		echo "$$LINE" |tr ',' '\n' | (\
			read EXT;\
			read PIN;\
			read NAME;\
			read EMAIL;\
			read DID;\
			NAME="$${NAME#\"}";\
			NAME="$${NAME%\"}";\
			echo "[$$EXT](secret)";\
			echo "type=line";\
			echo "";\
		);\
	done ) < generate/users.csv > $@

voicemail-users.conf: FORCE
	echo "; $@ created by Makefile - DO NOT CHANGE" > $@
	( read HEADER ; while read LINE ;\
	do \
		echo "$$LINE" |tr ',' '\n' | (\
			read EXT;\
			read PIN;\
			read NAME;\
			read EMAIL;\
			read DID;\
			NAME="$${NAME#\"}";\
			NAME="$${NAME%\"}";\
			echo "$$EXT => $$PIN,$$NAME,$$EMAIL";\
		);\
	done ) < generate/users.csv > $@

res_digium_phone_line_secret.conf: FORCE
	echo "; $@ created by Makefile - DO NOT CHANGE" > $@
	echo -e "; as it contains a plaintext password, do not add this file to git!\n" >> $@
	echo -e "[secret](!)\nauthname=$(AUTHNAME)\nsecret=$$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 |head -n 1)\n" >> $@

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
