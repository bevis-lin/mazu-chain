//import SentimenAdmin from "../contracts/NFTs/SentimenAdmin.cdc"
//import SentimenCreator from "../contracts/NFTs/SentimenCreator.cdc"
import SentimenAdmin from 0x2ebc7543c6a3f855
import SentimenCreator from 0x2ebc7543c6a3f855


transaction(address: Address, name: String, email:String, profileUrl:String, data:{String:String}){

    let adminRef: &SentimenAdmin.Admin

    prepare(signer: AuthAccount) {
        self.adminRef = signer.borrow<&SentimenAdmin.Admin>(from: /storage/sentimenAdmin)?? panic("Could not borrow a reference to the SentimenAdmin")
    }

    execute {
        SentimenCreator.setCreator(adminRef: self.adminRef, address:address, name:name, email:email, profileUrl:profileUrl, data:data)
    }

}