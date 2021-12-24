import ContractVersion from "./ContractVersion.cdc"
import SentimenCreator from "./SentimenCreator.cdc"

pub contract SentimenTemplate: ContractVersion {
  pub fun getVersion(): String {
    return "0.0.1"
  }

  pub struct Template {
    pub let templateId: UInt64
    pub let siteId: String
    pub let creator: Address
    pub let name: String
    pub let description: String
    pub let imageUrl: String
    pub let data: {String: String}
    pub let totalSupply: UInt64
    pub var totalMinted: UInt64
    
    init(_templateId:UInt64, _siteId:String, _creator: Address, 
    _name:String, _description:String,
    _imageUrl:String,_data:{String:String}, 
    _totalSupply:UInt64) {
      self.templateId = _templateId
      self.siteId = _siteId
      self.creator = _creator
      self.name = _name
      self.description = _description
      self.imageUrl = _imageUrl
      self.data = _data
      self.totalSupply = _totalSupply
      self.totalMinted = 0
    }

    access(contract) fun increaseTotalMinted(){
      self.totalMinted = self.totalMinted + UInt64(1)
    }
  }

  //access(self) let templateTotalMinted: {UInt64: UInt64}
  access(self) let creatorTemplates: {Address: [UInt64]}
  access(self) let templates: {UInt64: SentimenTemplate.Template}

  // pub fun getTotalMinted(templateId:UInt64): UInt64?{
  //   return self.templates[templateId].totalMinted
  // }

  pub fun getTemplatesByCreator(address: Address): [UInt64]? {
    return self.creatorTemplates[address]
  }

  pub fun getTemplateById(templateId: UInt64): SentimenTemplate.Template? {
    return self.templates[templateId]
  }

  pub fun getAllTemplates(): {UInt64: SentimenTemplate.Template} {
    return self.templates
  }

  pub fun addTemplate(siteId: String, creator:Address, name:String, description:String, imageUrl:String, data:{String:String}, totalSupploy:UInt64) {
    
    let sentimenCreator = SentimenCreator.getCreatorProfleByAddress(address: creator)
    if(sentimenCreator == nil){
      panic("Creator does not exist")
    }

    let userTemplates:[UInt64]? = self.creatorTemplates[creator]
    var newTemplateId = self.templates.length+1
    let templateNew = Template(_templateId: UInt64(newTemplateId), _siteId: siteId, 
    _creator: creator, _name: name, _description: description, _imageUrl: imageUrl, 
    _data: data, _totalSupply: totalSupploy)

    if(userTemplates==nil){
      let newUserTemplates:[UInt64] = []
      newUserTemplates.append(UInt64(newTemplateId))
      self.creatorTemplates[creator] = newUserTemplates  
    }else{
      userTemplates?.append(UInt64(newTemplateId))
      self.creatorTemplates[creator] = userTemplates
    }

    self.templates[UInt64(newTemplateId)] = templateNew
    

  }

  pub fun increaseTemplateTotalMinted(templateId: UInt64){
      self.templates[templateId]!.increaseTotalMinted()
  }

  

  init(){
    self.creatorTemplates = {}
    self.templates = {}
  }
}