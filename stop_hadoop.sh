#!/bin/bash

sudo -u hduser bash << EOF
/usr/local/hadoop/sbin/stop-dfs.sh
EOF

sudo -u hduser bash << EOF
/usr/local/hadoop/sbin/stop-yarn.sh
EOF