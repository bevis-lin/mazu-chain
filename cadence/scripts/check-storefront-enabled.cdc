import FungibleToken from 0x9a0766d93b6608b7
import FlowToken from 0x7e60df042a9c0868
import NonFungibleToken from 0x78e84183b7e33d61
import NFTStorefront from 0x78e84183b7e33d61
import Sentimen from 0x78e84183b7e33d61

pub fun main(addr: Address): Bool {

  let account = getAccount(addr)

  if account.getCapability<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(NFTStorefront.StorefrontPublicPath) == nil {
    return false
  }
  
  return true
}