#!/usr/bin/env bash

if [ -z $GOMAP_LOC ]
then
    GOMAP_LOC="$PWD"
fi
GOMAP_IMG="$GOMAP_LOC/GOMAP.simg"
GOMAP_DATA_LOC="$GOMAP_LOC/GOMAP-data"

if [ ! -f "$GOMAP_IMG" ]
then
    singularity pull --name `basename $GOMAP_IMG` "shub://Dill-PICL/GOMAP-singularity"
    mv  `basename $GOMAP_IMG` `dirname $GOMAP_IMG`
fi

args="$@"
mixmeth=`echo $@ | grep mixmeth | grep -v mixmeth-blast | grep -v mixmeth-preproc`
mixmeth_blast=`echo $@ | grep mixmeth-blast`
setup=`echo $@ | grep setup`

if [[ "$SLURM_CLUSTER_NAME" = "condo2017" ]]
then
    tmpdir="$TMPDIR"
else
    tmpdir="/tmp"
fi

if [ ! -z "$mixmeth" ]
then
    echo "Starting GOMAP instance"
    $GOMAP_LOC/stop-GOMAP.sh && \
    rsync -aq $GOMAP_LOC/GOMAP-data/mysql $tmpdir/ && \
    singularity instance.start   \
        --bind $tmpdir/mysql/lib:/var/lib/mysql  \
        --bind $tmpdir/mysql/log:/var/log/mysql  \
        --bind $GOMAP_DATA_LOC:/opt/GOMAP/data \
        --bind $PWD:/workdir  \
        --bind $tmpdir:/tmpdir  \
        -W $PWD/tmp \
        $GOMAP_IMG GOMAP && \
    singularity run \
        instance://GOMAP $@ && \
    $GOMAP_LOC/stop-GOMAP.sh
elif [ ! -z "$setup" ]
then
    echo "Running GOMAP $@"
    mkdir -p $GOMAP_DATA_LOC
    singularity run   \
        --bind $GOMAP_DATA_LOC:/opt/GOMAP/data \
        --bind $PWD:/workdir  \
        --bind $tmpdir:/tmpdir  \
        -W $PWD/tmp \
        $GOMAP_IMG $@
else
    echo "Running GOMAP $@"
    echo "using $SLURM_JOB_NUM_NODES for the process"
    singularity run   \
        --bind $GOMAP_DATA_LOC/mysql/lib:/var/lib/mysql  \
        --bind $GOMAP_DATA_LOC/mysql/log:/var/log/mysql  \
        --bind $GOMAP_DATA_LOC:/opt/GOMAP/data \
        --bind $PWD:/workdir  \
        --bind $tmpdir:/tmpdir  \
        -W $PWD/tmp \
        $GOMAP_IMG $@
fi
