import SentimenMintRequest from "../contracts/NFTs/SentimenMintRequest.cdc"

pub fun main(address: Address) : [SentimenMintRequest.MintRequest]? {
  return SentimenMintRequest.getMintRequestsByAddress(address: address)
}