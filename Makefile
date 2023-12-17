-include .env

## Script to deploy and verify contract for Sepolia Testnet
deploy-sepolia:
	forge script scripts/DeployFundMe.s.sol:DeployFundMe --rpc-url $(SEPOLIA_RPC_URL) --private-key $(TN_PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv