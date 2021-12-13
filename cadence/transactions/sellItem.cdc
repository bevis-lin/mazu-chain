import FungibleToken from 0x9a0766d93b6608b7
import NonFungibleToken from 0xf21fee1faa18dce2
import NFTStorefront from 0xf21fee1faa18dce2
import Marketplace from 0xf21fee1faa18dce2
import FlowToken from 0x7e60df042a9c0868
import Sentimen from 0xf21fee1faa18dce2

transaction(saleItemID: UInt64, saleItemPrice: UFix64, activityID: UInt) {
    let flowTokenReceiver: Capability<&FlowToken.Vault{FungibleToken.Receiver}>
    let sentimenProvider: Capability<&Sentimen.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>
    let storefront: &NFTStorefront.Storefront
    let storefrontPublic: Capability<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>

    prepare(signer: AuthAccount) {
        // Create Storefront if it doesn't exist
        if signer.borrow<&NFTStorefront.Storefront>(from: NFTStorefront.StorefrontStoragePath) == nil {
            let storefront <- NFTStorefront.createStorefront() as! @NFTStorefront.Storefront
            signer.save(<-storefront, to: NFTStorefront.StorefrontStoragePath)
            signer.link<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(
                NFTStorefront.StorefrontPublicPath,
                target: NFTStorefront.StorefrontStoragePath)
        }

        // We need a provider capability, but one is not provided by default so we create one if needed.
        let sentimenCardCollectionProviderPrivatePath = /private/sentimenCardCollectionProviderForNFTStorefront
        if !signer.getCapability<&Sentimen.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(sentimenCardCollectionProviderPrivatePath)!.check() {
            signer.link<&Sentimen.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(sentimenCardCollectionProviderPrivatePath, target: /storage/sentimenCollection)
        }

        self.flowTokenReceiver = signer.getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)!
        assert(self.flowTokenReceiver.borrow() != nil, message: "Missing or mis-typed FlowToken receiver")

        self.sentimenProvider = signer.getCapability<&Sentimen.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(sentimenCardCollectionProviderPrivatePath)!
        assert(self.sentimenProvider.borrow() != nil, message: "Missing or mis-typed Sentimen.Collection provider")

        self.storefront = signer.borrow<&NFTStorefront.Storefront>(from: NFTStorefront.StorefrontStoragePath)
            ?? panic("Missing or mis-typed NFTStorefront Storefront")

        self.storefrontPublic = signer.getCapability<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(NFTStorefront.StorefrontPublicPath)
        assert(self.storefrontPublic.borrow() != nil, message: "Could not borrow public storefront from address")
    }

    execute {
        // Remove old listing
        if let listingID = Marketplace.getListingID(nftType: Type<@Sentimen.NFT>(), nftID: saleItemID) {
            let listingIDs = self.storefront.getListingIDs()
            if listingIDs.contains(listingID) {
                self.storefront.removeListing(listingResourceID: listingID)
            }
            Marketplace.removeListing(id: listingID)
        }

        // Create SaleCuts
        var saleCuts: [NFTStorefront.SaleCut] = []
        let requirements = Marketplace.getSaleCutRequirements(nftType: Type<@Sentimen.NFT>())
        var remainingPrice = saleItemPrice
        for requirement in requirements {
            let price = saleItemPrice * requirement.ratio
            saleCuts.append(NFTStorefront.SaleCut(
                receiver: requirement.receiver,
                amount: price
            ))
            remainingPrice = remainingPrice - price
        }
        saleCuts.append(NFTStorefront.SaleCut(
            receiver: self.flowTokenReceiver,
            amount: remainingPrice
        ))

        // Add listing
        let id = self.storefront.createListing(
            nftProviderCapability: self.sentimenProvider,
            nftType: Type<@Sentimen.NFT>(),
            nftID: saleItemID,
            salePaymentVaultType: Type<@FlowToken.Vault>(),
            saleCuts: saleCuts,
            activityID: activityID
        )
        Marketplace.addListing(id: id, storefrontPublicCapability: self.storefrontPublic)
    }
}