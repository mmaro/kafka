#!/bin/bash
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
# 
#    http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if [ $# -lt 1 ];
then
  echo "USAGE: $0 classname [opts]"
  exit 1
fi

base_dir=$(dirname $0)/..


USER_HOME=$(eval echo ~${USER})
ivyPath=$(echo "$USER_HOME/.ivy2/cache")

snappy=$(echo "$ivyPath/org.xerial.snappy/snappy-java/bundles/snappy-java-1.0.4.1.jar")
CLASSPATH=$CLASSPATH:$snappy

library=$(echo "$ivyPath/org.scala-lang/scala-library/jars/scala-library-2.8.0.jar")
CLASSPATH=$CLASSPATH:$library

compiler=~$(echo "$ivyPath/org.scala-lang/scala-compiler/jars/scala-compiler-2.8.0.jar")
CLASSPATH=$CLASSPATH:$compiler

log4j=$(echo "$ivyPath/log4j/log4j/jars/log4j-1.2.15.jar")
CLASSPATH=$CLASSPATH:$log4j

slf=$(echo "$ivyPath/org.slf4j/slf4j-api/jars/slf4j-api-1.6.4.jar")
CLASSPATH=$CLASSPATH:$slf

zookeeper=$(echo "$ivyPath/org.apache.zookeeper/zookeeper/jars/zookeeper-3.3.4.jar")
CLASSPATH=$CLASSPATH:$zookeeper

jopt=$(echo "$ivyPath/net.sf.jopt-simple/jopt-simple/jars/jopt-simple-3.2.jar")
CLASSPATH=$CLASSPATH:$jopt

for file in $base_dir/core/target/scala-2.8.0/*.jar;
do
  CLASSPATH=$CLASSPATH:$file
done

for file in $base_dir/core/lib/*.jar;
do
  CLASSPATH=$CLASSPATH:$file
done

for file in $base_dir/perf/target/scala-2.8.0/kafka*.jar;
do
  CLASSPATH=$CLASSPATH:$file
done

if [ -z "$KAFKA_JMX_OPTS" ]; then
  KAFKA_JMX_OPTS="-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.authenticate=false  -Dcom.sun.management.jmxremote.ssl=false "
fi

if [ -z "$KAFKA_OPTS" ]; then
  KAFKA_OPTS="-Xmx512M -server  -Dlog4j.configuration=file:$base_dir/config/log4j.properties"
fi

if [  $JMX_PORT ]; then
  KAFKA_JMX_OPTS="$KAFKA_JMX_OPTS -Dcom.sun.management.jmxremote.port=$JMX_PORT "
fi

if [ -z "$JAVA_HOME" ]; then
  JAVA="java"
else
  JAVA="$JAVA_HOME/bin/java"
fi

$JAVA $KAFKA_OPTS $KAFKA_JMX_OPTS -cp $CLASSPATH "$@"
