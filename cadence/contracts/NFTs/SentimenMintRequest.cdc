import ContractVersion from "./ContractVersion.cdc"
import NonFungibleToken from "../NonFungibleToken.cdc"
import Sentimen from "./Sentimen.cdc"
import SentimenTemplate from "./SentimenTemplate.cdc"
import SentimenPack from "./SentimenPack.cdc"
//import SentimenMintRequest from "./SentimenMintRequest.cdc"
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

    init(_requestId:UInt64, _creator: Address, _templateId: UInt64, _price: UFix64){
      self.requestId = _requestId
      self.creator = _creator
      self.templateId = _templateId
      self.price = _price
    }
  }

  access(self) let creatorMintRequests: {Address: [MintRequest]}
  access(self) let mintRequests: {UInt64: MintRequest}

  pub fun getAllRequests(): {UInt64: MintRequest} {
    return self.mintRequests
  }

  pub fun getRequestsByCreator(address: Address): [MintRequest]? {
    return self.creatorMintRequests[address]
  }

  pub fun addRequest(creator: Address, templateId: UInt64, price: UFix64 ) {

    //check if template exists or not
    let template = SentimenTemplate.getTemplateById(templateId: templateId)
    if(template==nil){
      panic("Template does not exist")
    }

    let userRequests:[MintRequest]? = self.creatorMintRequests[creator]
    let addressString:String = creator.toString()
    let newRequestId = self.mintRequests.length+1
    if(userRequests==nil){
      let newUserRequests:[MintRequest] = []
      let requestNew = MintRequest(_requestId: UInt64(newRequestId), _creator: creator, _templateId: templateId, _price: price)
      newUserRequests.append(requestNew)
      self.creatorMintRequests[creator] = newUserRequests
    }else{
      let requestNew = MintRequest(_requestId: UInt64(newRequestId), _creator: creator, _templateId: templateId, _price: price)
      userRequests?.append(requestNew)
      self.creatorMintRequests[creator] = userRequests
    }
  
  }

  pub fun approveMintRequest(adminRef: &SentimenAdmin.Admin, minter: &Sentimen.NFTMinter, mintRequestId:UInt64) {
            pre {
                adminRef !=nil: "adminRef is nil"
                minter !=nil: "minter is nil"
            }

            let allMintRequests:{UInt64: SentimenMintRequest.MintRequest} = SentimenMintRequest.getAllRequests()
                
            if(allMintRequests[mintRequestId] !=nil)
            {
                panic("This mint request id doest not exist!")
            }
            
            let mintRequest:SentimenMintRequest.MintRequest? = allMintRequests[mintRequestId]
            let receiver = getAccount(mintRequest!.creator)
            .getCapability(/public/sentimenCollection)
            .borrow<&{NonFungibleToken.CollectionPublic}>()
            ?? panic("Could not get receiver reference to the NFT Collection")

            let newSentimenID = Sentimen.totalSupply
            // Mint the NFT and deposit it to the recipient's collection
            minter.mintNFT(recipient: receiver)

            let template = SentimenTemplate.getTemplateById(templateId:mintRequest!.templateId)

            // Create metadata
            let updatedTotalMintedNumber = SentimenTemplate.getTotalMinted(templateId:template!.templateId)! + UInt64(1)
            let newSentimenName = template!.name.concat(" #".concat(updatedTotalMintedNumber.toString()))
            

            SentimenMetadata.setMetadata(adminRef: adminRef,cardID: newSentimenID,
                name: newSentimenName, description: template!.description,
                imageUrl: template!.imageUrl,data: template!.data)

  }

  init(){
    self.mintRequests = {}
    self.creatorMintRequests = {}
  }



}