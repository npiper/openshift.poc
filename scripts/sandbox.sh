#! /bin/bash
#set -x

        # Sandbox project and user (anything)
        SANDBOX_PROJECT="sandbox"
        SANDBOX_USER="dev"
        SANDBOX_PASS="dev"

        # CI - CD user bamboo
        CI_USER="jenkins"
        CI_PASS="jenkins"

#        {
#            oc login -u system:admin
#        } &> /dev/null

#        NODE_NAME=$(oc get node --no-headers=true | awk '{ print $1; }')
#        NODE_LABELS='env=sandbox owner=integration'

#        echo "Found Node: ${NODE_NAME}"

        echo "Create Non-prod projects"
        {
            oc new-project $SANDBOX_PROJECT \
               --description="Openshift Sandbox project" --display-name="${SANDBOX_PROJECT}"
       } &> /dev/null

       echo "Create Project users"
       {
           oc login -u ${SANDBOX_USER} -p ${SANDBOX_PASS}
       } &> /dev/null

       echo "Create Jenkins user"
       {     
           oc login -u ${CI_USER} -p ${CI_PASS}
       } &> /dev/null

       echo "Switch back to system:admin"
       {
           oc login -u system:admin
       } &> /dev/null

       echo "Add users to projects"
       oc adm policy add-role-to-user admin $SANDBOX_USER -n $SANDBOX_PROJECT
       oc adm policy add-role-to-user admin $CI_USER -n $SANDBOX_PROJECT

       echo "Allow Public docker images to run as root"
       oc adm policy add-scc-to-user anyuid -z default

       echo "Add User's SSH Key to both Projects - for use with Repositories"
       # TODO - check for existence

       oc project $SANDBOX_PROJECT
       oc secrets new-sshauth sshsecret --ssh-privatekey=$HOME/.ssh/id_rsa

       echo "Add DockerHub secret"
       oc secret new-dockercfg docker-hub --docker-server=registry.hub.docker.com --docker-username=npiper --docker-password=npip2410 --docker-email=neil.piper@gmail.com

       echo "Add docker secret to Image pull default account"
       oc secrets add serviceaccount/default secrets/docker-hub --for=pull

       echo "Add docker secret to Builder account"
       oc secrets add serviceaccount/builder secrets/docker-hub

       echo "Linking to build docker"
       oc secrets link builder docker-hub

