
# script to start a sharded environment on localhost

# clean everything up
echo "killing mongod and mongos"
sudo killall mongod
sudo killall mongos
echo "removing data files"
rm -rf sharding/data/db/config
rm -rf sharding/data/db/shard*
rm -rf sharding/data/db/logFiles

# start a replica set and tell it that it will be shard0
echo "starting servers for shard 0"
mkdir -p sharding/data/db/shard0/rs0 sharding/data/db/shard0/rs1 sharding/data/db/shard0/rs2 logFiles/

mongod --replSet s0 --logpath "logFiles/s0-r0.log" --dbpath sharding/data/db/shard0/rs0 --port 27017 --fork --shardsvr --smallfiles
mongod --replSet s0 --logpath "logFiles/s0-r1.log" --dbpath sharding/data/db/shard0/rs1 --port 27018 --fork --shardsvr --smallfiles
mongod --replSet s0 --logpath "logFiles/s0-r2.log" --dbpath sharding/data/db/shard0/rs2 --port 27019 --fork --shardsvr --smallfiles

sleep 5
# connect to one server and initiate the set
echo "Configuring s0 replica set"
mongo --port 27017 << 'EOF'
config = { _id: "s0", members:[
          { _id : 0, host : "localhost:27017" },
          { _id : 1, host : "localhost:27018" },
          { _id : 2, host : "localhost:27019" }]};
rs.initiate(config)
EOF

# start a replicate set and tell it that it will be a shard1
echo "starting servers for shard 1"
mkdir -p sharding/data/db/shard1/rs0 sharding/data/db/shard1/rs1 sharding/data/db/shard1/rs2 logFiles/

mongod --replSet s1 --logpath "logFiles/s1-r0.log" --dbpath sharding/data/db/shard1/rs0 --port 37017 --fork --shardsvr --smallfiles
mongod --replSet s1 --logpath "logFiles/s1-r1.log" --dbpath sharding/data/db/shard1/rs1 --port 37018 --fork --shardsvr --smallfiles
mongod --replSet s1 --logpath "logFiles/s1-r2.log" --dbpath sharding/data/db/shard1/rs2 --port 37019 --fork --shardsvr --smallfiles

sleep 5

echo "Configuring s1 replica set"
mongo --port 37017 << 'EOF'
config = { _id: "s1", members:[
          { _id : 0, host : "localhost:37017" },
          { _id : 1, host : "localhost:37018" },
          { _id : 2, host : "localhost:37019" }]};
rs.initiate(config)
EOF

# start a replicate set and tell it that it will be a shard2
echo "starting servers for shard 2"
mkdir -p sharding/data/db/shard2/rs0 sharding/data/db/shard2/rs1 sharding/data/db/shard2/rs2 logFiles/

mongod --replSet s2 --logpath "logFiles/s2-r0.log" --dbpath sharding/data/db/shard2/rs0 --port 47017 --fork --shardsvr --smallfiles
mongod --replSet s2 --logpath "logFiles/s2-r1.log" --dbpath sharding/data/db/shard2/rs1 --port 47018 --fork --shardsvr --smallfiles
mongod --replSet s2 --logpath "logFiles/s2-r2.log" --dbpath sharding/data/db/shard2/rs2 --port 47019 --fork --shardsvr --smallfiles

sleep 5

echo "Configuring s2 replica set"
mongo --port 47017 << 'EOF'
config = { _id: "s2", members:[
          { _id : 0, host : "localhost:47017" },
          { _id : 1, host : "localhost:47018" },
          { _id : 2, host : "localhost:47019" }]};
rs.initiate(config)
EOF

# now start 3 config servers
echo "Starting config servers"
mkdir -p sharding//data/db/config/config-a sharding//data/db/config/config-b sharding//data/db/config/config-c logFiles/

mongod --logpath "logFiles/cfg-a.log" --dbpath sharding/data/db/config/config-a --port 47040 --fork --configsvr --smallfiles
mongod --logpath "logFiles/cfg-b.log" --dbpath sharding/data/db/config/config-b --port 47041 --fork --configsvr --smallfiles
mongod --logpath "logFiles/cfg-c.log" --dbpath sharding/data/db/config/config-c --port 47042 --fork --configsvr --smallfiles

# now start the mongos on a standard port
mongos --logpath "logFiles/mongos-1.log" --configdb localhost:47040,localhost:47041,localhost:47042 --fork
echo "Waiting 60 seconds for the replica sets to fully come online"
sleep 60
echo "Connnecting to mongos and enabling sharding"

# add shards and enable sharding on the test db
mongo <<'EOF'
db.adminCommand( { addshard : "s0/"+"localhost:27017" } );
db.adminCommand( { addshard : "s1/"+"localhost:37017" } );
db.adminCommand( { addshard : "s2/"+"localhost:47017" } );
db.adminCommand({enableSharding: "qwertz"})
db.adminCommand({shardCollection: "qwertz.users", key: {student_id:1}});
EOF


