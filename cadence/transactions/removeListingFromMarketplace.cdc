//import NFTStorefront from 0xNFTStorefront
import Marketplace from 0x2ebc7543c6a3f855


transaction(listingId:UInt64) {

  prepare(signer: AuthAccount){
    Marketplace.removeListing(id: listingId)

  }

  
}