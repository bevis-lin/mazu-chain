import ContractVersion from "./ContractVersion.cdc"

pub contract SentimenTemplate: ContractVersion {
  pub fun getVersion(): String {
    return "0.0.1"
  }

  pub struct Template {
    pub let templateId: UInt64
    pub let creator: Address
    pub let name: String
    pub let description: String
    pub let imageUrl: String
    pub let data: {String: String}
    pub let totalSupply: UInt64
    
    init(_templateId:UInt64, _creator: Address, 
    _name:String, _description:String,
    _imageUrl:String,_data:{String:String}, 
    _totalSupply:UInt64) {
      self.templateId = _templateId
      self.creator = _creator
      self.name = _name
      self.description = _description
      self.imageUrl = _imageUrl
      self.data = _data
      self.totalSupply = _totalSupply
    }
  }

  access(self) let templateTotalMinted: {UInt64: UInt64}
  access(self) let creatorTemplates: {Address: [SentimenTemplate.Template]}
  access(self) let templates: {UInt64: SentimenTemplate.Template}

  pub fun getTotalMinted(templateId:UInt64): UInt64?{
    return self.templateTotalMinted[templateId]
  }

  pub fun getTemplatesByCreator(address: Address): [Template]? {
    return self.creatorTemplates[address]
  }

  pub fun getTemplateById(templateId: UInt64): SentimenTemplate.Template? {
    return self.templates[templateId]
  }

  pub fun addTemplate(creator:Address, name:String, description:String, imageUrl:String, data:{String:String}, totalSupploy:UInt64) {
    let userTemplates:[Template]? = self.creatorTemplates[creator]
    var newTemplateId = self.templates.length+1
    let templateNew = Template(_templateId: UInt64(newTemplateId), _creator: creator, _name: name,
    _description: description, _imageUrl: imageUrl, _data: data, _totalSupply: totalSupploy)

    self.templates[UInt64(newTemplateId)] = templateNew
    userTemplates?.append(templateNew)
    self.creatorTemplates[creator] = userTemplates

  }

  

  init(){
    self.templateTotalMinted = {}
    self.creatorTemplates = {}
    self.templates = {}
  }
}