import SentimenAdmin from "../contracts/NFTs/SentimenAdmin.cdc"
import SentimenMetadata from 0xf21fee1faa18dce2


transaction(templateId: UInt64, name: String, description:String, imageUrl:String, data:{String:String}){

    let adminRef: &SentimenAdmin.Admin

    prepare(signer: AuthAccount) {
        self.adminRef = signer.borrow<&SentimenAdmin.Admin>(from: /storage/sentimenAdmin)?? panic("Could not borrow a reference to the SentimenAdmin")
    }

    execute {
        SentimenMetadata.setMetadata(adminRef: self.adminRef,templateId: templateId,name: name,description: description,imageUrl: imageUrl,data: data)
    }

}