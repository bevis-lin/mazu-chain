  import Sentimen from 0x4cb6bfd7b94aea71
  import SentimenPack from 0x4cb6bfd7b94aea71
  import NFTStorefront from 0x4cb6bfd7b94aea71

  transaction() {
    prepare(acct: AuthAccount) {

      if acct.borrow<&Sentimen.Collection>(from: /storage/sentimenCollection) != nil {
        let collectionRef <- acct.load<@Sentimen.Collection>(from: /storage/sentimenCollection)
          ?? panic("Could not borrow collection reference")
        destroy collectionRef
        acct.unlink(/public/sentimenCollection)
      }

      if acct.borrow<&SentimenPack.Collection>(from: /storage/sentimenPackCollection) != nil {
        let packCollectionRef <- acct.load<@SentimenPack.Collection>(from: /storage/sentimenPackCollection)
          ?? panic("Could not borrow pack collection reference")
        destroy packCollectionRef
        acct.unlink(/public/sentimenPackCollection)
      }

      if acct.borrow<&NFTStorefront.Storefront>(from: NFTStorefront.StorefrontStoragePath) != nil {
        let storefrontRef <- acct.load<@NFTStorefront.Storefront>(from: NFTStorefront.StorefrontStoragePath)
          ?? panic("Could not borrow storefront reference")
        
        destroy storefrontRef
        acct.unlink(NFTStorefront.StorefrontPublicPath)
      }

      let sentimenCardCollectionProviderPrivatePath = /private/sentimenCardCollectionProviderForNFTStorefront
      if !acct.getCapability<&Sentimen.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(sentimenCardCollectionProviderPrivatePath)!.check() {
        signer.unlink(sentimenCardCollectionProviderPrivatePath)
      }

    }
  }