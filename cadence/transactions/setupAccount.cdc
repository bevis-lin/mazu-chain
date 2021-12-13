import NonFungibleToken from 0xf21fee1faa18dce2
import Sentimen from 0xf21fee1faa18dce2
import SentimenPack from 0xf21fee1faa18dce2

transaction {

    prepare(signer: AuthAccount) {
        if signer.borrow<&SentimenPack.Collection>(from: /storage/sentimenPackCollection) == nil {
		    let packCollection <- SentimenPack.createEmptyCollection()
		    signer.save(<-packCollection, to: /storage/sentimenPackCollection)
		    signer.link<&SentimenPack.Collection{SentimenPack.IPackCollectionPublic, SentimenPack.IPackCollectionAdminAccessible, NonFungibleToken.CollectionPublic}>(/public/sentimenPackCollection, target: /storage/sentimenPackCollection)
	    }

	    if signer.getCapability(/public/sentimenPackCollection)!
            .borrow<&SentimenPack.Collection{SentimenPack.IPackCollectionPublic, SentimenPack.IPackCollectionAdminAccessible, NonFungibleToken.CollectionPublic}>() == nil {
            signer.unlink(/public/sentimenPackCollection)
            signer.link<&SentimenPack.Collection{SentimenPack.IPackCollectionPublic, SentimenPack.IPackCollectionAdminAccessible, NonFungibleToken.CollectionPublic}>(/public/sentimenPackCollection, target: /storage/sentimenPackCollection
            )
        }

	    if signer.borrow<&Sentimen.Collection>(from: /storage/sentimenCollection) == nil {
		    let cardCollection <- Sentimen.createEmptyCollection()
		    signer.save(<-cardCollection, to: /storage/sentimenCollection)
		    signer.link<&Sentimen.Collection{Sentimen.ICardCollectionPublic, NonFungibleToken.CollectionPublic}>(/public/sentimenCollection, target: /storage/sentimenCollection)
	    }

	    if signer.getCapability(/public/sentimenCollection)!
            .borrow<&Sentimen.Collection{Sentimen.ICardCollectionPublic, NonFungibleToken.CollectionPublic}>() == nil {
            signer.unlink(/public/sentimenCollection)
            signer.link<&Sentimen.Collection{Sentimen.ICardCollectionPublic, NonFungibleToken.CollectionPublic}>(
                /public/sentimenCollection,
                target: /storage/sentimenCollection
            )
        }
    }
}
