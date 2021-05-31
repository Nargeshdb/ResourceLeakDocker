#!/bin/bash

cd object-construction-checker
git checkout "${OCC_BRANCH}"
git pull
./gradlew install
cd ..

CURDIR=$(pwd)
RESULTS="${CURDIR}/results"

if [ -d "${RESULTS}" ]; then
    rm -rf "${RESULTS}"
fi

mkdir "${RESULTS}"

cd zookeeper
git checkout "${ZK_BRANCH}"
git pull

${ZK_CLEAN} &> /dev/null
echo "Zookeeper starting:"
${ZK_CMD} &> "${RESULTS}/zookeeper.run.log"
echo "completed"
cat "${RESULTS}/zookeeper.run.log" | grep "WARNING" | grep -e "objectconstruction:" -e "mustcall:" | grep -v "The type of object is: org." | grep -v "mustcall:inconsistent.mustcall.subtype" | grep -v "The type of object is: <anonymous org." | grep -v "unneeded.suppression" | grep -v "annotation.not.completed" | grep -v "mustcall:type.invalid.annotations.on.use" | grep -v "hadoop/hadoop-common-project/hadoop-common" | grep -v "/hbase/hbase-common/" | grep -v "The type of object is: com." > "${RESULTS}/out.zookeeper.log"
cd ..

cd hbase
git checkout "${HBASE_BRANCH}"
git pull

${HBASE_CLEAN} &> /dev/null
echo "Hbase starting:"
${HBASE_CMD} &> "${RESULTS}/hbase.run.log"
echo "completed"
cat "${RESULTS}/hbase.run.log" | grep "WARNING" | grep -e "objectconstruction:" -e "mustcall:" | grep -v "The type of object is: org." | grep -v "mustcall:inconsistent.mustcall.subtype" | grep -v "The type of object is: <anonymous org." | grep -v "unneeded.suppression" | grep -v "annotation.not.completed" | grep -v "mustcall:type.invalid.annotations.on.use" | grep -v "hadoop/hadoop-common-project/hadoop-common" | grep -v "/hbase/hbase-common/" | grep -v "The type of object is: com." > "${RESULTS}/out.hbase.log"
cd ..

cd hadoop
git checkout "${HADOOP_BRANCH}"
git pull

${HADOOP_CLEAN} &> /dev/null
echo "Hadoop starting:"
${HADOOP_CMD} &> "${RESULTS}/hadoop.run.log"
echo "completed"
cat "${RESULTS}/hadoop.run.log" | grep "WARNING" | grep -e "objectconstruction:" -e "mustcall:" | grep -v "The type of object is: org." | grep -v "mustcall:inconsistent.mustcall.subtype" | grep -v "The type of object is: <anonymous org." | grep -v "unneeded.suppression" | grep -v "annotation.not.completed" | grep -v "mustcall:type.invalid.annotations.on.use" | grep -v "hadoop/hadoop-common-project/hadoop-common" | grep -v "/hbase/hbase-common/" | grep -v "The type of object is: com." > "${RESULTS}/out.hadoop.log"
cd ..
