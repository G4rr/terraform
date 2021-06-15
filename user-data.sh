#!/bin/bash
yum -y update
yum -y install httpd

myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`

cat <<EOF > /var/www/html/index.html
<html>
<body bgcolor="red">
<h2><font color="yellow">Build by Power of Terraform <font color="red"> v0.35</font></h2><br><p>
<font color="green">Server Private IP: <font color="aqua">$myip<br><br>
<font color="magenta">
<b>Version 4.0</b>
</body>
</html>
EOF

sudo service httpd start
chkconfig httpd on
