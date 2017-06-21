
# script to start a sharded environment on localhost

# clean everything up
echo "killing mongod and mongos"
sudo killall mongod
sudo killall mongos
sleep 3
echo "removing data files"
rm -rf sharding/data/db/*

# now start 3 config servers
rm logFiles/cfg-a.log logFiles/cfg-b.log logFiles/cfg-c.log
echo "Starting config servers"
mkdir -p sharding//data/db/config/config-a sharding//data/db/config/config-b sharding//data/db/config/config-c logFiles/

mongod --configsvr --replSet configServers --port 27017 --logpath "logFiles/cfg-a.log" --logappend --dbpath sharding/data/db/config/config-a --fork --smallfiles
mongod --configsvr --replSet configServers --port 27017 --logpath "logFiles/cfg-b.log" --logappend --dbpath sharding/data/db/config/config-b --fork --smallfiles
mongod --configsvr --replSet configServers --port 27017 --logpath "logFiles/cfg-c.log" --logappend --dbpath sharding/data/db/config/config-c --fork --smallfiles

sleep 5

echo "Configuring configServers replica set"

ssh ec2-user@52.28.177.69
sudo service mongod start
mongo 52.28.177.69:27017 << 'EOF'
use admin

config = { _id: "configServers", 
		   configsvr: true,
		   members:[
          { _id : 0, host : "mongocfg0.example.com:27017" },
          { _id : 1, host : "mongocfg1.example.com:27017" },
          { _id : 2, host : "mongocfg2.example.com:27017" }]};
rs.initiate(config)
EOF

# start a replica set and tell it that it will be shard0
echo "starting servers for shard 0"
mkdir -p sharding/data/db/shard0/rs0 sharding/data/db/shard0/rs1 sharding/data/db/shard0/rs2 logFiles/

mongod --shardsvr --replSet rs0 --logpath "logFiles/s0-r0.log" --logappend --dbpath sharding/data/db/shard0/rs0 --port 27017 --fork --smallfiles
mongod --shardsvr --replSet rs0 --logpath "logFiles/s0-r1.log" --logappend --dbpath sharding/data/db/shard0/rs1 --port 27017 --fork --smallfiles
mongod --shardsvr --replSet rs0 --logpath "logFiles/s0-r2.log" --logappend --dbpath sharding/data/db/shard0/rs2 --port 27017 --fork --smallfiles

sleep 5
# connect to one server and initiate the set
echo "Configuring rs0 replica set"

ssh ec2-user@52.28.246.59
sudo service mongod start
mongo 52.28.246.59:27017 << 'EOF'
use admin

config = { _id: "rs0", members:[
          { _id : 0, host : "mongo0.example.com:27017" },
          { _id : 1, host : "mongo1.example.com:27017" },
          { _id : 2, host : "mongo2.example.com:27017" }]};
rs.initiate(config)
EOF

# start a replicate set and tell it that it will be a shard1
echo "starting servers for shard 1"
mkdir -p sharding/data/db/shard1/rs0 sharding/data/db/shard1/rs1 sharding/data/db/shard1/rs2 logFiles/

mongod --shardsvr --replSet rs1 --logpath "logFiles/s1-r0.log" --logappend --dbpath sharding/data/db/shard1/rs0 --port 27017 --fork --smallfiles
mongod --shardsvr --replSet rs1 --logpath "logFiles/s1-r1.log" --logappend --dbpath sharding/data/db/shard1/rs1 --port 27017 --fork --smallfiles
mongod --shardsvr --replSet rs1 --logpath "logFiles/s1-r2.log" --logappend --dbpath sharding/data/db/shard1/rs2 --port 27017 --fork --smallfiles
sleep 5

echo "Configuring s1 replica set"

ssh ec2-user@52.28.246.59
sudo service mongod start
mongo 52.28.246.59:27017 << 'EOF'
use admin

#mongo 52.57.4.2:27017 << 'EOF'
config = { _id: "rs1", members:[
          { _id : 0, host : "mongo3.example.com:27017" },
          { _id : 1, host : "mongo4.example.com:27017" },
          { _id : 2, host : "mongo5.example.com:27017" }]};
rs.initiate(config)
EOF

# start a replicate set and tell it that it will be a shard2
# echo "starting servers for shard 2"
# mkdir -p sharding/data/db/shard2/rs0 sharding/data/db/shard2/rs1 sharding/data/db/shard2/rs2 logFiles/

# mongod --shardsvr --replSet s2 --logpath "logFiles/s2-r0.log" --logappend --dbpath sharding/data/db/shard2/rs0 --port 27017 --fork --smallfiles
# mongod --shardsvr --replSet s2 --logpath "logFiles/s2-r1.log" --logappend --dbpath sharding/data/db/shard2/rs1 --port 27017 --fork --smallfiles
# mongod --shardsvr --replSet s2 --logpath "logFiles/s2-r2.log" --logappend --dbpath sharding/data/db/shard2/rs2 --port 27017 --fork --smallfiles
# sleep 5

# echo "Configuring s2 replica set"
# mongo 52.37.228.164/27017 << 'EOF'
# config = { _id: "s2", members:[
#           { _id : 0, host : "52.37.228.164:27017" },
 #          { _id : 1, host : "52.88.81.254:27017" },
   #        { _id : 2, host : "34.208.96.195:27017" }]};
# rs.initiate(config)
# EOF

# now start the mongos on a standard port
# !!! now start the mongos on port 10000 !!!
#rm logFiles/mongos-1.log
#sleep 5
mkdir -p logFiles/
mongos --configdb configServers/mongocfg0.example.com:27017,mongocfg1.example.com:27017,mongocfg0.example.com:27017 --logpath "logFiles/mongos-1.log" --logappend --port 27017 --fork
echo "Waiting 10 seconds for the replica sets to fully come online"
#sleep 60
sleep 10
echo "Connnecting to mongos and enabling sharding"

# add shards and enable sharding on the test db
mongo  ec2-user@35.157.181.34/27017 << 'EOF'
use admin
db.adminCommand( { addshard : "rs1/"+"mongo3.example.com:27017" } );
# db.adminCommand( { addshard : "s2/"+"52.37.228.164:27017" } );
db.adminCommand({enableSharding: "dbase"})
db.adminCommand({shardCollection: "dbase.users", key: {_id:1}});
EOF

sleep 5
echo "Done setting up sharded environment on Amazon EC2"

db.adminCommand({enableSharding: "qwertz"})
db.adminCommand({shardCollection: "qwertz.users", key: {"_id":1}});
db.adminCommand({shardCollection: "qwertz.photos.files", key: {"_id":1}});
db.adminCommand({shardCollection: "qwertz.photos.chunks", key: {"_id":1}});

sh.enableSharding("qwertz")
sh.shardCollection("qwertz.users", { _id : 1 } )
sh.shardCollection("qwertz.photos.files", { _id : 1 } )
sh.shardCollection("qwertz.photos.chunks", { _id : 1 } )


#for(var i=1001; i <= 10000 ; i++){db.test.insert({ "_id" : i, "I do" : i})}



