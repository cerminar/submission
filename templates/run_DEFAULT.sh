#!/bin/bash
uname -a

env

CLUSTERID=$1
PROCID=$2

source ./params.sh


BATCH_DIR=${PWD}


echo "CLUSTER:" ${CLUSTERID}
echo "PROC-ID" ${PROCID}
echo 'TASKCONFDIR' ${ABSTASKCONFDIR}
echo 'OUT-DIR' ${OUTDIR}
echo 'OUTPUT-FILE' ${OUTFILE}

#dump job info
echo 'PROCID='${PROCID} >> job_info.sh
echo 'CLUSTERID='${CLUSTERID} >> job_info.sh

source /cvmfs/cms.cern.ch/cmsset_default.sh
export SCRAM_ARCH=${SCRAMARCH}
scram proj CMSSW ${CMSSWVERSION}
cd ${CMSSWVERSION}
cp ../sandbox.tgz .
# cp ${ABSTASKBASEDIR}/sandbox.tgz .
tar xvf sandbox.tgz
eval `scram runtime -sh`
echo "SCRAM arch: ${SCRAM_ARCH} CMSSW version: ${CMSSWVERSION}"
#cd ${ABSTASKCONFDIR}
# cp ${ABSTASKCONFDIR}/input_cfg.pkl ${BATCH_DIR}/
cp ${ABSTASKCONFDIR}/input_cfg.py ${BATCH_DIR}/
cp ${ABSTASKCONFDIR}/job_config_${PROCID}.py ${BATCH_DIR}/
# python process_pickler.py job_config_${PROCID}.py ${BATCH_DIR}/job_config.py
cd ${BATCH_DIR}
ls -lrt
echo 'now we run it...fasten your seatbelt: '
cmsRun job_config_${PROCID}.py 2>&1 | tee cmsRun_${PROCID}.${CLUSTERID}.log > /dev/null
EXIT_CODE=${PIPESTATUS[0]}
gzip cmsRun_${PROCID}.${CLUSTERID}.log && cp -v cmsRun_${PROCID}.${CLUSTERID}.log.gz ${ABSTASKLOGDIR} || { echo 'cmsRun log handling failed!'; exit 12; }
if [ $EXIT_CODE -ne 0 ]; then
    echo "cmsRun failed with exit code $EXIT_CODE"
    exit 11
fi
echo '...done'
