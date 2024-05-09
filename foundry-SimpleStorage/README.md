# Foundry Simple Storage

This is part of the Cyfrin Solidity Blockchain Course.

*[⭐️ (6:23:59) | Lesson 6 | Foundry Simple Storage](https://www.youtube.com/watch?v=umepbfKp5rI&t=22979s)*

# Getting Started

## Requirements

- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
  - You'll know you did it right if you can run `git --version` and you see a response like `git version x.x.x`
- [ganache](https://trufflesuite.com/ganache/)
  - You'll know you did it right if you can run the application and see:
    <br>
    <img src="./img/ganache-picture.png" alt="ganache" width="200"/>
  - You can alternatively use [ganache-cli](https://www.npmjs.com/package/ganache-cli) or [hardhat](https://hardhat.org/)
- [foundry](https://getfoundry.sh/)
  - You'll know you did it right if you can run `forge --version` and you see a response like `forge 0.2.0 (816e00b 2023-03-16T00:05:26.396218Z)`


<!-- If you're installing foundry for the first time, you can put this in your `.bash_profile` or `.zshrc` depending on if you're using bash or zsh shell.

You can check which shell you are currently using by looking at the value of the SHELL environment variable or examining the current process name. Run the following command in your terminal:

```bash
echo $SHELL
```

And you'll see if you're using bash or zsh.


```bash
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi
``` -->

<!-- If you are using zsh, make sure to place your configurations, aliases, and functions in the .zshrc file located in your home directory. If the file doesn't exist, you can create it with touch ~/.zshrc. -->


## Setup

Clone this repo

```
git clone https://github.com/Cyfrin/foundry-simple-storage-f23
cd foundry-simple-storage-f23
```

## Usage

1. Run your ganache local chain, by hitting `quickstart` on your ganache application

> Save the workspace. This way, next time you open ganache you can start the workspace you've created, otherwise you'll have to redo all the steps below.

2. Copy the `RPC SERVER` sting in your ganache CLI, and place it into your `.env` file similar to what's in `.env.example`.

<img src="./img/ganache-http.png" alt="ganache" width="500"/>

`.env` Example:

```
RPC_URL=http://0.0.0.0:8545
```

3. Hit the key on one of the accounts, and copy the key you see and place it into your `.env` file, similar to what you see in `.env.example`.

<img src="./img/ganache-key.png" alt="ganache" width="500"/>

<img src="./img/ganache-private-key.png" alt="ganache" width="500"/>

`.env` Example:

PRIVATE_KEY=11ee3108a03081fe260ecdc106554d09d9d1209bcafd46942b10e02943effc4a

4. Compile your code

Run

```
forge compile
```

5. Deploy your contract

```
forge create SimpleStorage --private-key <PRIVATE_KEY>
```

## Windows, WSL, & Ganache
If you're using WSL, for the ganache UI you'll have to use a different endpoint.
You have 4 options to fix this:

1. Use the WSL endpoint on the ganache UI (this sometimes doesn't work)
2. Use `anvil` (We will move to anvil at some point anyways...)


### Deploying to a testnet

Make sure you have a [metamask](https://metamask.io/) or other wallet, and export the private key.

**IMPORTANT**

USE A METAMASK THAT DOESNT HAVE ANY REAL FUNDS IN IT. Just in case you accidentally push your private key to a public place. I _highly_ recommend you use a different metamask or wallet when developing.

1. [Export your private key](https://metamask.zendesk.com/hc/en-us/articles/360015289632-How-to-Export-an-Account-Private-Key) and place it in your `.env` file, as done above.

2. Go to [Alchemy](https://alchemy.com/?a=673c802981) and create a new project on the testnet of choice (ie, Goerli)
3. Grab your URL associated with the testnet, and place it into your `.env` file.
4. Make sure you have [testnet ETH](https://faucets.chain.link/) in your account. You can [get some here](https://faucets.chain.link/). You should get testnet ETH for the same testnet that you made a project in Alchemy (ie, Goerli)
5. Run

```
forge create SimpleStorage --private-key <PRIVATE_KEY> --rpc-url <ALCHEMY_URL>
```

Or, you can use a deploy script!

```
forge script script/DeploySimpleStorage.s.sol --private-key <PRIVATE_KEY> --rpc-url <ALCHEMY_URL>
```



## COMMAND 

* Simply deploy contract in interactive mode
```sh
forge create SimpleStorage --rpc-url http://127.0.0.1:8545 --interactive
Or
forge create SimpleStorage --rpc-url http://127.0.0.1:8545 --private-key $PRIVATE_KEY
```

* Deploy using script
```sh
forge script script/DeploySimpleStorage.s.sol --rpc-url http://127.0.0.1:8545 --broadcast --private-key $PRIVATE_KEY
||
forge script script/DeploySimpleStorage.s.sol --rpc-url $RPC_URL  --broadcast --private-key $PRIVATE_KEY

```

* Using cast to cast into dec 
```
cast --to-base 0x000000000000000000000000000000000000000000000000000000000000007b dec
cast --to-base 0x71706 dec
```

* Create a wallet to secure private 
```sh
1. cast wallet import defaultKey --interactive
2. cast wallet list
# Deploy using wallet
3. forge script script/DeploySimpleStorage.s.sol --rpc-url $RPC_URL --account defaultKey --sender `WalletAddress` --broadcast -vvvv
```

* Interact with contract from terminal

```
1. cast send 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0 "store(uint256)" 123 --rpc-url $RPC_URL --private-key $PRIVATE_KEY
2. cast call 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0 "retrieve()"
```

* Deploy on a testnet 
```
forge script script/DeploySimpleStorage.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast --private-key $METAMASK_PRIVATE_KEY
```