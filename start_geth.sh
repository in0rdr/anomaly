#!/usr/bin/env bash

enode1="enode://f64717b1e2f5e320d8375a530a512a7957a99664038a2921679688d520eb431da209f6b232e20bbd258832dfa8028f7d7dfd9b649abcd192aa56f51b2405e505@"
enode2="enode://f2285f930e1e26a00406b64914bfda9927b927b25fa04d16d65d437f015a81232e9eb872d8026239b6be408dfe32fec05d0d7b23e7f5c351ca27fc2d26959051@"
enode3="enode://aa86de6d9ac9de726be7763c91700b6b03bbc9cdb56db9873f1ff5d922951e3000cf6b4b32c89fd32b56909b9573b0811864fafc1ccee5a7eefd74dd220916f8@"
enode4="enode://b0f3cf4ff5f48bb3ba9d3071183b0fcf2c94b250073dd8ea81017ac73aa3632bba10a29f46a8a1089bd9ce4d04171dec1968a9727bd78905020ae48b9281b95c@"

usage() {
  echo "Usage: $0 speed peer"
  echo
  echo " speed: Miner speed"
  echo "  - \"slow\",  1 thread"
  echo "  - \"fast\", 24 threads"
  echo
  echo " peer: IP of additional peer or bootnode"
}

# check input
if [[ "$1" != "slow" && "$1" != "fast" || "$#" -lt 2 ]]
then
 usage
 exit
fi

# rm prompt
echo -n "<<-- WARNING: This will prune ~/.ethereum*, proceed? [y/N]: "
read proceed
if [ "$proceed" != "y" ]
then
  exit
fi
echo

echo "<<-- Cleaning existing geth configs"
rm -rf ~/.ethereum*
rm -rf ~/.ethash
echo "-->> Clean"
echo "<<-- Existing geth processes:"
pgrep -l geth$
pkill geth$
echo "-->> Processes killed"
echo

# import accounts
p1="0x0bae58123a6f907f9d20061f676a9df8548ee6f0"
p2="0xc0113c6615ca98661b2f0b07df603420fac6b2e3"
p3="0x590ff0aaf1906d34c9b7ed9df3976d98eb677b37"

echo "<<-- Extracting accounts:"
tar -vxf accounts.tar.gz -C ~
echo "-->> Extraction completed"
echo 
echo "<<-- Extracted accounts:"
geth --datadir=~/.ethereum2 account list
echo

# initialize peers
echo "<<-- Initializing geth for P1/P3:"
geth init genesis.json
echo "-->> P1/P3 initialization finished"

echo "<<-- Initializing geth for P2:"
geth --datadir ~/.ethereum2 init genesis.json
echo "-->> P2 initialization finished"
echo

# run peers
if [[ "$1" == "slow" ]]
then
  ## p1, slow miner
  echo "<<-- Starting slow miner P1"
  geth --datadir=~/.ethereum2 --rpcapi="eth,net,web3,admin,personal,miner" --rpccorsdomain "*" \
  --rpc --rpcport 8545 --rpcaddr "0.0.0.0" --networkid 15 \
  --mine --minerthreads=1 --etherbase=$p2 \
  --nodekey ./nodekeys/nodekey1 \
  --bootnodes "${enode2}127.0.0.1:30304,${enode3}${2}:30303" \
  --unlock "${p1},${p2},${p3}" --password "pwd.txt" &>/dev/null &
  echo "-->> Slow miner P1 running in background"

  ## p2, a client
  echo "<<-- Running client P2:"
  geth  --port 30304 \
  --rpcapi="eth,net,web3,admin,personal,miner" --rpccorsdomain "*" \
  --rpc --rpcport 8546 --rpcaddr "0.0.0.0" --networkid 15 \
  --nodekey ./nodekeys/nodekey2 \
  --unlock "${p1},${p2},${p3}" --password "pwd.txt"
else
  # p3, fast miner
  echo "<<-- Running fast miner P3:"
  geth --rpcapi="eth,net,web3,admin,personal,miner" --rpccorsdomain "*" \
  --rpc --rpcport 8545 --rpcaddr "0.0.0.0" --networkid 15 \
  --mine --minerthreads=24 --etherbase=$p2 \
  --nodekey ./nodekeys/nodekey3 \
  --bootnodes "${enode1}${2}:30303,${enode2}${2}:30304" \
  --unlock "${p1},${p2},${p3}" --password "pwd.txt"
fi

