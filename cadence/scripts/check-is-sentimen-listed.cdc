import Sentimen from 0x78e84183b7e33d61
import Marketplace from 0x78e84183b7e33d61

pub fun main(nftId: UInt64): Bool {

  let listingId = Marketplace.getListingID(nftType: Type<@Sentimen.NFT>(), nftID: nftId)

  if listingId == nil {
    return false
  }else{
    return true
  }

}