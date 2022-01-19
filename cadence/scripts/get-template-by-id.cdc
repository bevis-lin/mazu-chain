import SentimenTemplate from 0x2ebc7543c6a3f855

pub fun main(templateId: UInt64): SentimenTemplate.Template? {
  return SentimenTemplate.getTemplateById(templateId:templateId)
}