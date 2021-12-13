import FungibleToken from 0x9a0766d93b6608b7
import Marketplace from 0xf21fee1faa18dce2
import FlowToken from 0x7e60df042a9c0868
import Sentimen from 0xf21fee1faa18dce2
import SentimenPack from 0xf21fee1faa18dce2

// This transaction creates SaleCutRequirements of Marketplace for NFT & Digi96

transaction {

    prepare(signer: AuthAccount) {
        let digi96Recipient: Address = 0xf21fee1faa18dce2
        let digi96Ratio = 0.025 // 2.5%
        let nftRecipient: Address = 0xee3832caa4548467
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