import SentimenMintRequest from "../contracts/NFTs/SentimenMintRequest.cdc"

pub fun main() : {Address: [SentimenMintRequest.MintRequest]} {
  return SentimenMintRequest.getMintRequests()
}