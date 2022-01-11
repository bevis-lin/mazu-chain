import SentimenMetadata from 0x78e84183b7e33d61

pub fun main(nftId: UInt64): SentimenMetadata.Metadata? {
  return SentimenMetadata.getMetadataForSentimenNFT(sentimenId: nftId)
}