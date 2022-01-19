import SentimenAdmin from "../contracts/NFTs/SentimenAdmin.cdc"
import SentimenMetadata from "../contracts/NFTs/SentimenMetadata.cdc"

transaction(templateId: UInt64) {

  let adminRef: &SentimenAdmin.Admin

    prepare(signer: AuthAccount) {
        self.adminRef = signer.borrow<&SentimenAdmin.Admin>(from: /storage/sentimenAdmin)?? panic("Could not borrow a reference to the SentimenAdmin")
    }

    execute {
      SentimenMetadata.removeMetadata(adminRef: self.adminRef, templateId: templateId)
    }

}