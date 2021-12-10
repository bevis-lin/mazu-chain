import FungibleToken from 0xee82856bf20e2aa6
import NonFungibleToken from "../contracts/NonFungibleToken.cdc"
import NFTStorefront from "../contracts/NFTStorefront.cdc"
import Marketplace from "../contracts/Marketplace.cdc"
import FlowToken from 0x0ae53cb6e3f42a79
import Sentimen from "../contracts/NFTs/Sentimen.cdc"

transaction(listingResourceID: UInt64, storefrontAddress: Address, buyPrice: UFix64) {
    let paymentVault: @FungibleToken.Vault
    let SentimenCollection: &Sentimen.Collection{NonFungibleToken.Receiver}
    let storefront: &NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}
    let listing: &NFTStorefront.Listing{NFTStorefront.ListingPublic}

    prepare(signer: AuthAccount) {
        // Create a collection to store the purchase if none present
        if signer.borrow<&Sentimen.Collection>(from: /storage/sentimenCollection) == nil {
            signer.save(<- Sentimen.createEmptyCollection(), to: /storage/sentimenCollection)
            signer.link<&Sentimen.Collection{Sentimen.ICardCollectionPublic, NonFungibleToken.CollectionPublic}>(/public/sentimenCollection, target: /storage/sentimenCollection)
        }

        self.storefront = getAccount(storefrontAddress)
            .getCapability<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(NFTStorefront.StorefrontPublicPath)
            .borrow()
            ?? panic("Could not borrow Storefront from provided address")

        self.listing = self.storefront.borrowListing(listingResourceID: listingResourceID)
            ?? panic("No Offer with that ID in Storefront")
        let price = self.listing.getDetails().salePrice

        assert(buyPrice == price, message: "buyPrice is NOT same with salePrice")

        let flowTokenVault = signer.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
            ?? panic("Cannot borrow FlowToken vault from signer storage")
        self.paymentVault <- flowTokenVault.withdraw(amount: price)

        self.SentimenCollection = signer.borrow<&Sentimen.Collection{NonFungibleToken.Receiver}>(from: /storage/sentimenCollection)
            ?? panic("Cannot borrow NFT collection receiver from account")
    }

    execute {
        let item <- self.listing.purchase(payment: <-self.paymentVault)

        self.SentimenCollection.deposit(token: <-item)

        // Be kind and recycle
        self.storefront.cleanup(listingResourceID: listingResourceID)
        Marketplace.removeListing(id: listingResourceID)
    }

}
