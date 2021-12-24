import SentimenAdmin from "./SentimenAdmin.cdc"
import ContractVersion from "./ContractVersion.cdc"

// Contract to hold Metadata for MotoGPCards. Metadata is accessed using the Card's cardID (not the Card's id)
//
pub contract SentimenMetadata: ContractVersion {

   pub fun getVersion():String {
       return "0.0.1"
   }

   pub struct Metadata {
       pub let sentimenId: UInt64
       pub let cardID: UInt64
       pub let name: String
       pub let description: String
       pub let imageUrl: String
       // data contains all 'other' metadata fields, e.g. videoUrl, team, etc
       //
       pub let data: {String: String} 
       init(_sentimenId:UInt64, _cardID:UInt64, _name:String, _description:String, _imageUrl:String, _data:{String:String}){
           pre {
                !_data.containsKey("name") : "data dictionary contains 'name' key"
                !_data.containsKey("description") : "data dictionary contains 'description' key"
                !_data.containsKey("imageUrl") : "data dictionary contains 'imageUrl' key"
           }
           self.sentimenId = _sentimenId
           self.cardID = _cardID
           self.name = _name
           self.description = _description
           self.imageUrl = _imageUrl
           self.data = _data
       }
   }

   //Dictionary to hold all metadata with cardID as key
   //
   access(self) let metadatas: {UInt64: SentimenMetadata.Metadata} 

   // Get all metadatas
   //
   pub fun getMetadatas(): {UInt64: SentimenMetadata.Metadata} {
       return self.metadatas;
   }

   pub fun getMetadatasCount(): UInt64 {
       return UInt64(self.metadatas.length)
   }

   //Get metadata for a specific cardID
   //
   pub fun getMetadataForSentimenNFT(sentimenId: UInt64): SentimenMetadata.Metadata? {
       return self.metadatas[sentimenId]
   }

   //Access to set metadata is controlled using an Admin reference as argument
   //
   pub fun setMetadata(adminRef: &SentimenAdmin.Admin, sentimenId: UInt64, cardID: UInt64, 
            name:String, description:String, imageUrl:String, data:{String: String}) {
       pre {
           adminRef != nil: "adminRef is nil"
       }
       let metadata = Metadata(_sentimenId:sentimenId, _cardID:cardID, _name:name, _description:description, _imageUrl:imageUrl, _data:data)
       self.metadatas[sentimenId] = metadata
   }

   //Remove metadata by sentimen id
   //
   pub fun removeMetadata(adminRef: &SentimenAdmin.Admin, sentimenId: UInt64) {
       pre {
           adminRef != nil: "adminRef is nil"
       }
       self.metadatas.remove(key: sentimenId)
   }
   
   init(){
        self.metadatas = {}
   }
        
}
