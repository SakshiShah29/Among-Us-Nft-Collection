const {ethers}=require("hardhat");
require("dotenv").config({path:".env"});
const {WHITELIST_CONTRACT_ADDRESS,METADATA_URL}=require("../constants");

async function main(){
  const whitelistContract=WHITELIST_CONTRACT_ADDRESS;
  const metadatURL=METADATA_URL;
  const AmongUsContract=await ethers.getContractFactory("AmongUs");
  const deployedAmongUsContract=await AmongUsContract.deploy(
    metadatURL,
    whitelistContract
  );

  console.log("Among Us Contract Address:",deployedAmongUsContract.address);
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });