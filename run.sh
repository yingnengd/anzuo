#!/bin/bash
container=novnc_ssh
image=novnc:dev2
extra_run_args=""  
quiet=""  
workspace=/home/yk/workspace  
vnc_port=6085  
ssh_port=2225  
# https_port=18888

docker run -itd \
--name $container \
-v $workspace:/home/user/workspace/ \
-p $vnc_port:8080 \
-p $ssh_port:22 \
-p $https_port:8888 \
$extra_run_args \
$image  >/dev/null