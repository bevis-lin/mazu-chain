//import Sentimen from 0xf21fee1faa18dce2
import NonFungibleToken from "../contracts/NonFungibleToken.cdc"
import Sentimen from "../contracts/NFTs/Sentimen.cdc"
  
  pub fun main(addr: Address): Bool {
    if getAccount(addr).getCapability(/public/sentimenCollection)!.borrow<&Sentimen.Collection{Sentimen.ICardCollectionPublic, NonFungibleToken.CollectionPublic}>() != nil {
      return true
    }else {
      return false
    }
  }