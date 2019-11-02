#!/bin/sh

# This will install moloch to a local centos 7 box
# Demo mode only

echo -e "
   ##################################################
   ##### Install and configure  Moloch for Demo #####
   ##################################################
\n"

echo -e "
   ##############################
   ##### Creating Data Dir  #####
   ##############################
\n"
mkdir /data

echo -e "
   ################################################
   ##### Installing Moloch and Deps using Yum #####
   ################################################
\n"

yum update -y
yum install -y epel-release
yum install -y nc curl wget tree tcpdump whois bash-completion bind-utils vim tcpreplay
if [ `rpm -q moloch` == "moloch-2.0.1-1.x86_64" ] > /dev/null 2>&1; then
   echo "
      ##############################################
      #####     Moloch is already installed    #####
      #####              Exiting               #####
      #####       If you wish remove with:     #####
      ##### `sudo yum remove moloch.x86_64 -y` #####
      ##############################################"
   exit
 else
   yum install -y "https://files.molo.ch/builds/centos-7/moloch-2.0.1-1.x86_64.rpm" > /dev/null 2>&1
fi

echo -e "
   ############################
   ##### Configure Moloch #####
   ############################
\n"
sleep 2

echo "
   ###############################################
   ##### Follow the next set of instructions #####"
sleep 2

echo -e "\n"
echo -e  "             ##### When prompted #####\n\n"
sleep 2
echo -e '   Select "ens37" as your monitoring/capture network interface'
sleep 2
echo -e '   Enter "yes" to install Elasticsearch server locally'
sleep 2
echo -e '   Enter "no-default" for password for encrypt S2S and other'
sleep 3
echo -e '   Enter "y" to install elasticsearch-oss'
sleep 3
echo -e '   Enter "yes" to Download GEO files'
sleep 3
echo -e "   ###############################################\n"

/data/moloch/bin/Configure

echo -e "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"

echo -e "
   ##################################
   ##### Starting Elasticsearch #####
   ##################################
\n"
systemctl enable --now elasticsearch.service > /dev/null 2>&1

echo -e "
   #####################################################
   ##### Waiting for Elasticsearch to be reachable #####
   #####################################################
\n"

while ! nc -vz localhost 9200 > /dev/null 2>&1 ; do sleep 1; done

echo -e "
   #########################################################
   ##### Waiting for Elasticsearch cluster to go green #####
   #########################################################
\n"

STATUS=`/usr/bin/curl -s localhost:9200/_cluster/health?pretty|grep status|awk '{print $3}'|cut -d\" -f2`
while [[ "$STATUS" == "red" ]];
  do
    STATUS=`/usr/bin/curl -s localhost:9200/_cluster/health?pretty|grep status|awk '{print $3}'|cut -d\" -f2`
  done

echo -e "
   ##################################
   ##### Elasticsearch is ready #####
   ##################################
\n"

echo -e "
   ################################
   ##### Initialize Moloch DB #####
   ################################
\n"
/data/moloch/db/db.pl http://localhost:9200 init > /dev/null 2>&1

echo '
   ###########################################################################
   ##### Add "admin" as the Admin User and set password to random string #####
   ###########################################################################'
echo -e "\n"
AdminPassword=$(date | sha1sum | base64 | head -c 13)
/data/moloch/bin/moloch_add_user.sh admin "Admin User" $AdminPassword --admin > /dev/null 2>&1

systemctl daemon-reload

echo -e "
   ##################################
   ##### Starting molochcapture #####
   ##################################
\n"
systemctl enable --now molochcapture.service > /dev/null 2>&1

echo -e "
   #################################
   ##### Starting molochviewer #####
   #################################
\n"
systemctl enable --now molochviewer.service > /dev/null 2>&1

echo -e "
   ##########################################################
      Visit http://localhost:8005 with your favorite browser.
      Username: admin
      Password: $AdminPassword
   ##########################################################
\n"
# Quick check for any hung services
sleep 10
systemctl status elasticsearch moloch* | grep "Active:" -B 2 | GREP_COLOR='1;32' grep --color=always "running\|$"
