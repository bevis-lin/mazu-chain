import ContractVersion from "./ContractVersion.cdc"
import NonFungibleToken from "../NonFungibleToken.cdc"
import Sentimen from "./Sentimen.cdc"
import SentimenTemplate from "./SentimenTemplate.cdc"
import SentimenPack from "./SentimenPack.cdc"
import SentimenAdmin from "./SentimenAdmin.cdc"
import SentimenMetadata from "./SentimenMetadata.cdc"

pub contract SentimenMintRequest: ContractVersion {
  pub fun getVersion():String {
    return "0.0.1"
  }

  pub struct MintRequest {
    pub let requestId: UInt64
    pub let creator: Address
    pub let templateId: UInt64
    pub let price: UFix64
    pub var completed: Bool

    init(_requestId:UInt64, _creator: Address, _templateId: UInt64, _price: UFix64){
      self.requestId = _requestId
      self.creator = _creator
      self.templateId = _templateId
      self.price = _price
      self.completed = false
    }

    access(contract) fun setToCompleted() {
            self.completed = true
        }
  }

  access(self) let creatorMintRequests: {Address: [UInt64]}
  access(self) let mintRequests: {UInt64: MintRequest}

  pub fun getAllRequests(): {UInt64: MintRequest} {
    return self.mintRequests
  }

  // pub fun getRequestsByCreator(address: Address): [UInt64]? {
  //   return self.creatorMintRequests[address]
  // }

  pub fun getRequestsByCreator(address: Address): [MintRequest] {
    let testMintRequests: [MintRequest] = []

    if let requestIds = self.creatorMintRequests[address]
    {
      for id in requestIds {
        if let request = self.mintRequests[UInt64(id)] {
          testMintRequests.append(request)
        }
      }
    }
    
    return testMintRequests
  }


  pub fun addRequest(creator: Address, templateId: UInt64, price: UFix64 ) {

    //check if template exists or not
    let template = SentimenTemplate.getTemplateById(templateId: templateId)
    if(template==nil){
      panic("Template does not exist")
    }

    let userRequests:[UInt64]? = self.creatorMintRequests[creator]
    let addressString:String = creator.toString()
    let newRequestId = self.mintRequests.length+1
    let requestNew = MintRequest(_requestId: UInt64(newRequestId), _creator: creator, _templateId: templateId, _price: price)
      
    if(userRequests==nil){
      let newUserRequests:[UInt64] = []
      newUserRequests.append(UInt64(newRequestId))
      self.creatorMintRequests[creator] = newUserRequests
    }else{
      userRequests?.append(UInt64(newRequestId))
      self.creatorMintRequests[creator] = userRequests
    }

    self.mintRequests[UInt64(newRequestId)] = requestNew
  
  }

  pub fun approveMintRequest(adminRef: &SentimenAdmin.Admin, minter: &Sentimen.NFTMinter, mintRequestId:UInt64) {
            pre {
                adminRef !=nil: "adminRef is nil"
                minter !=nil: "minter is nil"
            }

            //let allMintRequests:{UInt64: SentimenMintRequest.MintRequest} = SentimenMintRequest.getAllRequests()
                
            if(self.mintRequests[mintRequestId] == nil)
            {
                panic("This mint request id doest not exist!")
            }
            
            let mintRequest:SentimenMintRequest.MintRequest? = self.mintRequests[mintRequestId]
            if mintRequest!.completed == true {
              panic("This mint request has been completed")
            }

            let receiver = getAccount(mintRequest!.creator)
            .getCapability(/public/sentimenCollection)
            .borrow<&{NonFungibleToken.CollectionPublic}>()
            ?? panic("Could not get receiver reference to the NFT Collection")

            let template = SentimenTemplate.getTemplateById(templateId:mintRequest!.templateId)
            let currentTotalMinted = template!.totalMinted
            var updatedTotalMintedNumber: UInt64 = 1
            if(currentTotalMinted != 0){
              updatedTotalMintedNumber = currentTotalMinted! + UInt64(1)
            }
          
            SentimenTemplate.increaseTemplateTotalMinted(templateId:template!.templateId)
            
            // Mint the NFT and deposit it to the recipient's collection
            let newSentimenId = minter.mintNFT(recipient: receiver, siteId: template!.siteId,
             templateId: mintRequest!.templateId, serialNumber: updatedTotalMintedNumber)
            
            var newSentimenCardID:UInt64 = 0
            if(Sentimen.totalSupply == 0)
            {
              newSentimenCardID = 1
            }else{
              newSentimenCardID = Sentimen.totalSupply
            }

            
            // Create metadata
            let newSentimenName = template!.name.concat(" #".concat(updatedTotalMintedNumber.toString()))
            
            SentimenMetadata.setMetadata(adminRef: adminRef, sentimenId: newSentimenId,
                cardID: UInt64(newSentimenCardID),
                name: newSentimenName, description: template!.description,
                imageUrl: template!.imageUrl,data: template!.data)

            //close the request
            mintRequest!.setToCompleted()
            //self.mintRequests[mintRequestId] = mintRequest
            self.mintRequests[mintRequestId]!.setToCompleted()
            
            
  }

  init(){
    self.mintRequests = {}
    self.creatorMintRequests = {}
  }



}