  #cloud-config
write_files:
  - path: /var/tmp/install_docker.sh 
    permissions: '0750'
    content: |
      #!/usr/bin/env bash
      curl -fsSL https://get.docker.com -o get-docker.sh
      sudo sh get-docker.sh --version 24.0

  - path: /var/tmp/certificates.sh 
    permissions: '0750'
    content: |
      #!/usr/bin/env bash
      
      # Create folders for FDO installation and TLS certificates

      mkdir -p /fdo/certs

      echo ${full_chain} | base64 --decode > /fdo/certs/cert.pem
      echo ${full_chain} | base64 --decode > /fdo/certs/bundle.pem
      echo ${private_key_pem} | base64 --decode > /fdo/certs/key.pem

  - path: /fdo/compose.yaml
    permissions: '0640'
    content: |
      name: terraform-enterprise
      services:
        tfe:
          image: images.releases.hashicorp.com/hashicorp/terraform-enterprise:${tfe_release}
          environment:
            TFE_LICENSE: ${tfe_license}
            TFE_HOSTNAME: ${route53_subdomain}.${route53_zone}
            TFE_OPERATIONAL_MODE: "external"    
            TFE_ENCRYPTION_PASSWORD: "${tfe_password}"
            TFE_DISK_CACHE_VOLUME_NAME: $${COMPOSE_PROJECT_NAME}_terraform-enterprise-cache
            TFE_TLS_CERT_FILE: /etc/ssl/private/terraform-enterprise/cert.pem
            TFE_TLS_KEY_FILE: /etc/ssl/private/terraform-enterprise/key.pem
            TFE_TLS_CA_BUNDLE_FILE: /etc/ssl/private/terraform-enterprise/bundle.pem
            TFE_IACT_SUBNETS: "0.0.0.0/0"
            
            # Database settings            
            TFE_DATABASE_USER: "${postgresql_user}"
            TFE_DATABASE_PASSWORD: "${postgresql_password}"
            TFE_DATABASE_HOST: "${postgres_fqdn}"
            TFE_DATABASE_NAME: "postgres"
            TFE_DATABASE_PARAMETERS: "sslmode=require"
            
            # Object storage settings.
            TFE_OBJECT_STORAGE_TYPE: "azure"
            TFE_OBJECT_STORAGE_AZURE_ACCOUNT_NAME: "${storage_account}"
            TFE_OBJECT_STORAGE_AZURE_CONTAINER: "${container_name}"
            TFE_OBJECT_STORAGE_AZURE_ACCOUNT_KEY: "${storage_account_key}"
          cap_add:
            - IPC_LOCK
          read_only: true
          tmpfs:
            - /tmp
            - /var/run
            - /var/log/terraform-enterprise
          ports:
            - "80:80"
            - "443:443"
          volumes:
            - type: bind
              source: /var/run/docker.sock
              target: /var/run/docker.sock
            - type: bind
              source: ./certs
              target: /etc/ssl/private/terraform-enterprise
            - type: volume
              source: terraform-enterprise-cache
              target: /var/cache/tfe-task-worker/terraform
      
      volumes:
        terraform-enterprise-cache:
  
  - path: /var/tmp/install_tfe.sh   
    permissions: '0750'
    content: |
      #!/usr/bin/env bash    
      
      # Switch to install path
      pushd /fdo
      
      # Authenticate to container image registry
      echo "${tfe_license}" | docker login --username terraform images.releases.hashicorp.com --password-stdin
      
      # Pull the image and spin up the TFE FDO container
      docker compose up --detach   

runcmd:
  - sudo bash /var/tmp/install_docker.sh 
  - sudo bash /var/tmp/certificates.sh
  - sudo bash /var/tmp/install_tfe.sh 
