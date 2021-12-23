import SentimenTemplate from "../contracts/NFTs/SentimenTemplate.cdc"
import SentimenCreator from "../contracts/NFTs/SentimenCreator.cdc"


pub fun main(addr: Address): [SentimenTemplate.Template]? {
 
  return SentimenTemplate.getTemplatesByCreator(address: addr)

}