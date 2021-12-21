import SentimenMintRequest from "../contracts/NFTs/SentimenMintRequest.cdc"

transaction(title:String, imageUrl:String, activity:String, price:UFix64) {

  let creator: Address

  prepare(signer:AuthAccount){
    self.creator = signer.address
  }

  execute{
    SentimenMintRequest.addMintRequest(creator: self.creator, title: title,
    imageUrl:imageUrl,activity:activity,price:price)
  }

}