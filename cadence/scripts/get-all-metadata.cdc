import SentimenMetadata from "../contracts/NFTs/SentimenMetadata.cdc"

pub fun main(): {UInt64: SentimenMetadata.Metadata} {

  return SentimenMetadata.getMetadatas()

}