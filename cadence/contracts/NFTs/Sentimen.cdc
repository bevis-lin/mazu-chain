import NonFungibleToken from "../NonFungibleToken.cdc"
import SentimenCounter from "./SentimenCounter.cdc"
import SentimenMetadata from "./SentimenMetadata.cdc"
//import SentimenAdmin from "./SentimenAdmin.cdc"
pub contract Sentimen: NonFungibleToken {

    pub let NFTMinterStoragePath: StoragePath
  
    pub fun getVersion(): String {
       return "0.0.1"
    }

   // The total number of Cards in existence
    pub var totalSupply: UInt64

    // Event that emitted when the MotoGPCard contract is initialized
    //
    pub event ContractInitialized()

    // Event that is emitted when a Card is withdrawn,
    // indicating the owner of the collection that it was withdrawn from.
    //
    // If the collection is not in an account's storage, `from` will be `nil`.
    //
    pub event Withdraw(id: UInt64, from: Address?)

    // Event that emitted when a Card is deposited to a collection.
    //
    // It indicates the owner of the collection that it was deposited to.
    //
    pub event Deposit(id: UInt64, to: Address?)


    pub event Mint(id: UInt64)

    pub event Burn(id: UInt64)

    // An array UInt128s that represents templateId + serial keys
    // This is primarily used to ensure there
    // are no duplicates when we mint a new Sentimen (NFT)
   access(account) var allCards: [UInt128]

  
    pub resource NFT: NonFungibleToken.INFT {

        // The siteId which distinguish different Sentimen sub branding
        pub let siteId: String

        // The Sentimen's Issue ID (completely sequential)
        pub let id: UInt64

        // The Sentimen's templated, which will be determined
        // once the pack is opened
        pub let templateId: UInt64

        // The card's Serial, which will also be determined
        // once the pack is opened
        pub let serial: UInt64

        // initializer
        //
        init(_siteId: String, _templateId: UInt64, _serial: UInt64) {
            let keyValue = UInt128(_templateId) + (UInt128(_serial) * (0x4000000000000000 as UInt128))
            if (Sentimen.allCards.contains(keyValue)) {
                panic("This templateId and serial combination already exists")
            }
            Sentimen.allCards.append(keyValue)

            self.siteId = _siteId

            self.templateId = _templateId

            self.serial = _serial

            self.id = SentimenCounter.increment(_siteId)

            Sentimen.totalSupply = Sentimen.totalSupply + (1 as UInt64)

            emit Mint(id: self.id)
        }

        pub fun getCardMetadata(): SentimenMetadata.Metadata? {
            return SentimenMetadata.getMetadataForSentimenNFT(sentimenId: self.id)
        }

        destroy(){
            Sentimen.totalSupply = Sentimen.totalSupply - (1 as UInt64)
            emit Burn(id: self.id)
        }
    }

    // createNFT
    // allows us to create an NFT from another contract in this
    // account because we want to be able to mint NFTs
    // in MotoGPPack
    //
    access(account) fun createNFT(siteId:String, templateId: UInt64, serial: UInt64): @NFT {
        return <- create NFT(_siteId: siteId, _templateId: templateId, _serial: serial)
    }

    // ICardCollectionPublic
    // Defines an interface that specifies
    // what fields and functions 
    // we want to expose to the public.
    //
    // Allows users to deposit Cards, read all the Card IDs,
    // borrow a NFT reference to access a Card's ID,
    // deposit a batch of Cards, and borrow a Card reference
    // to access all of the Card's fields.
    //
    pub resource interface ICardCollectionPublic {
        pub fun deposit(token: @NonFungibleToken.NFT)
        pub fun getIDs(): [UInt64]
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT

        pub fun depositBatch(cardCollection: @NonFungibleToken.Collection)
        pub fun borrowCard(id: UInt64): &Sentimen.NFT? {
            // If the result isn't nil, the id of the returned reference
            // should be the same as the argument to the function
            post {
                (result == nil) || (result?.id == id): 
                    "Cannot borrow Card reference: The ID of the returned reference is incorrect"
            }
        }
    }

    // Collection
    // This resource defines a collection of Cards
    // that a user will have. We must give each user
    // this collection so they can
    // interact with Cards.
    //
    pub resource Collection: NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, ICardCollectionPublic {
        // A dictionary that maps a Card's id to a 
        // Card in the collection. It holds all the 
        // Cards in a collection.
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        // deposit
        // deposits a Card into the Collection
        //
        pub fun deposit(token: @NonFungibleToken.NFT) {
            let token <- token as! @Sentimen.NFT

            let id: UInt64 = token.id

            // add the new Card to the dictionary which removes the old one
            let oldToken <- self.ownedNFTs[id] <- token

            // Only emit a deposit event if the Collection 
            // is in an account's storage
            if self.owner?.address != nil {
                emit Deposit(id: id, to: self.owner?.address)
            }

            destroy oldToken
        }

        // depositBatch
        // This method deposits a collection of Cards into the
        // user's Collection.
        //
        // This is primarily called by an Admin to
        // deposit newly minted Cards into this Collection.
        //
        pub fun depositBatch(cardCollection: @NonFungibleToken.Collection) {
            pre {
                cardCollection.getIDs().length <= 100:
                    "Too many cards being deposited. Must be less than or equal to 100"
            }

            // Get an array of the IDs to be deposited
            let keys = cardCollection.getIDs()

            // Iterate through the keys in the collection and deposit each one
            for key in keys {
                self.deposit(token: <-cardCollection.withdraw(withdrawID: key))
            }

            // Destroy the empty Collection
            destroy cardCollection
        }

        // withdraw
        // withdraw removes a Card from the collection and moves it to the caller
        //
        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("missing NFT")

            emit Withdraw(id: token.id, from: self.owner?.address)

            return <-token
        }

        // getIDs
        // returns the ids of all the Card this
        // collection has
        // 
        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        // borrowNFT
        // borrowNFT gets a reference to an NFT in the collection
        // so that the caller can read its id field
        //
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return &self.ownedNFTs[id] as &NonFungibleToken.NFT
        }

        // borrowCard
        // borrowCard returns a borrowed reference to a Card
        // so that the caller can read data from it.
        // They can use this to read its id, sentimenId, and serial
        //
        pub fun borrowCard(id: UInt64): &Sentimen.NFT? {
            if self.ownedNFTs[id] != nil {
                let ref = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
                return ref as! &Sentimen.NFT
            } else {
                return nil
            }
        }

        destroy() {
            destroy self.ownedNFTs
        }

        init () {
            self.ownedNFTs <- {}
        }
    }

    // createEmptyCollection
    // creates a new Collection resource and returns it.
    // This will primarily be used to give a user a new Collection
    // so they can store Cards
    //
    pub fun createEmptyCollection(): @Collection {
        return <- create Collection()
    }

    // Resource that an admin or something similar would own to be
    // able to mint new NFTs
    //
    pub resource NFTMinter {

        // mintNFT mints a new NFT with a new ID
        // and deposit it in the recipients collection using their collection reference
        pub fun mintNFT(recipient: &{NonFungibleToken.CollectionPublic}, 
        siteId: String, templateId: UInt64, serialNumber: UInt64): UInt64 {

            log("new mint sentimen before supply count:".concat(Sentimen.totalSupply.toString()))
            
            // create a new NFT
            var newNFT <- create NFT(_siteId: siteId, _templateId: templateId, _serial: serialNumber)

            let newNFTId = newNFT.id

            // deposit it in the recipient's account using their reference
            recipient.deposit(token: <-newNFT)

            //Sentimen.totalSupply = Sentimen.totalSupply + UInt64(1)
             log("new mint sentimen after supply count:".concat(Sentimen.totalSupply.toString()))

             return newNFTId
           
        }
    }

    init() {
        self.totalSupply = 0
        self.allCards = []
        self.NFTMinterStoragePath = /storage/NFTMinter
        self.account.save<@NFTMinter>(<- create NFTMinter(), to: self.NFTMinterStoragePath)
        emit ContractInitialized()
    }
   

}