const hre = require("hardhat");

async function main() {
  console.log("Deploying Authority Ledger to Celo Alfajores Testnet");
  console.log("Chain ID: 44787\n");

  const CeloAuthorityState = await hre.ethers.getContractFactory("CeloAuthorityState");
  
  console.log("Deploying CeloAuthorityState...");
  const authority = await CeloAuthorityState.deploy();
  await authority.waitForDeployment();
  
  const address = await authority.getAddress();
  console.log(`✅ CeloAuthorityState deployed to: ${address}`);
  
  // Grant authority to an agent with micro-lending capability
  console.log("\nGranting authority to test agent...");
  const testAgent = "0x1234567890123456789012345678901234567890";
  const tx = await authority.grantAuthority(
    testAgent,
    3, // EXECUTE level
    "0x0000000000000000000000000000000000000000000000000000000000000001", // READ scope
    86400, // 24 hours
    100000000000000000000 // 100 cUSD credit limit (18 decimals)
  );
  await tx.wait();
  console.log(`✅ Authority granted to test agent`);
  
  console.log("\n--- Deployment Summary ---");
  console.log(`Contract: ${address}`);
  console.log(`Network: Celo Alfajores Testnet`);
  console.log(`Explorer: https://explorer.celo.org/alfajores/address/${address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});