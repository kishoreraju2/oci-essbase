#!/bin/bash
#
# Copyright (c) 2019, Oracle and/or its affiliates. All rights reserved.
#

# Trap for script exit
onComplete() {
  rv=$?
  echo "Oracle Essbase VM initialization finished with error code $rv"
  #sudo rm -rf /tmp/essbase_config.json
}

trap onComplete EXIT
set -e

# Read version file
image_version=`sudo cat /etc/essbase/image_version.txt`
echo Using image ${image_version}

# Update the global env settings
echo Updating the global env settings for this instance
sudo /bin/bash <<EOF
echo 'DOMAIN_HOME=/u01/config/domains/essbase_domain' >> /etc/essbase/env
echo 'ARBORPATH=/u01/data/essbase' >> /etc/essbase/env
EOF

# Run the configuration script as oracle user
# This is needed to be done to make sure limits are applied
echo Running configuration script as oracle user
sudo -i -u oracle /u01/vmtools/configure.sh
rv=$?
if [ $rv -ne 0 ]; then
  exit $rv
fi

# Run the post configuration script as root
sudo /bin/bash -e <<EOF

# Move the demo certs and enable in ssl.conf
echo Processing certificate files
mv /etc/essbase/demo-ca.crt   /etc/pki/tls/certs
mv /etc/essbase/demo-cert.crt /etc/pki/tls/certs
mv /etc/essbase/demo-cert.key /etc/pki/tls/private
sed -i 's|SSLCertificateFile .*$|SSLCertificateFile /etc/pki/tls/certs/demo-cert.crt|g' /etc/httpd/conf.d/ssl.conf
sed -i 's|SSLCertificateKeyFile .*$|SSLCertificateKeyFile /etc/pki/tls/private/demo-cert.key|g' /etc/httpd/conf.d/ssl.conf

# Run post configuration
/u01/vmtools/post-configure.sh

# Update the essbase service to include the mount information for reboot
sed -i 's|#RequiresMountsFor=.*$|RequiresMountsFor=/u01/config /u01/data|g' /etc/systemd/system/essbase.service
systemctl daemon-reload
EOF
rv=$?
exit $rv
