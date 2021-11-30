import FungibleToken from 0xee82856bf20e2aa6
import Marketplace from "../contracts/Marketplace.cdc"
import FlowToken from 0x0ae53cb6e3f42a79
import Sentimen from "../contracts/NFTs/Sentimen.cdc"
import SentimenPack from "../contracts/NFTs/SentimenPack.cdc"

// This transaction creates SaleCutRequirements of Marketplace for NFT & Digi96

transaction {

    prepare(signer: AuthAccount) {
        let digi96Recipient: Address = 0xf8d6e0586b0a20c7
        let digi96Ratio = 0.025 // 2.5%
        let nftRecipient: Address = 0x01cf0e2f2f715450
        let nftRatio = 0.075 // 7.5%

        assert(nftRatio + digi96Ratio <= 1.0, message: "total of ratio must be less than or equal to 1.0")

        let admin = signer.borrow<&Marketplace.Administrator>(from: Marketplace.MarketplaceAdminStoragePath)
            ?? panic("Cannot borrow marketplace admin")

        let requirements: [Marketplace.SaleCutRequirement] = []

        // Blocto SaleCut
        if digi96Ratio > 0.0 {
            let bloctoFlowTokenReceiver = getAccount(digi96Recipient).getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)
            assert(bloctoFlowTokenReceiver.borrow() != nil, message: "Missing or mis-typed blocto FlowToken receiver")
            requirements.append(Marketplace.SaleCutRequirement(receiver: bloctoFlowTokenReceiver, ratio: digi96Ratio))
        }

        // NFT SaleCut
        if nftRatio > 0.0 {
            let nftFlowTokenReceiver = getAccount(nftRecipient).getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)
            assert(nftFlowTokenReceiver.borrow() != nil, message: "Missing or mis-typed NFT FlowToken receiver")
            requirements.append(Marketplace.SaleCutRequirement(receiver: nftFlowTokenReceiver, ratio: nftRatio))
        }

        admin.updateSaleCutRequirements(requirements, nftType: Type<@Sentimen.NFT>())
        admin.updateSaleCutRequirements(requirements, nftType: Type<@SentimenPack.NFT>())
    }
}