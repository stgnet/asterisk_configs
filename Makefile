all: pjsip-endpoints.conf res_digium_phone_phones.conf res_digium_phone_lines.conf

EXTENS=200 299

pjsip-endpoints.conf: FORCE
	echo "; $@ endpoint configured by Makefile" > $@
	(for ext in `seq $(EXTENS)`; do echo -e "[$$ext](endpoint,nat)\nauth=endpoint-auth\naors=$$ext\n[$$ext](aor)\nmailboxes=$$ext@default\n"; done ) >> $@

res_digium_phone_phones.conf: FORCE
	echo "; $@ configured by Makefile" > $@
	(for ext in `seq $(EXTENS)`; do echo -e "[$$ext](phone,vm)\nfull_name=Ext$$ext\npin=8$$ext\nline=$$ext\n;line=299\n"; done ) >> $@

res_digium_phone_lines.conf: FORCE
	echo "; $@ configured by Makefile" > $@
	(for ext in `seq $(EXTENS)`; do echo -e "[$$ext](secret)\ntype=line\n"; done ) >> $@

FORCE:
