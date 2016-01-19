#!/bin/bash
set -Eeo pipefail

# TODO: Provide a build that will work for Gigayak.

cert_path=""
update_command=()
if [[ "$HOST_OS" == "centos" ]]
then
  echo "Found CentOS host" >&2
  cert_dir="/etc/pki/ca-trust/source/anchors"
  update_command=(update-ca-trust extract)
elif [[ "$HOST_OS" == "ubuntu" ]]
then
  echo "Found Ubuntu host" >&2
  cert_dir="/usr/local/share/ca-certificates"
  mkdir -pv "$cert_dir"
  update_command=(update-ca-certificates --verbose)
else
  echo "Unknown host OS '$HOST_OS'" >&2
  exit 1
fi

cat > "$cert_dir/gigayak.pem" <<'EOF'
-----BEGIN CERTIFICATE-----
MIIKADCCBeigAwIBAgIBATANBgkqhkiG9w0BAQsFADCBnjE+MDwGA1UEAxM1TWFj
aGluZSBBdWRpbyBSZXNlYXJjaCBJbnRlcm5hbCBDZXJ0aWZpY2F0ZSBBdXRob3Jp
dHkxGTAXBgNVBAsTEEludGVybmFsIE5ldHdvcmsxHzAdBgNVBAoTFk1hY2hpbmUg
QXVkaW8gUmVzZWFyY2gxEzARBgNVBAgTCkNhbGlmb3JuaWExCzAJBgNVBAYTAlVT
MCIYDzIwMTUwMTE1MDIwMDQzWhgPMjAyNTAxMTIwMjAwNDNaMIGeMT4wPAYDVQQD
EzVNYWNoaW5lIEF1ZGlvIFJlc2VhcmNoIEludGVybmFsIENlcnRpZmljYXRlIEF1
dGhvcml0eTEZMBcGA1UECxMQSW50ZXJuYWwgTmV0d29yazEfMB0GA1UEChMWTWFj
aGluZSBBdWRpbyBSZXNlYXJjaDETMBEGA1UECBMKQ2FsaWZvcm5pYTELMAkGA1UE
BhMCVVMwggQiMA0GCSqGSIb3DQEBAQUAA4IEDwAwggQKAoIEAQC3nJK6xv8yvqg9
VOnbxJwZKkrTsD+9a76ZMpB/PLoc+YWt7bk7LTWdSDrh2q8k8YjwB9smyHB1O2q+
Ow0Te3XHZ2i3GiOmeSvcvahRrRbYYlVfLDiyvlcTEhydEXfGjQ+cotjEFC1rZgpT
u9rf+cACYEy1o5IRaNKaUE08Qi3AMHhnCRfx6SMqKzrdte0XKdCJfwx5f2bOmXaV
2wB2Q+nNIqBthIdEp5kGDhMRd0ENksGgPR5tpHUced5Df2PEmazfLDORaI+xbR0t
YkXNr7SMyY0nov6lsbR/YjuW7kTPvkOevM2byUK8m53ZR2kvEEBEqAZiJvi6Ep9C
kCiksjhZDIHREI2AOnOMQlwY6aCSbjpz4ZSclcNyjewVyABcyl1Jo3fb++noGwhr
OsqTXYtClkSXhTGSvs3i3pRJY7z1owONG6k4qrLJC6/ikswTdAtxn33qBorpLrku
iBFoTlCpP6vjXFsel6kCH8u7+BzFf8tdY61Oj/vIHG64x0dnNqQRXgq66Z5WvuX5
Z3M/VgEKgkiyKDefnDXmmAqDLNGzqxw3DYsXMdwD9wo1e5JyCRWl98agoH8hCeo0
SKrrwQte9XnqoFvXtaVovvao2KAfa0e7rVuaW8281zpfEBioh4qNrbid84eGdybH
+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
hc3Ekx13T+TlLchIipENa7ZAtt0=
-----END CERTIFICATE-----
EOF

# Ubuntu appears to demand that it see a PEM file with suffix .crt.
# Which... makes no sense, given .crt is traditionally DER-encoded.
cp -fv \
  "$cert_dir/gigayak.pem" \
  "$cert_dir/gigayak_as_pem.crt"

${update_command[@]}
