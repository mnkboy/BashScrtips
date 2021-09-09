Guia instalacion 18.04
=============================================
================= PARTE 0.- =================
=============================================
//-----------------------
EN AWS
Route 53 / Zonas hospedadas / school-manager.education
Crear un registro para IP V4
Crear un registro para IP V6
=============================================
================= PARTE 0.- =================
=============================================
                         

=============================================
================= PARTE 1.- =================
=============================================
lvresize --size +750G /dev/vg00/var && lvresize --size +50G /dev/vg00/home && lvresize --size +50G /dev/vg00/usr
resize2fs /dev/vg00/var && resize2fs /dev/vg00/home && resize2fs /dev/vg00/usr && df -h

apt update && apt upgrade -y

echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf

echo 'sysctl -w net.core.somaxconn=65535' >> /etc/rc.local

reboot

=============================================
================= PARTE 1.- =================
=============================================


                                                               
=============================================
================= PARTE 2.- =================
=============================================
Bb@14785236
#CAMBIAR el nombre de la instalacion OJO
wget https://ubuntu.bigbluebutton.org/bbb-install.sh && chmod +x bbb-install.sh
./bbb-install.sh -v bionic-23 -s bbb5.school-manager.education <--- OJO CAMBIAR EL NOMBRE DE LA INSTALACION


rm bbb-install.sh
mkdir /etc/nginx/ssl
//Origen --> //Destino
scp root@bbb1.school-manager.education:/etc/nginx/ssl/* /etc/nginx/ssl


scp root@bbb1.school-manager.education:/var/www/bigbluebutton-default/images/favicon.png /var/www/bigbluebutton-default/images/favicon.png 
scp root@bbb1.school-manager.education:/var/www/bigbluebutton-default/favicon.ico /var/www/bigbluebutton-default/favicon.ico 
scp root@bbb1.school-manager.education:/var/www/bigbluebutton-default/default.pdf /var/www/bigbluebutton-default/default.pdf 

=============================================
================= PARTE 2.- =================
=============================================

=============================================
================= PARTE 3.- =================
=============================================

sed -i '5i listen 443 ssl;' /etc/nginx/sites-available/bigbluebutton
sed -i '6i listen [::]:443 ssl;' /etc/nginx/sites-available/bigbluebutton
sed -i '7i ssl_certificate /etc/nginx/ssl/fullchain.pem;' /etc/nginx/sites-available/bigbluebutton
sed -i '8i ssl_certificate_key /etc/nginx/ssl/privkey.pem;' /etc/nginx/sites-available/bigbluebutton
sed -i '9i ssl_session_cache shared:SSL:10m;' /etc/nginx/sites-available/bigbluebutton
sed -i '10i ssl_protocols TLSv1 TLSv1.1 TLSv1.2;' /etc/nginx/sites-available/bigbluebutton
sed -i '11i ssl_ciphers "ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:ECDH+3DES:DH+3DES:RSA+AESGCM:RSA+AES:RSA+3DES:!aNULL:!MD5:!DSS:!AES256";' /etc/nginx/sites-available/bigbluebutton
sed -i '12i ssl_prefer_server_ciphers on;' /etc/nginx/sites-available/bigbluebutton
sed -i '13i ssl_dhparam /etc/nginx/ssl/dhp-4096.pem;' /etc/nginx/sites-available/bigbluebutton

#Verificamos nuestra propia ip
ip addr

cat > /etc/nginx/conf.d/bigbluebutton_sip_addr_map.conf <<EOF
map \$remote_addr \$freeswitch_addr {
    "~:"    [fe80::d250:99ff:fedf:e0fc];
    default    74.208.211.182;
}
EOF


cat > /etc/bigbluebutton/nginx/sip.nginx << EOF
location /ws {
        proxy_pass https://\$freeswitch_addr:7443;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_read_timeout 6h;
        proxy_send_timeout 6h;
        client_body_timeout 6h;
        send_timeout 6h;

        auth_request /bigbluebutton/connection/checkAuthorization;
        auth_request_set \$auth_status \$upstream_status;
}
EOF

cat /etc/nginx/conf.d/bigbluebutton_sip_addr_map.conf
cat /etc/bigbluebutton/nginx/sip.nginx
=============================================
================= PARTE 3.- =================
=============================================


=============================================
================= PARTE 4.- =================
=============================================

sed -i 's/worker_connections 768/worker_connections 6000/g' /etc/nginx/nginx.conf
sed -i 's/30m/150m/g' /etc/bigbluebutton/nginx/web.nginx 
sed -i 's/maxFileSizeUpload=30000000/maxFileSizeUpload=150000000/g'  /usr/share/bbb-web/WEB-INF/classes/bigbluebutton.properties 
sed -i 's/uploadSizeMax: 50000000/uploadSizeMax: 150000000/g' /usr/share/meteor/bundle/programs/server/assets/app/config/settings.yml 
sed -i 's/bigbluebutton.web.serverURL=http/bigbluebutton.web.serverURL=https/g' /usr/share/bbb-web/WEB-INF/classes/bigbluebutton.properties

sed -i 's/url: http\:\/\//url: https\:\/\//g' /usr/share/meteor/bundle/programs/server/assets/app/config/settings.yml
sed -i 's/wsUrl: ws\:/wsUrl: wss\:/g' /usr/share/meteor/bundle/programs/server/assets/app/config/settings.yml
sed -i 's/playback_protocol\: http/playback_protocol\: https/g' /usr/local/bigbluebutton/core/scripts/bigbluebutton.yml 
sed -i 's/<!--<param name=\"enable-3pcc\" value=\"true\"\/>-->/<param name=\"enable-3pcc\" value=\"proxy\"\/>/g'  /opt/freeswitch/conf/sip_profiles/external-ipv6.xml

sed -i -e 's|defaultWelcomeMessage=.*|defaultWelcomeMessage=Bienvenido a <b>%%CONFNAME%%</b>!<br>|g' /usr/share/bbb-web/WEB-INF/classes/bigbluebutton.properties
sed -i -e 's|defaultWelcomeMessageFooter=.*|defaultWelcomeMessageFooter=.|g' /usr/share/bbb-web/WEB-INF/classes/bigbluebutton.properties
sed -i -e 's|userInactivityInspectTimerInMinutes=.*|userInactivityInspectTimerInMinutes=2|g' /usr/share/bbb-web/WEB-INF/classes/bigbluebutton.properties
sed -i -e 's|userInactivityThresholdInMinutes=.*|userInactivityThresholdInMinutes=15|g' /usr/share/bbb-web/WEB-INF/classes/bigbluebutton.properties
sed -i -e 's|userActivitySignResponseDelayInMinutes=.*|userActivitySignResponseDelayInMinutes=5|g' /usr/share/bbb-web/WEB-INF/classes/bigbluebutton.properties


=============================================
================= PARTE 4.- =================
=============================================


=============================================
================= PARTE 5.- =================
=============================================

cp /usr/share/bbb-web/WEB-INF/classes/spring/turn-stun-servers.xml /usr/share/bbb-web/WEB-INF/classes/spring/turn-stun-servers.original

cat  > /usr/share/bbb-web/WEB-INF/classes/spring/turn-stun-servers.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.springframework.org/schema/beans
        http://www.springframework.org/schema/beans/spring-beans-2.5.xsd">

    <bean id="stun0" class="org.bigbluebutton.web.services.turn.StunServer">
        <constructor-arg index="0" value="stun:sturn.aulaescolar.mx"/>
    </bean>


    <bean id="turn0" class="org.bigbluebutton.web.services.turn.TurnServer">
        <constructor-arg index="0" value="7db29d66755c37a95a478f99cb019750"/>
        <constructor-arg index="1" value="turns:sturn.aulaescolar.mx:443?transport=tcp"/>
        <constructor-arg index="2" value="86400"/>
    </bean>
    
    <bean id="turn1" class="org.bigbluebutton.web.services.turn.TurnServer">
        <constructor-arg index="0" value="7db29d66755c37a95a478f99cb019750"/>
        <constructor-arg index="1" value="turn:sturn.aulaescolar.mx:443?transport=tcp"/>
        <constructor-arg index="2" value="86400"/>
    </bean>

    <bean id="stunTurnService"
            class="org.bigbluebutton.web.services.turn.StunTurnService">
        <property name="stunServers">
            <set>
                <ref bean="stun0"/>
            </set>
        </property>
        <property name="turnServers">
            <set>
                <ref bean="turn0"/>
                <ref bean="turn1"/>
            </set>
        </property>
    </bean>
</beans>
EOF

yq w -i /usr/share/meteor/bundle/programs/server/assets/app/config/settings.yml public.kurento.cameraProfiles.[6].bitrate 30
yq w -i /usr/share/meteor/bundle/programs/server/assets/app/config/settings.yml public.kurento.cameraProfiles.[6].default true 
yq w -i /usr/share/meteor/bundle/programs/server/assets/app/config/settings.yml public.kurento.cameraProfiles.[7].bitrate 80
yq w -i /usr/share/meteor/bundle/programs/server/assets/app/config/settings.yml public.kurento.cameraProfiles.[7].default false
yq w -i /usr/share/meteor/bundle/programs/server/assets/app/config/settings.yml public.kurento.cameraProfiles.[8].bitrate 130
yq w -i /usr/share/meteor/bundle/programs/server/assets/app/config/settings.yml public.kurento.cameraProfiles.[8].default false
yq w -i /usr/share/meteor/bundle/programs/server/assets/app/config/settings.yml public.kurento.cameraProfiles.[9].bitrate 180
yq w -i /usr/share/meteor/bundle/programs/server/assets/app/config/settings.yml public.kurento.cameraProfiles.[9].default false

chown meteor:meteor /usr/share/meteor/bundle/programs/server/assets/app/config/settings.yml

sed -i -e 's/LimitCORE=infinity/#LimitCORE=infinity/g' /lib/systemd/system/freeswitch.service
sed -i -e 's/LimitNOFILE=100000/#LimitNOFILE=100000/g' /lib/systemd/system/freeswitch.service
sed -i -e 's/LimitNPROC=60000/#LimitNPROC=60000/g' /lib/systemd/system/freeswitch.service
sed -i -e 's/LimitSTACK=250000/#LimitSTACK=250000/g' /lib/systemd/system/freeswitch.service
sed -i -e 's/LimitRTPRIO=infinity/#LimitRTPRIO=infinity/g' /lib/systemd/system/freeswitch.service
sed -i -e 's/LimitRTTIME=7000000/#LimitRTTIME=7000000/g' /lib/systemd/system/freeswitch.service
sed -i -e 's/IOSchedulingClass=realtime/#IOSchedulingClass=realtime/g' /lib/systemd/system/freeswitch.service
sed -i -e 's/IOSchedulingPriority=2/#IOSchedulingPriority=2/g' /lib/systemd/system/freeswitch.service
sed -i -e 's/CPUSchedulingPolicy=rr/#CPUSchedulingPolicy=rr/g' /lib/systemd/system/freeswitch.service
sed -i -e 's/CPUSchedulingPriority=89/#CPUSchedulingPriority=89/g' /lib/systemd/system/freeswitch.service

sed -i '32i LimitCORE=infinity'  /lib/systemd/system/freeswitch.service
sed -i '33i LimitNOFILE=999999'  /lib/systemd/system/freeswitch.service
sed -i '34i LimitNPROC=infinity'  /lib/systemd/system/freeswitch.service
sed -i '35i LimitSTACK=250000'  /lib/systemd/system/freeswitch.service
sed -i '36i LimitDATA=infinity'  /lib/systemd/system/freeswitch.service
sed -i '37i LimitFSIZE=infinity'  /lib/systemd/system/freeswitch.service
sed -i '38i LimitSIGPENDING=infinity'  /lib/systemd/system/freeswitch.service
sed -i '39i LimitMSGQUEUE=infinity'  /lib/systemd/system/freeswitch.service
sed -i '40i LimitAS=infinity'  /lib/systemd/system/freeswitch.service
sed -i '41i LimitLOCKS=infinity'  /lib/systemd/system/freeswitch.service
sed -i '42i LimitMEMLOCK=infinity'  /lib/systemd/system/freeswitch.service
sed -i '43i LimitRTPRIO=infinity'  /lib/systemd/system/freeswitch.service
sed -i '44i LimitRTTIME=7000000'  /lib/systemd/system/freeswitch.service
sed -i '45i IOSchedulingClass=realtime'  /lib/systemd/system/freeswitch.service
sed -i '46i IOSchedulingPriority=2'  /lib/systemd/system/freeswitch.service
sed -i '47i CPUSchedulingPolicy=rr'  /lib/systemd/system/freeswitch.service
sed -i '48i CPUSchedulingPriority=89'  /lib/systemd/system/freeswitch.service
sed -i '49i \\n'  /lib/systemd/system/freeswitch.service


=============================================
================= PARTE 5.- =================
=============================================

=============================================
================= PARTE 6.- =================
=============================================
systemctl daemon-reload
systemctl restart freeswitch.service redis.service kurento-media-server.service
systemctl status freeswitch.service redis.service kurento-media-server.service

bbb-conf --setsecret ybmUHtwDPuDXJSyrgr2OpqV00fFYAx2QIUBt05NBo
bbb-conf --restart
bbb-conf --check

=============================================
================= PARTE 6.- =================
=============================================


=============================================
================= PARTE 7.- =================
=============================================
-----------------------------------------------
------------ CONFIGURACION KURENTO ------------
-----------------------------------------------
echo "stunServerAddress=172.217.212.127" >> /etc/kurento/modules/kurento/WebRtcEndpoint.conf.ini
echo "stunServerPort=19302" >> /etc/kurento/modules/kurento/WebRtcEndpoint.conf.ini

72  groupadd -g 2000 scalelite-spool
73  usermod -a -G scalelite-spool bigbluebutton
74  mkdir /home/bigbluebutton
75  chown bigbluebutton:bigbluebutton /home/bigbluebutton
76  usermod -d   /home/bigbluebutton  bigbluebutton
77  su - bigbluebutton -s /bin/bash
78  mkdir -p ~/.ssh ; chmod 0700 ~/.ssh
79  cat > .ssh/scalelite << EOF
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACBTlkj7uBUhuEQJjI9XXF5f8xUkrHVXlvULZYXoY7EePwAAAKBomp+LaJqf
iwAAAAtzc2gtZWQyNTUxOQAAACBTlkj7uBUhuEQJjI9XXF5f8xUkrHVXlvULZYXoY7EePw
AAAECIr9gQdNPbsDrJ8bIuksyY8sQke4su4FVCWqulF5qnwlOWSPu4FSG4RAmMj1dcXl/z
FSSsdVeW9QtlhehjsR4/AAAAHWJpZ2JsdWVidXR0b25AaXAtMTcyLTMxLTQyLTk2
-----END OPENSSH PRIVATE KEY-----
EOF
80  chmod 400 .ssh/scalelite
81  cat .ssh/scalelite
82  cat > ~/.ssh/config << EOF
Host sync.school-manager.education
        User scalelite-spool
        IdentityFile ~/.ssh/scalelite
EOF

83  cat .ssh/config
84  chown bigbluebutton:bigbluebutton .ssh/scalelite
85  ssh sync.school-manager.education
86  exit
87  exit
88  git clone  https://github.com/blindsidenetworks/scalelite.git
89  cd scalelite/bigbluebutton/
90  cp  scalelite_post_publish.rb  /usr/local/bigbluebutton/core/scripts/post_publish
91  cp scalelite.yml  /usr/local/bigbluebutton/core/scripts/

cat > /usr/local/bigbluebutton/core/scripts/scalelite.yml  << EOF
work_dir: /var/bigbluebutton/recording/scalelite
spool_dir: sync.school-manager.education:/var/scalelite-recordings/var/bigbluebutton/spool
extra_rsync_opts: []
EOF

cat /usr/local/bigbluebutton/core/scripts/scalelite.yml

-------------------------------------------
--------------- PLUGIN MP4 ---------------
-------------------------------------------
cd 
git clone https://github.com/createwebinar/bbb-download.git && cd bbb-download && chmod u+x install.sh 
sudo ./install.sh
sudo bbb-record --rebuildall

sed -i 's/# - mp4/- mp4/g' /usr/local/bigbluebutton/core/scripts/presentation.yml

cat > /etc/bigbluebutton/bbb-conf/apply-config.sh  << EOF
#!/bin/bash
# Pull in the helper functions for configuring BigBlueButton
source /etc/bigbluebutton/bbb-conf/apply-lib.sh

enableMultipleKurentos
EOF

chmod +x /etc/bigbluebutton/bbb-conf/apply-config.sh

cat /usr/local/bigbluebutton/core/scripts/presentation.yml
cat /etc/bigbluebutton/bbb-conf/apply-config.sh

------------------------------------------------
--------------- CORRECCION HTTPS ---------------
------------------------------------------------
sed -i 's,bbbWebAPI="http://,bbbWebAPI="https://,g' /usr/share/bbb-apps-akka/conf/application.conf

bbb-conf --setsecret ybmUHtwDPuDXJSyrgr2OpqV00fFYAx2QIUBt05NBo
bbb-conf --restart
bbb-conf --check
=============================================
================= PARTE 7.- =================
=============================================


=============================================
================= PARTE 8.- =================
=============================================
-------------------------------------------
------------ EN EL BALANCEADOR ------------
-------------------------------------------
93  ssh root@198.71.49.179   //Bb@14785236
94  bbb-add  https://bbb5.school-manager.education/bigbluebutton/api ybmUHtwDPuDXJSyrgr2OpqV00fFYAx2QIUBt05NBo 1    
    copiamos id: 94d109d9-874c-44a2-ac16-4109a0bdbf1d
95  bbb-enable 94d109d9-874c-44a2-ac16-4109a0bdbf1d
96  bbb-poll
=============================================
================= PARTE 8.- =================
=============================================

Bb@14785236