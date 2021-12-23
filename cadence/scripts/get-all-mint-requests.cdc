import SentimenMintRequest from "../contracts/NFTs/SentimenMintRequest.cdc"

pub fun main() : {UInt64: SentimenMintRequest.MintRequest} {
  return SentimenMintRequest.getAllRequests()
}