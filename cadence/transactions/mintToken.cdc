import NonFungibleToken from 0xf21fee1faa18dce2
import Sentimen from 0xf21fee1faa18dce2

// This script uses the NFTMinter resource to mint a new NFT
// It must be run with the account that has the minter resource
// stored in /storage/NFTMinter

transaction(recipient: Address) {

    // local variable for storing the minter reference
    let minter: &Sentimen.NFTMinter

    prepare(signer: AuthAccount) {
        log("mint token for address $recipient")

        // borrow a reference to the NFTMinter resource in storage
        self.minter = signer.borrow<&Sentimen.NFTMinter>(from: /storage/NFTMinter)
            ?? panic("Could not borrow a reference to the NFT minter")
    }

    execute {
        // Borrow the recipient's public NFT collection reference
        let receiver = getAccount(recipient)
            .getCapability(/public/sentimenCollection)
            .borrow<&{NonFungibleToken.CollectionPublic}>()
            ?? panic("Could not get receiver reference to the NFT Collection")

        // Mint the NFT and deposit it to the recipient's collection
        self.minter.mintNFT(recipient: receiver)
    }
}