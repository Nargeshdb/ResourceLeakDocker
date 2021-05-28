#!/bin/bash

# OCC_BRANCH=master
# OCC_REPO=https://github.com/kelloggm/object-construction-checker.git

# ZK_BRANCH=with-annotations
# ZK_REPO=https://github.com/kelloggm/zookeeper.git
# ZK_CMD="mvn --projects zookeeper-server --also-make clean install -DskipTests"
# ZK_CLEAN="mvn clean"

# HADOOP_BRANCH=with-annotations
# HADOOP_REPO=https://github.com/Nargeshdb/hadoop
# HADOOP_CMD="mvn --projects hadoop-hdfs-project/hadoop-hdfs --also-make clean compile -DskipTests"
# HADOOP_CLEAN="mvn clean"

# HBASE_BRANCH=with-annotations
# HBASE_REPO=https://github.com/Nargeshdb/hbase
# HBASE_CMD="mvn --projects hbase-server --also-make clean compile -DskipTests"
# HBASE_CLEAN="mvn clean"

# if [ ! -d object-construction-checker ]; then
#     git clone "${OCC_REPO}"
# fi

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

# # download Zookeeper
# if [ ! -d zookeeper ]; then
#     git clone "${ZK_REPO}"
# fi

# cd zookeeper
# git checkout "${ZK_BRANCH}"
# git pull

# ${ZK_CLEAN} &> /dev/null
# echo "Zookeeper starting:"
# ${ZK_CMD} &> "${RESULTS}/zookeeper.run.log"
# cat "${RESULTS}/zookeeper.run.log"
# cd ..

# # download Hadoop
# if [ ! -d hadoop ]; then
#     git clone "${HADOOP_REPO}"
# fi

# cd hadoop
# git checkout "${HADOOP_BRANCH}"
# git pull

# ${HADOOP_CLEAN} &> /dev/null
# echo "Hadoop starting:"
# ${HADOOP_CMD} &> "${RESULTS}/hadoop.run.log"
# cat "${RESULTS}/hadoop.run.log"
# cd ..


cd hbase
git checkout "${HBASE_BRANCH}"
git pull

mvn --projects hbase-server --also-make clean install -DskipTests &> hbase.install.log || echo "Could not build hbase-server"
${HBASE_CLEAN} &> /dev/null
echo "running the checker on HBase starting:"
${HBASE_CMD} &> "${RESULTS}/hbase.run.log"
cat "${RESULTS}/hbase.run.log" | grep "WARNING" | grep -e "objectconstruction:" -e "mustcall:" | grep -v "The type of object is: org." | grep -v "mustcall:inconsistent.mustcall.subtype" | grep -v "The type of object is: <anonymous org." | grep -v "unneeded.suppression" | grep -v "annotation.not.completed" | grep -v "mustcall:type.invalid.annotations.on.use" | grep -v "hadoop/hadoop-common-project/hadoop-common" | grep -v "/hbase/hbase-common/" | grep -v "The type of object is: com."
cd ..










# if [ ! -d hadoop ]; then
#     git clone "${HADOOP_REPO}"
# fi

# if [ -d "/tmp/hadoop" ]; then
#     :
# else
#     pushd /tmp/
#     git clone https://github.com/Nargeshdb/hadoop.git
#     popd hadoop
#     git checkout with-annotations

# pushd /tmp/hadoop
# mvn --projects hadoop-hdfs-project/hadoop-hdfs --also-make clean compile -DskipTests > /tmp/hadoop-out.txt

    
# if [ -d "/tmp/hbase" ] 
# then
#     pushd /tmp/hbase
# else
#     pushd /tmp/
#     git clone https://github.com/Nargeshdb/hbase.git
#     popd hbase
#     git checkout with-annotations
