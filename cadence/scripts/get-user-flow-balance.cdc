import FungibleToken from 0x9a0766d93b6608b7
import FlowToken from 0x7e60df042a9c0868


pub fun main(address:Address) : UFix64? {
  let account = getAccount(address)      
  let vaultCapability = account.getCapability<&FlowToken.Vault{FungibleToken.Balance}>(/public/flowTokenBalance)!
  assert(vaultCapability.borrow() != nil, message: "Can't get FungibleToken balance")

  let vaultRef = vaultCapability.borrow() ?? panic("Can't get FungibleToken balance")

  return vaultRef.balance

}