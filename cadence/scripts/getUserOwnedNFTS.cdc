import Sentimen from "../contracts/NFTs/Sentimen.cdc"
import SentimenMetadata from "../contracts/NFTs/SentimenMetadata.cdc"

pub fun main(addr: Address): Result {
    let account = getAccount(addr)

    var nfts: [NFT] = []
    var nftMetadatas: [SentimenMetadata.Metadata?] = []
    
    if let collectionRef = account.getCapability(/public/sentimenCollection)!.borrow<&{Sentimen.ICardCollectionPublic}>() {
        let type = Type<@Sentimen.NFT>()
        let ids = collectionRef.getIDs()
        nfts.appendAll(getNFTs(nftType: type, nftIDs: ids))
        for id in ids {
          let metadata = SentimenMetadata.getMetadataForCardID(cardID: id)
          nftMetadatas.append(metadata)
        }
    }

   
    return Result(
        nfts: nfts,
        nftMetadatas: nftMetadatas
    )
}

pub struct NFT {
    pub let nftType: Type
    pub let nftID: UInt64

    init(nftType: Type, nftID: UInt64) {
        self.nftType = nftType
        self.nftID = nftID
    }
}

pub fun getNFTs(nftType: Type, nftIDs: [UInt64]): [NFT] {
    var nfts: [NFT] = []
    for id in nftIDs {
        nfts.append(NFT(
            nftType: nftType,
            nftID: id
        ))
    }
    return nfts
}

pub struct Result {
    pub let nfts: [NFT]
    pub let nftMetadatas: [SentimenMetadata.Metadata?]

    init(nfts: [NFT], nftMetadatas: [SentimenMetadata.Metadata?]) {
        self.nfts = nfts
        self.nftMetadatas = nftMetadatas
    }
}