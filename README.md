# Competitions

Competitions is an open source tool to run NIH-style peer review of competitions, pilot projects, and research proposals in a cloud-based consortium-wide single sign-on platform.

This repository contains a re-factored version of the [NITRO-Competitions](https://github.com/NUBIC/nitro-competitions) original code base which is currently running at Northwestern University Clinical and Translational Institute (NUCATS). It is work-progress, and intended primarily to enable a cloud-based implementtion in support of the [CTSA National Center for Data to Health (CD2H)](https://ctsa.ncats.nih.gov/cd2h/) operations.

# Prerequesites

Installing Competitions requires certain configurations.
  * A shibboleth IDP for these configuration
  * Storage should be configured locally or with AWS.
    - It is possible to user other services, but more changes will be necessary.
  * Mailcatcher(https://mailcatcher.me) is used in the development environment for emails.
  * Postgres database
  * RVM installed on server
  * Capistrano for deployment

# Installation

Configure the following files with your instance's attributes and store the files on the server.

# config/attribute-map.yml

This file is required for mapping the SAML IDP and SP attributes.
https://github.com/apokalipto/devise_saml_authenticatable

# config/competitions_config.yml

The application's configuration has been consolidated into this file. Here you will configure your instance's values for your database, storage, mailers, and saml authentication. Keys, passwords, and secrets will be stored in the credentials.yml.enc

# config/database.yml
You will need to configure your database connection. For more details please see the rails docs (https://guides.rubyonrails.org/v5.2/configuring.html#configuring-a-database).
```
development:
  adapter: # postgresql
  host: # localhost
  database: # <DATABASE_NAME>
  username: # <DATABASE_USERNAME>
  password: # <DATABASE_PASSWORD>
```

# config/deploy_config.yml

Here you will find instance specific values for Capistrano deployment of the application (https://github.com/capistrano/rails).

Include all of your instance's configuration files under linked_files in config/deploy_config.yml, if you are symlinking these on your deployment server.

# config/storage.yml
You will need to configure your instance's storage. For more details please see the rails docs (https://guides.rubyonrails.org/v5.2.0/active_storage_overview.html#setup).
```
local:
  service: Disk
  root: <%= Rails.root.join("storage") %>

test:
  service: Disk
  root: <%= Rails.root.join("tmp/storage") %>

amazon:
  service: S3
  access_key_id: <AWS_ACCESS_KEY_ID>
  secret_access_key: <AWS_SECRET_ACCESS_KEY>
  region: <REGION_FOR_AWS_BUCKET>
  bucket: <NAME_OF_YOUR_BUCKET>
```

# config/environments

Included are a test and development environment configured out of the box. There are also example environment files for staging and production included. These will need the following configured before they will work.
  * storage
  * time_zone

# config/credentials.yml

Keys, passwords, and secrets are encrypted in this file.
https://guides.rubyonrails.org/5_2_release_notes.html#credentials