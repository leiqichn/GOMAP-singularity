#!/usr/bin/env bash
instance_name="GOMAP"
img_loc="$instance_name.simg"
mkdir -p $PWD/tmp

./stop-GOMAP.sh

singularity instance.start \
	--bind $PWD/GOMAP-data/mysql/lib:/var/lib/mysql \
	--bind $PWD/GOMAP-data/mysql/log:/var/log/mysql \
	--bind $PWD/GOMAP-container:/opt/GOMAP \
	--bind $PWD/GOMAP-data:/opt/GOMAP/data \
    --bind $PWD:/workdir \
	-W $PWD/tmp \
	$img_loc $instance_name && \
singularity run  \
	instance://$instance_name --step=preprocess --config=test/config.yml #&&
#singularity run  \
# 	instance://$instance_name --step=aggregate --config=test/config.yml

./stop-GOMAP.sh
