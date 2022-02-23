import SentimenMintRequest from 0x2ebc7543c6a3f855 

pub fun main(requestId: UInt64): SentimenMintRequest.MintRequest? {
  return SentimenMintRequest.getRequestById(reqId: requestId)
}