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
DOCKERCOMPOSE_TESTS_VOLUME_NAME="app-test-results"
DOCKERCOMPOSE_TESTS_CONTAINER_NAME="container-testresults"
DOCKERCOMPOSE_TESTS_TEST_RESULT_PATH="/TestResults"

#Build
export RUN_PROJECT=${RUN_PROJECT:-false}
export RUN_TEST=${RUN_TEST:-false}
export RUN_SONARQUBE=${RUN_SONARQUBE:-true}
export SONARQUBE_URL=${SONARQUBE_URL:-http://172.17.0.1:9000}
export SONARQUBE_LOGIN=${SONARQUBE_LOGIN}


echo ""
echo "-----------------------------------------------------------------------"
echo "Run docker-compose.cd-debug.yml"
docker-compose -f "docker-compose.yml" -f "docker-compose.cd-debug.yml" build
#docker-compose -f "docker-compose.yml" -f "docker-compose.cd-debug.yml" push
if [ $RUN_PROJECT == 'true' ]; then
    docker-compose -f "docker-compose.yml" -f "docker-compose.cd-debug.yml" up
fi
echo "-----------------------------------------------------------------------"


echo "-----------------------------------------------------------------------"
echo "Run docker-compose.cd-tests.yml"
docker-compose -f "docker-compose.yml" -f "docker-compose.cd-tests.yml" build
#docker-compose -f "docker-compose.yml" -f "docker-compose.cd-tests.yml" push
if [ $RUN_TEST == 'true' ]; then
    docker-compose -f "docker-compose.yml" -f "docker-compose.cd-tests.yml" up --abort-on-container-exit
    echo "Extraindo os resultados dos testes"
    docker create --name $DOCKERCOMPOSE_TESTS_CONTAINER_NAME -v $DOCKERCOMPOSE_TESTS_VOLUME_NAME:$DOCKERCOMPOSE_TESTS_TEST_RESULT_PATH busybox
    docker cp $DOCKERCOMPOSE_TESTS_CONTAINER_NAME:$DOCKERCOMPOSE_TESTS_TEST_RESULT_PATH $ARTIFACT_STAGING_DIRECTORY/TestResults
    docker rm $DOCKERCOMPOSE_TESTS_CONTAINER_NAME
fi
echo "-----------------------------------------------------------------------"


echo ""
echo "-----------------------------------------------------------------------"
echo "Run docker-compose.cd-build.yml"
export DOCKERCOMPOSE_PUBLISH_VOLUME_NAME="app-extract-publish"
export DOCKERCOMPOSE_PUBLISH_CONTAINER_NAME="container-publish"
export DOCKERCOMPOSE_PUBLISH_APP_PATH="/var/release/"
docker-compose -f "docker-compose.yml" -f "docker-compose.cd-build.yml" build
#docker-compose -f "docker-compose.yml" -f "docker-compose.cd-build.yml" push
echo "Extraindo o artefatos"
docker create --name $DOCKERCOMPOSE_PUBLISH_CONTAINER_NAME -v $DOCKERCOMPOSE_PUBLISH_VOLUME_NAME:$DOCKERCOMPOSE_PUBLISH_APP_PATH busybox
docker cp $DOCKERCOMPOSE_PUBLISH_CONTAINER_NAME:$DOCKERCOMPOSE_PUBLISH_APP_PATH $ARTIFACT_STAGING_DIRECTORY/artefatos
docker rm $DOCKERCOMPOSE_PUBLISH_CONTAINER_NAME
echo "-----------------------------------------------------------------------"


echo ""
echo "-----------------------------------------------------------------------"
echo "Run docker-compose.cd-runtime.yml"
docker-compose -f "docker-compose.yml" -f "docker-compose.cd-runtime.yml" build
#docker-compose -f "docker-compose.yml" -f "docker-compose.cd-runtime.yml" push
echo "-----------------------------------------------------------------------"


echo ""
echo "-----------------------------------------------------------------------"
echo "Run docker-compose.cd-deploy.yml"
docker-compose -f "docker-compose.yml" -f "docker-compose.cd-deploy.yml" build
#docker-compose -f "docker-compose.yml" -f "docker-compose.cd-deploy.yml" push
echo "-----------------------------------------------------------------------"
