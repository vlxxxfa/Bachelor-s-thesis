
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

mongod --configsvr --replSet configServers --port 26050 --logpath "logFiles/cfg-a.log" --logappend --dbpath sharding/data/db/config/config-a --fork --smallfiles
mongod --configsvr --replSet configServers --port 26051 --logpath "logFiles/cfg-b.log" --logappend --dbpath sharding/data/db/config/config-b --fork --smallfiles
mongod --configsvr --replSet configServers --port 26052 --logpath "logFiles/cfg-c.log" --logappend --dbpath sharding/data/db/config/config-c --fork --smallfiles

sleep 5

echo "Configuring configServers replica set"
mongo --port 26050 << 'EOF'
use admin
config = { _id: "configServers", 
		   configsvr: true,
		   members:[
          { _id : 0, host : "localhost:26050" },
          { _id : 1, host : "localhost:26051" },
          { _id : 2, host : "localhost:26052" }]};
rs.initiate(config)
EOF

# start a replica set and tell it that it will be shard0
echo "starting servers for shard 0"
mkdir -p sharding/data/db/shard0/rs0 sharding/data/db/shard0/rs1 sharding/data/db/shard0/rs2 logFiles/

mongod --shardsvr --replSet s0 --logpath "logFiles/s0-r0.log" --logappend --dbpath sharding/data/db/shard0/rs0 --port 27000 --fork --smallfiles
mongod --shardsvr --replSet s0 --logpath "logFiles/s0-r1.log" --logappend --dbpath sharding/data/db/shard0/rs1 --port 27001 --fork --smallfiles
mongod --shardsvr --replSet s0 --logpath "logFiles/s0-r2.log" --logappend --dbpath sharding/data/db/shard0/rs2 --port 27002 --fork --smallfiles

sleep 5
# connect to one server and initiate the set
echo "Configuring s0 replica set"
mongo --port 27000 << 'EOF'
config = { _id: "s0", members:[
          { _id : 0, host : "localhost:27000" },
          { _id : 1, host : "localhost:27001" },
          { _id : 2, host : "localhost:27002" }]};
rs.initiate(config)
EOF

# start a replicate set and tell it that it will be a shard1
echo "starting servers for shard 1"
mkdir -p sharding/data/db/shard1/rs0 sharding/data/db/shard1/rs1 sharding/data/db/shard1/rs2 logFiles/

mongod --shardsvr --replSet s1 --logpath "logFiles/s1-r0.log" --logappend --dbpath sharding/data/db/shard1/rs0 --port 37000 --fork --smallfiles
mongod --shardsvr --replSet s1 --logpath "logFiles/s1-r1.log" --logappend --dbpath sharding/data/db/shard1/rs1 --port 37001 --fork --smallfiles
mongod --shardsvr --replSet s1 --logpath "logFiles/s1-r2.log" --logappend --dbpath sharding/data/db/shard1/rs2 --port 37002 --fork --smallfiles
sleep 5

echo "Configuring s1 replica set"
mongo --port 37000 << 'EOF'
config = { _id: "s1", members:[
          { _id : 0, host : "localhost:37000" },
          { _id : 1, host : "localhost:37001" },
          { _id : 2, host : "localhost:37002" }]};
rs.initiate(config)
EOF

# start a replicate set and tell it that it will be a shard2
echo "starting servers for shard 2"
mkdir -p sharding/data/db/shard2/rs0 sharding/data/db/shard2/rs1 sharding/data/db/shard2/rs2 logFiles/

mongod --shardsvr --replSet s2 --logpath "logFiles/s2-r0.log" --logappend --dbpath sharding/data/db/shard2/rs0 --port 47000 --fork --smallfiles
mongod --shardsvr --replSet s2 --logpath "logFiles/s2-r1.log" --logappend --dbpath sharding/data/db/shard2/rs1 --port 47001 --fork --smallfiles
mongod --shardsvr --replSet s2 --logpath "logFiles/s2-r2.log" --logappend --dbpath sharding/data/db/shard2/rs2 --port 47002 --fork --smallfiles
sleep 5

echo "Configuring s2 replica set"
mongo --port 47000 << 'EOF'
config = { _id: "s2", members:[
          { _id : 0, host : "localhost:47000" },
          { _id : 1, host : "localhost:47001" },
          { _id : 2, host : "localhost:47002" }]};
rs.initiate(config)
EOF

# now start the mongos on a standard port
# !!! now start the mongos on port 10000 !!!
#rm logFiles/mongos-1.log
#sleep 5
mongos --port 27017 --logpath "logFiles/mongos-1.log" --logappend --configdb configServers/localhost:26050,localhost:26051,localhost:26052 --fork
echo "Waiting 10 seconds for the replica sets to fully come online"
#sleep 60
sleep 10
echo "Connnecting to mongos and enabling sharding"

# add shards and enable sharding on the test db
mongo --port 27017 << 'EOF'
use admin
db.adminCommand( { addshard : "s0/"+"localhost:27000" } );
db.adminCommand( { addshard : "s1/"+"localhost:37000" } );
db.adminCommand( { addshard : "s2/"+"localhost:47000" } );
db.adminCommand({enableSharding: "dbase"})
db.adminCommand({shardCollection: "dbase.users", key: {_id:1}});
EOF

sleep 5
echo "Done setting up sharded environment on localhost"




#for(var i=1; i <= 800000 ; i++){db.users.insert({ "_id" : i, "I do have a spreadsheet calculator as a starting pointI do have a spreadsheet calculator as a starting pointI do have a spreadsheet calculator as a starting pointI do have a spreadsheet calculator as a starting pointI do have a spreadsheet calculator as a starting pointI do have a spreadsheet calculator as a starting pointI do have a spreadsheet calculator as a starting pointI do have a spreadsheet calculator as a starting pointI do have a spreadsheet calculator as a starting pointI do have a spreadsheet calculator as a starting pointI do have a spreadsheet calculator as a starting pointI do have a spreadsheet calculator as a starting pointI do have a spreadsheet calculator as a starting pointI do have a spreadsheet calculator as a starting pointI do have a spreadsheet calculator as a starting pointI do have a spreadsheet calculator as a starting pointI do have a spreadsheet calculator as a starting pointI do have a spreadsheet calculator as a starting pointI do have a spreadsheet calculator as a starting pointI do have a spreadsheet calculator as a starting pointI do have a spreadsheet calculator as a starting pointI do have a spreadsheet calculator as a starting pointI do have a spreadsheet calculator as a starting pointI do have a spreadsheet calculator as a starting pointI do have a spreadsheet calculator as a starting pointI do have a spreadsheet calculator as a starting pointI do have a spreadsheet calculator as a starting pointI do have a spreadsheet calculator as a starting pointI do have a spreadsheet calculator as a starting point" : i})}



