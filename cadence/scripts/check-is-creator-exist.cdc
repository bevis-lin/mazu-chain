import SentimenCreator from "../contracts/NFTs/SentimenCreator.cdc"

pub fun main(address: Address) : Bool {
  return SentimenCreator.checkIsCreator(address: address)
}