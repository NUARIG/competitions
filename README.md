# Competitions

Competitions is an open source tool to run NIH-style peer review of competitions, pilot projects, and research proposals in a cloud-based consortium-wide single sign-on platform.

This repository contains a re-factored version of the [NITRO-Competitions](https://github.com/NUBIC/nitro-competitions) original code base which is currently running at Northwestern University Clinical and Translational Institute (NUCATS). It is work-progress, and intended primarily to enable a cloud-based implementtion in support of the [CTSA National Center for Data to Health (CD2H)](https://ctsa.ncats.nih.gov/cd2h/) operations.


# Installation

Configure the following files with your instance's attributes.

# config/attribute-map.yml

This file is required for mapping the SAML IDP and SP attributes.
https://github.com/apokalipto/devise_saml_authenticatable

# config/competitions_config.yml

The application's configuration has been consolidated into this file. Here you will configure your instance's values for your database, storage, mailers, and saml authentication. Keys, passwords, and secrets will be stored in the credentials.yml.enc

# config/deploy_config.yml

Here you will find instance specific values for Capistrano deployment of the application.
https://github.com/capistrano/rails

# config/credentials.yml

Keys, passwords, and secrets are encrypted here.
https://guides.rubyonrails.org/5_2_release_notes.html#credentials