# 
# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# !/bin/bash

FILE=./client/client-settings.properties
CLIENT_STORE_PASS_FILE=./clientstore.pass
GUACAMOLE_HOME=/etc/guacamole
GUACD_HOSTNAME=guacamole-server-service

# Client Cert Keystore password is written out by the create-keystore.sh script
CLIENT_STORE_PASS=`tail -n 1 $CLIENT_STORE_PASS_FILE`
GUACD_PORT=4822
LOGBACK_LEVEL=info

if [ -z ${3} ]; then
    echo "Usage: bin/create-client-settings.sh [CLOUD_SQL_PRIVATE_IP] [CLOUD_SQL_PORT] [CLOUD_SQL_DBNAME]"
    exit 1
elif [ -z $CLIENT_STORE_PASS ]; then
    echo "Could not read client keystore password from clientstore.pass"
    echo "Enter Client Keystore Password:"
    read CLIENT_STORE_PASS
else
    echo "# Auto generated by create-client-settings.sh" > ${FILE}
    echo "GUACAMOLE_HOME=${GUACAMOLE_HOME}" >> ${FILE}
    echo "GUACD_HOSTNAME=${GUACD_HOSTNAME}" >> ${FILE}
    echo "GUACD_PORT=${GUACD_PORT}" >> ${FILE}
    echo "MYSQL_HOSTNAME=${1}" >> ${FILE}
    echo "MYSQL_PORT=${2}" >> ${FILE}
    echo "MYSQL_SSL_MODE=verify-ca" >> ${FILE}
    # Bug https://issues.apache.org/jira/browse/GUACAMOLE-1135
    # echo "MYSQL_SSL_TRUST_STORE=file:/etc/config/truststore.jks" >> ${FILE}
    # echo "MYSQL_SSL_CLIENT_STORE=file:/etc/config/clientstore.jks" >> ${FILE}

    # Bug https://issues.apache.org/jira/browse/GUACAMOLE-1136
    echo "MYSQL_SSL_TRUST_PASSWORD=$CLIENT_STORE_PASS" >> ${FILE}
    echo "MYSQL_SSL_CLIENT_PASSWORD=$CLIENT_STORE_PASS" >> ${FILE}
    echo "MYSQL_DATABASE=${3}?trustCertificateKeyStoreUrl=file:/etc/config/truststore.jks&clientCertificateKeyStoreUrl=file:/etc/config/clientstore.jks" >> ${FILE}
    echo "LOGBACK_LEVEL=${LOGBACK_LEVEL}" >> ${FILE}

    rm $CLIENT_STORE_PASS_FILE
fi