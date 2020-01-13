##-------------- RELEASE


#----Nuget
export DEPLOY_NUGET=${DEPLOY_NUGET:-false}
export NUGET_PACKAGES_FOLDER=${NUGET_PACKAGES_FOLDER:-/var/release/packages/nuget}
export NUGET_LIFECYCLE_VERSION=${NUGET_LIFECYCLE_VERSION:-} #Direfente para cada ambiente
export NUGET_REGISTRY=${NUGET_REGISTRY:-}
export NUGET_USER=${NUGET_USER:-}
export NUGET_PASS=${NUGET_PASS:-}

#----NPM
export DEPLOY_NPM=${DEPLOY_NPM:-false}
export NPM_PACKAGES_FOLDER=${NPM_PACKAGES_FOLDER:-/var/release/packages/npm}
export NPM_LIFECYCLE_VERSION=${NPM_LIFECYCLE_VERSION:-} #Direfente para cada ambiente
export NPM_REGISTRY=${NPM_REGISTRY:-}
export NPM_USER=${NPM_USER:-}
export NPM_PASS=${NPM_PASS:-}
export NPM_EMAIL=${NPM_EMAIL:-}

#----Kubernetes
export DEPLOY_KUBERNETES=${DEPLOY_KUBERNETES:-true}
export DESTROY_KUBERNETES_ENVIRONMENT=${DESTROY_KUBERNETES_ENVIRONMENT:-false}
export KUBERNETES_FOLDER=${KUBERNETES_FOLDER:-/var/release/source/}
export KUBECONFIG_PATH=${KUBECONFIG_PATH:-/var/release/source/kubeconfig}


 #----Kompose
LOCAL_VERSION=$(date '+%Y%m%d')-1
export VERSION=${VERSION:-${LOCAL_VERSION}}
export DOCKER_REGISTRY=${DOCKER_REGISTRY:-}
export BRANCH=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
export COMPOSE_PATH="" #Direfente para cada ambiente


echo "---------Publico em alpha"
export NUGET_LIFECYCLE_VERSION="alpha"
export NPM_LIFECYCLE_VERSION="alpha"
export MAVEN_LIFECYCLE_VERSION="alpha"
export COMPOSE_PATH="docker-compose.env-alpha.yml"
docker-compose -f "docker-compose.cd-deploy.yml" up --abort-on-container-exit --no-build
docker-compose -f "docker-compose.cd-deploy.yml" down
echo "-------------------------------------"


# echo "---------Publico em beta"
# export NUGET_LIFECYCLE_VERSION="beta"
# export NPM_LIFECYCLE_VERSION="beta"
# export MAVEN_LIFECYCLE_VERSION="beta"
# #export KUBECONFIG_PATH=""
# export COMPOSE_PATH="docker-compose.env-beta.yml"
# docker-compose -f "docker-compose.cd-deploy.yml" up --abort-on-container-exit --no-build
# docker-compose -f "docker-compose.cd-deploy.yml" down
# echo "-------------------------------------"


# echo "---------Publico em rc"
# export NUGET_LIFECYCLE_VERSION="rc"
# export NPM_LIFECYCLE_VERSION="rc"
# export MAVEN_LIFECYCLE_VERSION="RC"
# #export KUBECONFIG_PATH=""
# export COMPOSE_PATH="docker-compose.env-rc.yml"
# docker-compose -f "docker-compose.cd-deploy.yml" up --abort-on-container-exit --no-build
# docker-compose -f "docker-compose.cd-deploy.yml" down
# echo "-------------------------------------"


# echo "---------Publico em prod (stable)"
# export NUGET_LIFECYCLE_VERSION=""
# export NPM_LIFECYCLE_VERSION=""
# export MAVEN_LIFECYCLE_VERSION=""
# #export KUBECONFIG_PATH=""
# export COMPOSE_PATH="docker-compose.env-stable.yml"
# docker-compose -f "docker-compose.cd-deploy.yml" up --abort-on-container-exit --no-build
# docker-compose -f "docker-compose.cd-deploy.yml" down
# echo "-------------------------------------"
