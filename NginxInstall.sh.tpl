#!/bin/bash
sudo apt update -y
sudo apt install nginx -y
sudo chmod 647 /var/www/html/index.nginx-debian.html


cat <<EOF > /var/www/html/index.nginx-debian.html
<html>

${Hello}<br>

%{ for x in Names ~}
${Hello} to ${x} <br>
%{ endfor ~}

</html> 
EOF