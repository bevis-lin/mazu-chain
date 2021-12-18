import SentimenCreator from "../contracts/NFTs/SentimenCreator.cdc"

pub fun main() : {Address: SentimenCreator.Creator} {
  return SentimenCreator.getCreators()
}