clear
rm -rf ./docker-extract/
mkdir ./docker-extract/

#Essas variaveis precisam estar na release também
LOCAL_VERSION=$(date '+%Y%m%d')-1
export VERSION=${VERSION:-${LOCAL_VERSION}}
export DOCKER_REGISTRY=${DOCKER_REGISTRY:-}
export BRANCH=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')


echo "-----------------------------------------------------------------------"
echo "Iniciando cd-build.sh."
echo "ImageName: ${DOCKER_REGISTRY}/app:${BRANCH}.${VERSION}"
echo "-----------------------------------------------------------------------"


#Para remover todas as images intermediarias, volume, e outras dependencias, rodar os comandos abaixo
#echo ""
#echo "-----------------------------------------------------------------------"
# docker-compose -f "docker-compose.yml" -f "docker-compose.cd-tests.yml" down -v --rmi all --remove-orphans
# docker-compose -f "docker-compose.yml" -f "docker-compose.cd-build.yml" down -v --rmi all --remove-orphans
# docker-compose -f "docker-compose.yml" -f "docker-compose.cd-runtime.yml" down -v --rmi all --remove-orphans
#echo "-----------------------------------------------------------------------"


#Variaveis locais, utilizado para copiar os arquivos do container
ARTIFACT_STAGING_DIRECTORY="./docker-extract"

#Build
export RUN_PROJECT=${RUN_PROJECT:-false}
export RUN_TEST=${RUN_TEST:-false}
export RUN_SONARQUBE=${RUN_SONARQUBE:-true}
export SONARQUBE_URL=${SONARQUBE_URL:-http://172.17.0.1:9000}
export SONARQUBE_LOGIN=${SONARQUBE_LOGIN}

export DOCKER_PUSH_IMAGES=${DOCKER_PUSH_IMAGES:-false}

echo ""
echo "-----------------------------------------------------------------------"
echo "Run docker-compose.cd-debug.yml"
docker-compose -f "docker-compose.yml" -f "docker-compose.cd-debug.yml" build
if [ $RUN_PROJECT == 'true' ]; then
    docker-compose -f "docker-compose.yml" -f "docker-compose.cd-debug.yml" up
    exit 1
fi
if [ $DOCKER_PUSH_IMAGES == 'true' ]; then
    docker-compose -f "docker-compose.yml" -f "docker-compose.cd-debug.yml" push
fi
echo "-----------------------------------------------------------------------"


echo "-----------------------------------------------------------------------"
echo "Run docker-compose.cd-tests.yml"
docker-compose -f "docker-compose.yml" -f "docker-compose.cd-tests.yml" build
if [ $RUN_TEST == 'true' ]; then
    docker-compose -f "docker-compose.yml" -f "docker-compose.cd-tests.yml" up --abort-on-container-exit
    echo "Extraindo os artefatos de teste"
    docker cp tests:/TestResults ${ARTIFACT_STAGING_DIRECTORY}/TestResults
fi
if [ $DOCKER_PUSH_IMAGES == 'true' ]; then
    docker-compose -f "docker-compose.yml" -f "docker-compose.cd-tests.yml" push
fi
echo "-----------------------------------------------------------------------"


echo ""
echo "-----------------------------------------------------------------------"
echo "Run docker-compose.cd-build.yml"
docker-compose -f "docker-compose.yml" -f "docker-compose.cd-build.yml" up --build --force-recreate --no-start
echo "Extraindo os artefatos de build"
docker cp build:/app ${ARTIFACT_STAGING_DIRECTORY}/BuildArtifacts
echo "-----------------------------------------------------------------------"


echo ""
echo "-----------------------------------------------------------------------"
echo "Run docker-compose.cd-runtime.yml"
docker-compose -f "docker-compose.yml" -f "docker-compose.cd-runtime.yml" build
if [ $DOCKER_PUSH_IMAGES == 'true' ]; then
    docker-compose -f "docker-compose.yml" -f "docker-compose.cd-runtime.yml" push
fi
echo "-----------------------------------------------------------------------"


echo ""
echo "-----------------------------------------------------------------------"
echo "Run docker-compose.cd-deploy.yml"
docker-compose -f "docker-compose.yml" -f "docker-compose.cd-deploy.yml" build
if [ $DOCKER_PUSH_IMAGES == 'true' ]; then
    docker-compose -f "docker-compose.yml" -f "docker-compose.cd-deploy.yml" push
fi
echo "-----------------------------------------------------------------------"
