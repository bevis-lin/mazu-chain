import SentimenCreator from "../contracts/NFTs/SentimenCreator.cdc"

pub fun main(address: Address): SentimenCreator.Creator? {
  return SentimenCreator.getCreatorProfleByAddress(address: address)
}