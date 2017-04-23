#!/usr/bin/env bash

mkdir -p replSet/data/db/rs1 replSet/data/db/rs2 replSet/data/db/rs3 logFiles/

mongod --replSet replSet --logpath "logFiles/1.log" --dbpath replSet/data/db/rs1 --port 27017 --oplogSize 64 --fork --smallfiles
mongod --replSet replSet --logpath "logFiles/2.log" --dbpath replSet/data/db/rs2 --port 27018 --oplogSize 64 --smallfiles --fork
mongod --replSet replSet --logpath "logFiles/3.log" --dbpath replSet/data/db/rs3 --port 27019 --oplogSize 64 --smallfiles --fork

sleep 5
# connect to one server and initiate the set
echo "Configuring a replica set"
mongo --port 27017 << 'EOF'

config = { _id: "replSet", members:[
              { _id : 0, host : "localhost:27017"},
              { _id : 1, host : "localhost:27018"},
              { _id : 2, host : "localhost:27019"} ]
};
rs.initiate(config);
EOF