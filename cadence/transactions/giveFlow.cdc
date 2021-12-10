import FungibleToken from 0xee82856bf20e2aa6
import NonFungibleToken from "../contracts/NonFungibleToken.cdc"
import FlowToken from 0x0ae53cb6e3f42a79

transaction(targetAddress: Address, givePrice: UFix64) {
    let flowTokenVault: &FlowToken.Vault
    let flowTokenVaultReceiver: &{FungibleToken.Receiver}

    prepare(signer: AuthAccount) {
       
       let targetAccount = getAccount(targetAddress)

        self.flowTokenVault = signer.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
            ?? panic("Cannot borrow FlowToken vault from signer storage")
       
        let receiverCapability = targetAccount.getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)!
        assert(receiverCapability.borrow() != nil, message: "Can't get FungibleToken receiver")

        self.flowTokenVaultReceiver = receiverCapability.borrow()
           ?? panic("Can not get receiver vault")

        
    }

    execute {
        let paymentVault <- self.flowTokenVault.withdraw(amount: givePrice)
        
        self.flowTokenVaultReceiver.deposit(from: <-paymentVault)
    }

}
