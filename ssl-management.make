
###############################################################################
#
# Manage SSL certificates
#
# 2012-12-31 Sebastian Krohn <seb@gaia.sunn.de>
#

# Usage
# =====
#
# make new host=<fqdn> [SAN="list of SAN"]
#
#    This creates a new key and CSR for the hostname specified. After getting
#    the certificate back from the CA, make sure to place it in
#    cert/<fqdn>.pem. Otherwise other feature of this script won't work!
#
# make renew host=<fqdn>
#
#    This created a new CSR for the hostname specified based on the old
#    certificate. The current certificate will also be archived. Make sure to
#    put the new certificate in cert/<fqdn>.pem as with "make new".
#
# make check_expiry
#
#    Will display expiration times of issued certificates. Needs to be extended
#    to do monitoring of upcoming expiration dates.
#
# make pkcs12 host=<fqdn>
#
#    Creates a PKCS#12 format key file containing both the private key as well
#    as the certificate. OpenSSL will ask you for a password to protect the
#    key. We need this e.g. for the Ironports.
#
# make sign host=<fqdn>
#
#	Sign a generated CSR with our own CA. This is not very elegant so make sure
#	to check how it works first.
#
# 
# TODO:
#
#  - add deployment
#  - add checking of certificates being used by connecting to the hosts and
#    comparing with local certificates
#  - add monitoring for expiring certificates

KEYSIZE = 2048


CNF += [ req ]\n
CNF += default_bits        = 2048\n
CNF += default_keyfile     = privkey.pem\n
CNF += distinguished_name  = req_distinguished_name\n
CNF += req_extensions      = req_ext\n
CNF += \n
CNF += [ req_distinguished_name ]\n
CNF += countryName                 = Country Name (2 letter code)\n
CNF += countryName_default         = <<MyCC>>\n
CNF += stateOrProvinceName         = State or Province Name (full name)\n
CNF += stateOrProvinceName_default = <<MyState>>\n
CNF += localityName                = Locality Name (eg, city)\n
CNF += localityName_default        = <<MyCity>>\n
CNF += organizationName            = Organization Name (eg, company)\n
CNF += organizationName_default    = <<MyOrg>>\n
CNF += commonName                  = Common Name (eg, YOUR name)\n
CNF += commonName_max              = 64\n
CNF += \n
CNF += [ req_ext ]\n
CNF += subjectAltName          = @alt_names\n
CNF += \n
CNF += [alt_names]\n

.PHONY: .cnf



###############################################################################
# supporting targets

.cnf:
	@echo -e '$(CNF)' > .cnf

check_domain:
ifndef host
	@echo parameter \"host\" missing, check README
	@exit 1
endif

check_openssl:
	@which openssl &>/dev/null

echo_csr: check_domain check_openssl
ifeq ($(wildcard csr/$(host).pem),)
	@echo "Can't find the CSR - something is horribly wrong!"
	@exit 1
endif

	openssl req -noout -text -in "csr/$(host).pem"
	@echo "Now head over to your CA and submit this CSR:"
	@cat "csr/$(host).pem"
	@echo "... or use make sign right here"

check_dirs:
	@mkdir -p private public csr


###############################################################################
# new host - create keys and CSR
new: check_domain check_openssl check_dirs .cnf
	@n=1 ; \
		for x in $(host) $(SAN); do \
			echo "DNS.$$n = $$x" >> .cnf ; \
			let "n+=1" ; \
		done

ifneq ($(wildcard private/$(host).pem),)
	@echo private/$(host).pem does already exist, making new csr using that key
	openssl req -new -sha256 \
			-key "private/$(host).pem" \
			-config .cnf \
			-subj '/CN=$(host)/O=<<MyOrg>>/C=<<MyCC>>/ST=<<MyState>>/L=<<MyCity>>' \
			-out "csr/$(host).pem"
else
	@echo private/$(host).pem does not exist, making new key
	openssl req -new -sha256 \
			-newkey rsa:$(KEYSIZE) -nodes \
			-config .cnf \
			-subj '/CN=$(host)/O=<<MyOrg>>/C=<<MyCC>>/ST=<<MyState>>/L=<<MyCity>>' \
			-keyout "private/$(host).pem" \
			-out "csr/$(host).pem"
endif

	git add "csr/$(host).pem" "private/$(host).pem"
	make echo_csr host=$(host)
	@rm -f .cnf


###############################################################################
# convert private key and certificate into pkcs#12 format
pkcs12: check_domain check_openssl
ifeq ($(wildcard private/$(host).pem),)
		@echo private/$(host).pem does not exist - you need to create it first
		@exit 1
endif
ifeq ($(wildcard cert/$(host).pem),)
		@echo cert/$(host).pem does not exist - you need to create it first
		@exit 1
endif

	openssl pkcs12 -export \
			-inkey "private/$(host).pem" \
			-in "cert/$(host).pem" \
			-out "private/$(host).p12"

	git add "private/$(host).p12"

###############################################################################
# renew csr to be signed by CA
renew: check_domain check_openssl .cnf
ifeq ($(wildcard private/$(host).pem),)
	@echo private/$(host).pem does not exists, use \"new\" instead
	@exit 1
endif

ifeq ($(wildcard cert/$(host).pem),)
	@echo cert/$(host).pem does not exist - something is wrong here!
	@exit 1
endif

ifneq ($(wildcard csr/$(host).pem),)
	$(eval SAN = $(shell openssl req -text -in "csr/$(host).pem" | \
            sed -n -e '/^\s\+Subject: .*CN=\([^$$ ,\/]*\).*/{s//\1/;h}' \
		   -e '/DNS:/{s///g; s/^\s\+//;s/, / /g;p;q}; $${g;p}' ) )

	@n=1 ; \
		for x in $(SAN); do \
			echo "DNS.$$n = $$x" >> .cnf ; \
			let "n+=1" ; \
		done

else
	@echo csr/$(host).pem does not exist - something is wrong here!
	@exit 1
endif

	openssl req -new -sha256 \
			-key "private/$(host).pem" \
			-config .cnf \
			-subj '/CN=$(host)/O=<<MyOrg>>/C=<<MyCC>>/ST=<<MyState>>/L=<<MyCity>>' \
			-out "csr/$(host).pem"

	@echo removing current certificate
	rm "cert/$(host).pem"

	git add "csr/$(host).pem"
	make echo_csr host=$(host)

###############################################################################
# Sign a generated CSR with our own CA.

sign: check_domain check_openssl check_existing_csr check_existing_ca 
	openssl x509 -req \
		-in "csr/$(host).pem" \
		-CA ~/.ca/ca.pem \
		-CAkey ~/.ca/ca.key \
		-out "public/$(host).pem" \
		-days 9999 \
		-CAcreateserial -CAserial ~/.ca/ca.seq

check_existing_csr:
ifeq ($(wildcard csr/$(host).pem),)
	@echo can not find CSR - you need to create a CSR first
	@exit 1
endif

check_existing_ca: check_dirs
	test -d ~/.ca/
	test -f ~/.ca/ca.pem
	test -f ~/.ca/ca.key

###############################################################################
# check certificate expiry dates
check_expiry: check_openssl
	@$(foreach h,$(wildcard cert/*.pem), echo -e "\n\n$(h)\n"; openssl x509 -noout -in $(h) -dates;)

