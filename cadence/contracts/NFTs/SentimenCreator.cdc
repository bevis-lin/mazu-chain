import SentimenAdmin from "./SentimenAdmin.cdc"
import ContractVersion from "./ContractVersion.cdc"

pub contract SentimenCreator: ContractVersion {
  pub fun getVersion():String {
    return "0.0.1"
  }

  pub struct Creator {
    pub let address: Address
    pub let name: String
    pub let email: String
    pub let profileUrl: String


    pub let data:{String:String}
    init(_address:Address,_name:String,_email:String,_profileUrl:String, _data:{String:String}){
      self.address=_address
      self.name = _name
      self.email = _email
      self.profileUrl = _profileUrl
      self.data = _data
    }
  }

  access(self) let creators: {Address: SentimenCreator.Creator}

  pub fun getCreators(): {Address: SentimenCreator.Creator} {
    return self.creators;
  }

  pub fun getCreatorsCount(): UInt64 {
    return UInt64(self.creators.length)
  }

  pub fun getCreatorProfleByAddress(address: Address): SentimenCreator.Creator? {
    return self.creators[address]
  }

  pub fun setCreator(adminRef: &SentimenAdmin.Admin, address:Address, name:String, email:String, profileUrl:String, data:{String:String}){
    pre{
      adminRef !=nil: "adminRef is nil"
    }
    let creatorProifle = Creator(_address:address, _name:name, _email:email, _profileUrl:profileUrl,_data:data)
    self.creators[address] = creatorProifle
  }

  pub fun checkIsCreator(address:Address): Bool {
    return self.creators[address]!=nil
  }

  init(){
    self.creators = {}
  }


}