import NonFungibleToken from "../contracts/NonFungibleToken.cdc"
import Sentimen from "../contracts/NFTs/Sentimen.cdc"
import SentimenMetadata from "../contracts/NFTs/SentimenMetadata.cdc"

 pub fun main(addr: Address): {UInt64: &Sentimen.NFT}? {
     let account = getAccount(addr)
     if let ref = account.getCapability<&Sentimen.Collection{Sentimen.ICardCollectionPublic, NonFungibleToken.CollectionPublic}>(/public/sentimenCollection)
                 .borrow() {
                  
                  var ids = ref.getIDs()

                  var resultNFTs: {UInt64: &Sentimen.NFT} = {}

                  for id in ids {
                    resultNFTs[id] = ref.borrowCard(id: id)
                  }
                   


                   return resultNFTs
                 }
    
     return nil
 }