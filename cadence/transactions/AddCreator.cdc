import SentimenAdmin from "../contracts/NFTs/SentimenAdmin.cdc"
import SentimenCreator from "../contracts/NFTs/SentimenCreator.cdc"
//import SentimenMetadata from 0xf21fee1faa18dce2


transaction(address: Address, name: String, email:String, profileUrl:String, data:{String:String}){

    let adminRef: &SentimenAdmin.Admin

    prepare(signer: AuthAccount) {
        self.adminRef = signer.borrow<&SentimenAdmin.Admin>(from: /storage/sentimenAdmin)?? panic("Could not borrow a reference to the SentimenAdmin")
    }

    execute {
        //SentimenMetadata.setMetadata(adminRef: self.adminRef,cardID: cardID,name: name,description: description,imageUrl: imageUrl,data: data)
        SentimenCreator.setCreator(adminRef: self.adminRef, address:address, name:name, email:email, profileUrl:profileUrl, data:data)
    }

}