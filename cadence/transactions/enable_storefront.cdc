import FungibleToken from 0x9a0766d93b6608b7
import FlowToken from 0x7e60df042a9c0868
import NonFungibleToken from 0x78e84183b7e33d61
import NFTStorefront from 0x78e84183b7e33d61
import Sentimen from 0x78e84183b7e33d61

transaction() {
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
}