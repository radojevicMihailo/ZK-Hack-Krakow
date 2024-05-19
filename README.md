# Proof of Activity

## How it works

You can use an email from traiding platfor that contains some proof of profit or liquidation to generate a ZK proof that you have activity on some trading platform.

This ZK proof can be used to mint an NFT corresponding to your username in the `ProofOfActiivity` contract.

## Running locally

#### Install dependencies

```bash
yarn
```

#### Start the web app. In `packages/app` directory, run

```bash
yarn start
```

This will start the UI at `http://localhost:3000/` where you can paste the email, generate proof and mint the NFT.

The UI works against the generated zkeys downloaded from AWS and the deployed contract on Sepolia.
