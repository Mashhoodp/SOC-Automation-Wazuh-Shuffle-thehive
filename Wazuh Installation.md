Here's an organized set of instructions to install Wazuh in Markdown format:

# Wazuh Installation Guide

## Option 1: Using Docker

1. Clone the Wazuh repository:
   ```bash
   git clone https://github.com/wazuh/wazuh-docker.git
   ```
   For a specific version, use:`-b v4.8.1 `

2. Navigate to the single-node directory:
   ```bash
   cd single-node
   ```

3. Generate indexer certificates:
   ```bash
   docker-compose -f generate-indexer-certs.yml run --rm generator
   ```

4. Modify the necessary ports in the docker-compose file to avoid conflicts with the host:
   ```yaml
   ports:
     - "1514" # instead of "1514:1514"
     - "9200" # instead of "9200:9200"
   ```

5. Start the Wazuh single-node deployment using docker-compose:
  ```bash
  docker-compose up -d
  ```

## Option 2: Using Debian

### 1. Wazuh Indexer Installation

#### 1.1 Install Certificates

1. Download the certificate tool and configuration file:
   ```bash
   curl -sO https://packages.wazuh.com/4.8/wazuh-certs-tool.sh
   curl -sO https://packages.wazuh.com/4.8/config.yml
   ```

2. Edit `config.yml` and replace node names and IP values.

3. Generate certificates:
   ```bash
   bash ./wazuh-certs-tool.sh -A
   ```

4. Compress certificate files:
   ```bash
   tar -cvf ./wazuh-certificates.tar -C ./wazuh-certificates/ .
   rm -rf ./wazuh-certificates
   ```

#### 1.2 Install Wazuh Indexer

1. Install dependencies:
   ```bash
   sudo apt-get install debconf adduser procps gnupg apt-transport-https
   ```

2. Add Wazuh repository:
   ```bash
   curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import && chmod 644 /usr/share/keyrings/wazuh.gpg
   echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | tee -a /etc/apt/sources.list.d/wazuh.list
   apt-get update
   ```

3. Install Wazuh indexer:
   ```bash
   sudo apt-get -y install wazuh-indexer
   ```

4. Configure Wazuh indexer:
   - Edit `/etc/wazuh-indexer/opensearch.yml`
   - Set up certificates:
     ```bash
     NODE_NAME=wazuh.defendnet.loc
     mkdir /etc/wazuh-indexer/certs
     tar -xf ./wazuh-certificates.tar -C /etc/wazuh-indexer/certs/ ./$NODE_NAME.pem ./$NODE_NAME-key.pem ./admin.pem ./admin-key.pem ./root-ca.pem
     mv -n /etc/wazuh-indexer/certs/$NODE_NAME.pem /etc/wazuh-indexer/certs/indexer.pem
     mv -n /etc/wazuh-indexer/certs/$NODE_NAME-key.pem /etc/wazuh-indexer/certs/indexer-key.pem
     chmod 500 /etc/wazuh-indexer/certs
     chmod 400 /etc/wazuh-indexer/certs/*
     chown -R wazuh-indexer:wazuh-indexer /etc/wazuh-indexer/certs
     ```

5. Start Wazuh indexer service:
   ```bash
   systemctl daemon-reload
   systemctl enable wazuh-indexer
   systemctl start wazuh-indexer
   ```

### 2. Wazuh Manager Installation

1. Install Wazuh manager and Filebeat:
   ```bash
   sudo apt-get -y install wazuh-manager filebeat
   ```

2. Configure Filebeat:
   ```bash
   curl -so /etc/filebeat/filebeat.yml https://packages.wazuh.com/4.8/tpl/wazuh/filebeat/filebeat.yml
   nano /etc/filebeat/filebeat.yml
   # Change hosts: ["127.0.0.1:9200"] to ["192.168.44.110:9200"]
   ```

3. Set up Filebeat keystore:
   ```bash
   filebeat keystore create
   echo admin | filebeat keystore add username --stdin --force
   echo admin | filebeat keystore add password --stdin --force
   ```

4. Install Wazuh template:
   ```bash
   curl -so /etc/filebeat/wazuh-template.json https://raw.githubusercontent.com/wazuh/wazuh/v4.8.1/extensions/elasticsearch/7.x/wazuh-template.json
   chmod go+r /etc/filebeat/wazuh-template.json
   ```

5. Install Wazuh module:
   ```bash
   curl -s https://packages.wazuh.com/4.x/filebeat/wazuh-filebeat-0.4.tar.gz | tar -xvz -C /usr/share/filebeat/module
   ```

6. Set up certificates:
   ```bash
   NODE_NAME=wazuh.defendnet.loc
   mkdir /etc/filebeat/certs
   tar -xf ./wazuh-certificates.tar -C /etc/filebeat/certs/ ./$NODE_NAME.pem ./$NODE_NAME-key.pem ./root-ca.pem
   mv -n /etc/filebeat/certs/$NODE_NAME.pem /etc/filebeat/certs/filebeat.pem
   mv -n /etc/filebeat/certs/$NODE_NAME-key.pem /etc/filebeat/certs/filebeat-key.pem
   chmod 500 /etc/filebeat/certs
   chmod 400 /etc/filebeat/certs/*
   chown -R root:root /etc/filebeat/certs
   ```

7. Start Wazuh manager service:
   ```bash
   systemctl daemon-reload
   systemctl enable wazuh-manager
   systemctl start wazuh-manager
   ```

### 3. Wazuh Dashboard Installation

1. Install Wazuh dashboard:
   ```bash
   sudo apt-get install debhelper tar curl libcap2-bin
   sudo apt-get -y install wazuh-dashboard
   ```

2. Configure dashboard:
   - Edit `/etc/wazuh-dashboard/opensearch_dashboards.yml`
   - Change `opensearch.hosts: https://localhost:9200` to `opensearch.hosts: https://192.168.44.110:9200`

3. Set up certificates:
   ```bash
   NODE_NAME=wazuh.defendnet.loc
   mkdir /etc/wazuh-dashboard/certs
   tar -xf ./wazuh-certificates.tar -C /etc/wazuh-dashboard/certs/ ./$NODE_NAME.pem ./$NODE_NAME-key.pem ./root-ca.pem
   mv -n /etc/wazuh-dashboard/certs/$NODE_NAME.pem /etc/wazuh-dashboard/certs/dashboard.pem
   mv -n /etc/wazuh-dashboard/certs/$NODE_NAME-key.pem /etc/wazuh-dashboard/certs/dashboard-key.pem
   chmod 500 /etc/wazuh-dashboard/certs
   chmod 400 /etc/wazuh-dashboard/certs/*
   chown -R wazuh-dashboard:wazuh-dashboard /etc/wazuh-dashboard/certs
   ```

4. Start Wazuh dashboard service:
   ```bash
   systemctl daemon-reload
   systemctl enable wazuh-dashboard
   systemctl start wazuh-dashboard
   ```

5. Configure Wazuh server URL:
   - Edit `/usr/share/wazuh-dashboard/data/wazuh/config/wazuh.yml`
   - Change `url: https://<WAZUH_SERVER_IP_ADDRESS>` to `url: https://192.168.44.110`
