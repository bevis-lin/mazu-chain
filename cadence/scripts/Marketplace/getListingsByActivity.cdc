import NFTStorefront from "../../contracts/NFTStorefront.cdc"
import Marketplace from "../../contracts/Marketplace.cdc"
import SentimenMetadata from "../../contracts/NFTs/SentimenMetadata.cdc"

pub fun main(activityID:UInt, offset: Int, limit: Int): DipslayResult {
    var activitylistingIds: {UInt64:UInt64} = Marketplace.getActivityListingIDs(activityID: activityID)
    log(activitylistingIds.length.toString())

    var displayItems: [ListingDisplayItem] = []
    var limit = limit
    var skipCount = 0
    var index = offset

    for listingID in activitylistingIds.values {
        if let item = getListingDisplayItem(listingID:listingID) {
            displayItems.append(item)
            limit = limit - 1
        } else {
            skipCount = skipCount + 1
        }
        index = index + 1
    }

    return DipslayResult(displayItems: displayItems, skipCount: skipCount)
}

pub struct ListingDisplayItem {

    pub let listingID: UInt64

    pub var address: Address

    // The identifier of type of the NonFungibleToken.NFT that is being listed.
    pub let nftType: String
    // The ID of the NFT within that type.
    pub let nftID: UInt64
    // The identifier of type of the FungibleToken that payments must be made in.
    pub let salePaymentVaultType: String
    // The amount that must be paid in the specified FungibleToken.
    pub let salePrice: UFix64
    // This specifies the division of payment between recipients.
    pub let saleCuts: [NFTStorefront.SaleCut]

    pub let timestamp: UFix64

    pub let metadata: SentimenMetadata.Metadata

    init (
        listingID: UInt64,
        address: Address,
        nftType: String,
        nftID: UInt64,
        salePaymentVaultType: String,
        salePrice: UFix64,
        saleCuts: [NFTStorefront.SaleCut],
        timestamp: UFix64,
        metadata: SentimenMetadata.Metadata
    ) {
        self.listingID = listingID
        self.address = address
        self.nftType = nftType
        self.nftID = nftID
        self.salePaymentVaultType = salePaymentVaultType
        self.salePrice = salePrice
        self.saleCuts = saleCuts
        self.timestamp = timestamp
        self.metadata = metadata
    }
}

pub struct DipslayResult {
    pub let displayItems: [ListingDisplayItem]
    pub let skipCount: Int

    init(displayItems: [ListingDisplayItem], skipCount: Int) {
        self.displayItems = displayItems
        self.skipCount = skipCount
    }
}

pub fun getListingDisplayItem(listingID: UInt64): ListingDisplayItem? {
    if let item = Marketplace.getListingIDItem(listingID: listingID) {
        if let storefrontPublic = item.storefrontPublicCapability.borrow() {
            if let listingPublic = storefrontPublic.borrowListing(listingResourceID: listingID) {
                let listingDetails = listingPublic.getDetails()

                if listingDetails.purchased == false {

                    let metadata = SentimenMetadata.getMetadataForSentimenNFT(sentimenId: listingDetails.nftID)! as SentimenMetadata.Metadata

                    return ListingDisplayItem(
                        listingID: listingID,
                        address: item.storefrontPublicCapability.address,
                        nftType: listingDetails.nftType.identifier,
                        nftID: listingDetails.nftID,
                        salePaymentVaultType: listingDetails.salePaymentVaultType.identifier,
                        salePrice: listingDetails.salePrice,
                        saleCuts: listingDetails.saleCuts,
                        timestamp: item.timestamp,
                        metadata: metadata
                    )
                }
            }
        }
    }

    return nil
}