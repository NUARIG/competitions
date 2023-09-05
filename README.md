# Competitions

Competitions is an open source tool to run NIH-style peer review of competitions, pilot projects, and research proposals in a cloud-based consortium-wide single sign-on platform.

This repository contains a re-factored version of the [NITRO-Competitions](https://github.com/NUBIC/nitro-competitions) original code base which is currently running at Northwestern University Clinical and Translational Institute (NUCATS).
With the support of the [CTSA National Center for Data to Health (CD2H)](https://ctsa.ncats.nih.gov/cd2h/), the new application supports a cloud-based implementation and two authentication strategies (SAML authentication and database registerable).


# Prerequisites

The following are required to install competitions:
  * A shibboleth IDP
  * Storage should be configured locally or with AWS
  * Mailcatcher(https://mailcatcher.me) is used in the development environment for emails.
  * Postgres database
  * RVM installed on the server
  * Yarn installed on the server
  * Capistrano for deployment


# Compatibility

  * Ruby:   3.0.2
  * Rails:  6.1.7


# Shibboleth IDP

  The [Devise SAML Authenticatable gem](https://github.com/apokalipto/devise_saml_authenticatable) has been used for authentication. Please see their documentation for more information on configuration.

  You will need an IDP for your staging and production instances which may be coordinated with your university, the NIH, or another IDP.

  We have used a docker container for development. Instructions on setting up a local IDP for development can be found in our [WIKI](https://github.com/NUARIG/competitions/wiki/Installation-and-configuration-of-test-saml-idp). Third party venders like [One Login](https://www.onelogin.com/developer-signup) can also be used for a development IDP.


# Installation

Configure the following files with your instance's attributes and store the files on the server.

```
app/assets/stylesheets/_settings.scss
config/environments/*
config/competitions_config.yml
config/database.yml
config/deploy_config.yml
config/secrets.yml
config/storage.yml
```

### app/stylesheets/\_settings.scss
Competitions uses the [Foundation 6 framework](https://get.foundation/sites/docs/).

A default [\_settings.scss file](https://get.foundation/sites/docs/sass.html#the-settings-file) example is included. Customize for your institution as needed (e.g. `foundation-palette`).

### config/competitions_config.yml
The application's configuration has been consolidated into this file. Here you will configure your instance's values for your mailers, saml authentication, and application variables. Keys, passwords, and secrets will be stored in /config/secrets.yml

Also see further information regarding [devise_saml_authenticatable gem](https://github.com/apokalipto/devise_saml_authenticatable) configurations.

### config/database.yml
You will need to configure your database connection. For more details please see [the rails docs](https://guides.rubyonrails.org/v6.1.7.6/configuring.html#configuring-a-database).
```
development:
  adapter: # postgresql
  host: # localhost
  database: # <DATABASE_NAME>
  username: # <DATABASE_USERNAME>
  password: # <DATABASE_PASSWORD>
```

### config/deploy_config.yml

Here you will find instance specific values for [Capistrano deployment](https://github.com/capistrano/rails) of the application.

Any symlinked configuration files on your instance's deployment server should be included under the `linked_files` in the config/deploy_config.yml.

### config/storage.yml
You will need to configure your instance's storage. The configurations for local or AWS storage are included. It is possible to use other services with further changes.

For more details please see the rails docs (https://guides.rubyonrails.org/v6.0.3.4/active_storage_overview.html#setup).
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

### config/environments/*
The test and development environment files are configured out of the box.

The included staging and production environment files require the following to be configured:
  * storage
  * time_zone

### config/secrets.yml
Keep keys, passwords, secrets, and other sensitive information in this secure file.

You could use config/credentials.yml for this purpose also.
https://guides.rubyonrails.org/security.html#environmental-security
