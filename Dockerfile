FROM ubuntu:16.04

LABEL Narges Shadab <nshad001@ucr.edu>

# Install basic software support
RUN apt-get update && \
    apt-get install --yes software-properties-common

# Install Java 8
RUN apt-get update && \
    apt-get install -y openjdk-8-jdk && \
    apt-get install -y ant && \
    apt-get clean;

RUN apt-get update && \
    apt-get install ca-certificates-java && \
    apt-get clean && \
    update-ca-certificates -f;

# Install required softwares (curl & zip & wget)
RUN apt install curl
RUN apt install zip -y
RUN apt install wget -y

# update
RUN apt-get update -y

# Install python
RUN apt-get install -y python

# Install git
RUN apt-get install -y git

## Create a new user 
RUN useradd -ms /bin/bash fse && \
    apt-get install -y sudo && \
    adduser fse sudo && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER fse
WORKDIR /home/fse

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
RUN export JAVA_HOME

ENV JAVA8_HOME /usr/lib/jvm/java-8-openjdk-amd64/
RUN export JAVA8_HOME

# Install Maven
ARG MAVEN_VERSION=3.6.3
ARG USER_HOME_DIR="/root"
ARG SHA=c35a1803a6e70a126e80b2b3ae33eed961f83ed74d18fcd16909b2d44d7dada3203f1ffe726c17ef8dcca2dcaa9fca676987befeadc9b9f759967a8cb77181c0
ARG BASE_URL=https://downloads.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries

RUN mkdir -p /usr/share/maven /usr/share/maven/ref \
  && echo "Downlaoding maven" \
  && curl -fsSL -o /tmp/apache-maven.tar.gz ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
  \
  && echo "Checking download hash" \
  && echo "${SHA}  /tmp/apache-maven.tar.gz" | sha512sum -c - \
  \
  && echo "Unziping maven" \
  && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
  \
  && echo "Cleaning and setting links" \
  && rm -f /tmp/apache-maven.tar.gz \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"

#Install Gradle
ARG GRADLE_VERSION=6.8.3
ARG GRADLE_BASE_URL=https://services.gradle.org/distributions
ARG GRADLE_SHA=7faa7198769f872826c8ef4f1450f839ec27f0b4d5d1e51bade63667cbccd205
RUN mkdir -p /usr/share/gradle /usr/share/gradle/ref \
  && echo "Downlaoding gradle hash" \
  && curl -fsSL -o /tmp/gradle.zip ${GRADLE_BASE_URL}/gradle-${GRADLE_VERSION}-bin.zip \
  \
  && echo "Checking download hash" \
  && echo "${GRADLE_SHA}  /tmp/gradle.zip" | sha256sum -c - \
  \
  && echo "Unziping gradle" \
  && unzip -d /usr/share/gradle /tmp/gradle.zip \
   \
  && echo "Cleaning and setting links" \
  && rm -f /tmp/gradle.zip \
  && ln -s /usr/share/gradle/gradle-${GRADLE_VERSION} /usr/bin/gradle
ENV GRADLE_VERSION 6.8.3
ENV GRADLE_HOME /usr/bin/gradle
ENV GRADLE_USER_HOME /cache
ENV PATH $PATH:$GRADLE_HOME/bin
VOLUME $GRADLE_USER_HOME


# Script to run
# TODO do we still need this?
RUN mkdir -p /var/plumber/
COPY ./start.sh /var/plumber/start.sh
RUN chmod +x /var/plumber/start.sh


ENV OCC_BRANCH master
ENV OCC_REPO https://github.com/kelloggm/object-construction-checker.git

#ENV ZK_BRANCH with-annotations
ENV ZK_REPO https://github.com/kelloggm/zookeeper.git
ENV ZK_CMD "mvn --projects zookeeper-server --also-make clean install -DskipTests"
ENV ZK_CLEAN "mvn clean"

#ENV HADOOP_BRANCH with-annotations
ENV HADOOP_REPO https://github.com/Nargeshdb/hadoop
ENV HADOOP_CMD "mvn --projects hadoop-hdfs-project/hadoop-hdfs --also-make clean compile -DskipTests"
ENV HADOOP_CLEAN "mvn clean"

#ENV HBASE_BRANCH with-annotations
ENV HBASE_REPO https://github.com/Nargeshdb/hbase
ENV HBASE_CMD "mvn --projects hbase-server --also-make clean install -DskipTests"
ENV HBASE_CLEAN "mvn clean"

# download ResourceLeakChecker
RUN git clone "${OCC_REPO}"

RUN cd object-construction-checker \
    git checkout "${OCC_BRANCH}" \
    git pull \
    ./gradlew install \
    cd .. \

RUN cp object-construction-checker/experimental-machinery/ablation/*.sh .
RUN cp object-construction-checker/experimental-machinery/case-studies/*.sh .

# download Zookeeper
RUN git clone "${ZK_REPO}"
RUN cd zookeeper \
    git checkout with-annotations \
    cd .. \

# download Hadoop
RUN git clone "${HADOOP_REPO}"
RUN cd hadoop \
    git checkout with-annotations \
    cd .. \

# download HBase
RUN git clone "${HBASE_REPO}"
RUN cd hbase \
    git checkout with-annotations \
    cd .. \

# analyze all the benchmarks once to populate local Maven repository
RUN ./run-always-call-on-zookeeper.sh
RUN ./run-always-call-on-hadoop.sh
RUN ./run-always-call-on-hbase.sh

# Run cd  /hbase \
#     mvn --projects hbase-server --also-make clean install -DskipTests &> hbase.install.log || echo "Could not build hbase-server" 

# Run cd ..

# RUN [ "./var/plumber/start.sh" ]


CMD ["/bin/bash"]