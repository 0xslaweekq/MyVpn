#!/bin/bash

# start bash -i ./start.sh
# alias defpass="echo 'YOUR_DOCKER_PASS"
# alias doccon="docker login -u YOUR_DOCKER_USER_NAME --password-stdin"
# defpass | doccon
# docker image prune -af

IMAGES=''nginx-ui-no-auth''

for image in $IMAGES
do
  echo "Start building and push $image"
  docker buildx build -f ./$image/Dockerfile -t slaweekq/$image:latest --push ./$image
  echo "Successfily pulled image: slaweekq/$image:latest
  "
done
