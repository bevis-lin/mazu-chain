//import SentimenMintRequest from "../contracts/NFTs/SentimenMintRequest.cdc" //emulator
import SentimenMintRequest from 0x78e84183b7e33d61 //testnet

pub fun main() : {UInt64: SentimenMintRequest.MintRequest} {
  return SentimenMintRequest.getAllRequests()
}