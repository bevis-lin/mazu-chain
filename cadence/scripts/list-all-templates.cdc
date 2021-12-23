import SentimenTemplate from "../contracts/NFTs/SentimenTemplate.cdc"
import SentimenCreator from "../contracts/NFTs/SentimenCreator.cdc"


pub fun main(): {UInt64: SentimenTemplate.Template} {
 
  return SentimenTemplate.getAllTemplates()

}