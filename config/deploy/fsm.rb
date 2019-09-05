set :stage, :fsm

server DEPLOY_CONFIG[fetch(:stage).to_s]['server_name'],
        user: DEPLOY_CONFIG['deployer'],
        roles: DEPLOY_CONFIG['deployer_roles'],
        primary: true

set :deploy_to, DEPLOY_CONFIG['deploy_to']
