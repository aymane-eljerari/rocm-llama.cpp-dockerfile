#!/bin/bash

CONTAINER_NAME="rocm-llm-prof-c"
IMAGE_NAME="rocm-llm-prof-i"

docker run --privileged --gpus all -itd --rm --group-add=video \
    --security-opt="seccomp=unconfined" --device /dev/kfd --device /dev/dri \
    --name $CONTAINER_NAME \
    -v /home/eljeraria/llm-prof-utils:/app/llm-prof-utils \
    -v /home/eljeraria/llm-models/:/app/llama.cpp/models/mounted-models/ \
    $IMAGE_NAME && \

docker exec -it $CONTAINER_NAME zsh


