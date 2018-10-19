# ComSys Lab, Ex11: Blockchain Anomaly
![Anomaly](https://raw.githubusercontent.com/in0rdr/anomaly/master/anomaly.png)
(source: [1])

## 1 Preparation
```
# apt-get install software-properties-common
# add-apt-repository -y ppa:ethereum/ethereum
# apt-get update && apt-get install ethereum
```
## 2 Private Network
Start a slow miner (and a client) on PC1 (`10.0.X.1`) and a fast miner on PC2 (`10.0.X.2`). The slow miner connects with `.2` and the fast miner connects with the peers on `.1`:
```
$ bash start_geth.sh slow 10.0.X.2
$ bash start_geth.sh fast 10.0.X.1
```
## 3 Anomaly
Assume, that Alice owns the first address, Bob owns the second one (coinbase) and Charly ones the third one generated in that order:
```
$ geth attach
> p1="0x0bae58123a6f907f9d20061f676a9df8548ee6f0"
> p2="0xc0113c6615ca98661b2f0b07df603420fac6b2e3"
> p3="0x590ff0aaf1906d34c9b7ed9df3976d98eb677b37"
```

1. Check the balance on all three accounts (p1,p2,p3) with `eth.getBalance`. Why p2 holds more Ether than p1 and p3?
2. Compare the current block numbers on PC1 and PC2 with `eth.blockNumber`. Is there a difference? How do you explain the result?
3. Unfortunately, Charly's organization using PC2 (the stronger miner) has a network issue and is disconnected from the internet. Thus, plug the cable that connects PC1 and PC2 to simulate this network outage. Wait a few seconds and compare the current block numbers again. Do you see a difference? Explain your result.
4. The network outage goes unnoticed. Alice issues the following on PC1 to pay Bob:
```
eth.sendTransaction({from: p1, to: p2, value: web3.toWei(0.5, "ether")})
```
How much Gas did this transaction cost her? Hint: Use `eth.getBalance`
5. Alice notifies Bob about the transaction and Bob verifies on his end that he received the funds: `eth.getBalance(p2)`. Having been told, that transactions can be considered final after *k* (just a few) blocks/confirmations, he is convinced that his funds are secure. What is the current balance on Bob's account p2?
6. Bob does not notice, that the network issue in Charly's organization is fixed (reconnect the direct link between PC1 and PC2 again, wait a few seconds until blocks are in sync). Therefore, he issues the transaction to pay Charly on PC1:
```
eth.sendTransaction({from: p2, to: p3, value: web3.toWei(0.5, "ether")})
```
7. Again, compare the current block numbers on PC1 and PC2, are they in sync? Explain your result.
8. Bob notifies Charly about the transaction. After a sleepless night fighting malicious network daemons, he is happy to see the funds on his end: `eth.getBalance(p3)`. What is the current balance of Charly's account?
9. However, because Alice does not trust the technology, she checks her balance frequently: `eth.getBalance(p1)`. What is the current balance of Alice's account p1? And what do you think happened to the 0.5 Ether she sent to Bob recently? Can you explain what happened, considering the private blockchain with the two differently strong miners operates with PoW and the longest-chain selection rule <sup>1</sup>? How likely does this anomaly appear in larger blockchain networks with more peers?

## 4 Smart Contracts
1. Because Bob's funds are gone, he plans to be more cautious for the next conditional payment and creates a smart contract. Study the smart contract `./setup/contracts/ConditionalPayment.sol` and run a conditional payment example on http://remix.ethereum.org (Run > Environment > Web3 Provider). Why does this contract prevent the blockchain anomaly?
2. There are other ways to write this contract which are still prone to the blockchain anomaly. Find one such solution. Hint: You have to separate again the part that checks if Bob received the money from the part that sends the money from Bob to Charly

## 5 Double Spending
Explain with an example, how the blockchain anomaly can be used to create a double spending situation. If it helps: Think of a specific good you would like to receive twice, without paying twice :)

## References
[1] Natoli, Christopher, and Vincent Gramoli. "The blockchain anomaly." arXiv preprint arXiv:1605.05438 (2016). https://arxiv.org/pdf/1605.05438. Visited in October 2018.

[2] Enode URL Format: https://github.com/ethereum/wiki/wiki/enode-url-format. Visited in October 2018.

[3] Geth Command Line Options: https://github.com/ethereum/go-ethereum/wiki/Command-Line-Options. Visited in October 2018.

[4] Web3 JavaScript API: https://github.com/ethereum/wiki/wiki/JavaScript-API. Visited in October 2018.


---
<sup>1</sup> Without going into details here, Ethereum actually employs a variant of the longest-chain rule, the Greedy Heaviest Observed Subtree algorithm (GHOST)
