#!/bin/bash

echo '123456' | sudo -S apt-get update -y
echo '123456' | sudo -S apt-get install software-properties-common -y
sudo add-apt-repository ppa:webupd8team/java -y
sudo apt-get update -y
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
sudo -E apt-get purge oracle-java8-installer -y
sudo -E apt-get install oracle-java8-installer -y 
java -version

echo '123456' | sudo -S addgroup hadoop
printf 'a\na\n' | sudo -S adduser --ingroup hadoop hduser
echo '123456' | sudo -S adduser hduser sudo

echo 'a' | sudo -S -u hduser bash << EOF
echo 'a' | sudo -S apt-get update
sudo apt-get install -y openssh-server
sudo ufw allow 22
ssh-keygen -t rsa -P ""

touch /home/hduser/.ssh/authorized_keys
cat /home/hduser/.ssh/id_rsa.pub >> /home/hduser/.ssh/authorized_keys
touch /home/hduser/.ssh/known_hosts
ssh-keyscan -H localhost >> /home/hduser/.ssh/known_hosts
ssh-keyscan -H 127.0.0.1 >> /home/hduser/.ssh/known_hosts
ssh-keyscan -H 0.0.0.0 >> /home/hduser/.ssh/known_hosts
EOF

cd /home/ubuntu
sudo wget http://apache.claz.org/hadoop/common/hadoop-2.7.3/hadoop-2.7.3.tar.gz
sudo tar xzf hadoop-2.7.3.tar.gz

cd /usr/local
sudo mkdir hadoop
sudo mv /home/ubuntu/hadoop-2.7.3/* hadoop/

sudo chown -R hduser:hadoop /usr/local/hadoop

sudo -u hduser bash << EOF
sudo cat >> /home/hduser/.bashrc << EOL
export HADOOP_HOME=/usr/local/hadoop
export HADOOP_MAPRED_HOME=/usr/local/hadoop
export HADOOP_COMMON_HOME=/usr/local/hadoop
export HADOOP_HDFS_HOME=/usr/local/hadoop
export YARN_HOME=/usr/local/hadoop
export HADOOP_COMMON_LIB_NATIVE_DIR=/usr/local/hadoop/lib/native
export JAVA_HOME=/usr/lib/jvm/java-8-oracle
EOL
source /home/hduser/.bashrc
sudo cat >> /home/hduser/.bashrc << EOL
export PATH=$PATH:/usr/local/hadoop/sbin:/usr/local/hadoop/bin:$JAVA_HOME/bin
EOL
EOF

sudo -u hduser bash << EOF
source /home/hduser/.bashrc
sudo cat >> /usr/local/hadoop/etc/hadoop/hadoop-env.sh << EOL
export JAVA_HOME=/usr/lib/jvm/java-8-oracle
EOL
source /home/hduser/.bashrc
EOF

cd /usr/local/hadoop/etc/hadoop
echo 'into hadoop config folder'
pwd

sudo -u hduser bash << EOF
sed -i '/<configuration>/,/<\/configuration>/d' core-site.xml

sudo cat >> core-site.xml << EOL
<configuration>
<property>
<name>fs.default.name</name>
<value>hdfs://localhost/</value>
</property>
<property>
  <name>hadoop.tmp.dir</name>
  <value>/app/hadoop/tmp</value>
</property>
</configuration>
EOL
EOF

echo 'successfully updated core-site.xml'
pwd

sudo -u hduser bash << EOF
sudo cp mapred-site.xml.template mapred-site.xml
sed -i '/<configuration>/,/<\/configuration>/d' mapred-site.xml
sudo cat >> mapred-site.xml << EOL
<configuration>
<property>
  <name>mapred.job.tracker</name>
  <value>localhost:54311</value>
</property>
</configuration>
EOL
EOF

echo 'successfully updated mapred-site.xml'
pwd

#sudo -u hduser bash << EOF
#sudo cat >> yarn-site.xml << EOL
#<configuration>
#<property>
#<name>yarn.nodemanager.aux-services</name>
#<value>mapreduce_shuffle</value>
#</property>
#</configuration>
#EOL
#EOF

sudo -u hduser bash << EOF
sed -i '/<configuration>/,/<\/configuration>/d' hdfs-site.xml
sudo cat >> hdfs-site.xml << EOL
<configuration>
<property>
<name>dfs.replication</name>
<value>1</value>
</property>
<property>
<name>dfs.name.dir</name>
<value>/app/hadoop/namenode </value>
</property>
<property>
<name>dfs.data.dir</name>
<value>/app/hadoop/datanode </value >
</property>
</configuration>
EOL
EOF

echo 'successfully updated hdfs-site.xml'

sudo -u hduser bash << EOF
source /home/hduser/.bashrc
EOF

sudo rm -Rf /app/hadoop/namenode
sudo rm -Rf /app/hadoop/namenode
sudo rm -Rf /app/hadoop/tmp

sudo mkdir -p /app/hadoop/datanode
sudo mkdir -p /app/hadoop/namenode
sudo mkdir -p /app/hadoop/tmp
sudo chown hduser:hadoop /app/hadoop/*
sudo chmod 755 /app/hadoop/*

sudo -u hduser bash << EOF
/usr/local/hadoop/bin/hdfs namenode -format
EOF

sudo -u hduser bash << EOF
/usr/local/hadoop/sbin/start-dfs.sh
EOF

sudo -u hduser bash << EOF
/usr/local/hadoop/sbin/start-yarn.sh
EOF

sudo -u hduser bash << EOF
jps
EOF

cd /home/ubuntu

wget http://apache.claz.org/pig/pig-0.16.0/pig-0.16.0.tar.gz
sudo tar xzf pig-0.16.0.tar.gz

cd /usr/local
sudo mkdir pig
sudo mv /home/ubuntu/pig-0.16.0/* pig/

sudo cat >> ~/.bashrc << EOL
export JAVA_HOME=/usr/lib/jvm/java-8-oracle
export PIG_HOME=/usr/local/pig
EOL

source ~/.bashrc

sudo cat >> ~/.bashrc << EOL
export PATH=$PATH:$JAVA_HOME/bin:$PIG_HOME/bin
EOL

source ~/.bashrc
