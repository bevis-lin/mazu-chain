import NonFungibleToken from "../contracts/NonFungibleToken.cdc"
import Sentimen from "../contracts/NFTs/Sentimen.cdc"
import SentimenMetadata from "../contracts/NFTs/SentimenMetadata.cdc"


pub fun main(addr: Address, id: UInt64): [UInt64]? {
     let account = getAccount(addr)
     if let ref = account.getCapability<&Sentimen.Collection{Sentimen.ICardCollectionPublic, NonFungibleToken.CollectionPublic}>(/public/sentimenCollection)
                 .borrow() {
                   return ref.getIDs()
                 }
    
     return nil
 }

// pub fun main(addr: Address, id: UInt64): &Sentimen.NFT? {
//     let account = getAccount(addr)
//     if let ref = account.getCapability<&Sentimen.Collection{Sentimen.ICardCollectionPublic, NonFungibleToken.CollectionPublic}>(/public/sentimenCollection)
//                 .borrow() {
//                   return ref.borrowCard(id: id)
//                 }
    
//     return nil
// }

// pub fun main(addr: Address, id: UInt64): SentimenMetadata.Metadata? {
//     let account = getAccount(addr)
//     if let ref = account.getCapability<&Sentimen.Collection{Sentimen.ICardCollectionPublic, NonFungibleToken.CollectionPublic}>(/public/sentimenCollection)
//                 .borrow() {
//                   //let sentimenNFT = ref.borrowCard(id: id) as &Sentimen.NFT?
//                   //return sentimenNFT.id
//                   return SentimenMetadata.getMetadataForCardID(cardID: id)
//                 }
    
//     return nil
// }
