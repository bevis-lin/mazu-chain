import ContractVersion from "./ContractVersion.cdc"


pub contract SentimenMintRequest: ContractVersion {
  pub fun getVersion():String {
    return "0.0.1"
  }

  pub struct MintRequest {
    pub let requestId: UInt64
    pub let creator: Address
    pub let title: String
    pub let imageUrl: String
    pub let activity: String
    pub let price: UFix64

    init(_requestId:UInt64, _creator: Address, _title: String, _imageUrl: String, _activity: String, _price: UFix64){
      self.requestId = _requestId
      self.creator = _creator
      self.title = _title
      self.imageUrl = _imageUrl
      self.activity = _activity
      self.price = _price
    }
  }

  access(self) let mintRequests: {Address: [MintRequest]}

  pub fun getMintRequests(): {Address: [MintRequest]} {
    return self.mintRequests
  }

  pub fun getMintRequestsByAddress(address: Address): [MintRequest]? {
    return self.mintRequests[address]
  }

  pub fun addMintRequest(creator: Address, title: String, imageUrl: String, activity: String, price: UFix64 ) {
    let userRequests:[MintRequest]? = self.mintRequests[creator]
    let addressString:String = creator.toString()
    
    if(userRequests==nil){
      let newUserRequests:[MintRequest] = []
      let requestNew = MintRequest(_requestId: 1, _creator: creator, _title: title, _imageUrl: imageUrl, _activity: activity, _price: price)
      newUserRequests.append(requestNew)
      self.mintRequests[creator] = newUserRequests
    }else{
      var requestId = userRequests!.length+1
      let requestNew = MintRequest(_requestId: UInt64(requestId), _creator: creator, _title: title, _imageUrl: imageUrl, _activity: activity, _price: price)
      userRequests?.append(requestNew)
      self.mintRequests[creator] = userRequests
    }
  
  }

  init(){
    self.mintRequests = {}
  }



}