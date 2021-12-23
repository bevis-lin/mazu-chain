import SentimenMintRequest from "../contracts/NFTs/SentimenMintRequest.cdc"

pub fun main(address: Address) : [SentimenMintRequest.MintRequest]? {
  return SentimenMintRequest.getRequestsByCreator(address: address)
}