#flow emulator -v --config-path ./flow.json
flow project deploy —network=emulator
flow accounts create --key a246f632ca6e4e59c83d73b0bd8af07057a937af251d382c4b5f5654d5c290a6fdb0e0278e35b5705244c252a460d10f3aa43f4b5e0960575d8b52953c354844 --signer emulator-account
flow transactions send ./cadence/transactions/setupAccount.cdc --signer=emulator-account-user1
flow transactions send ./cadence/transactions/mintToken.cdc "0x01cf0e2f2f715450"
flow transactions send ./cadence/transactions/CreateMetadata.cdc 1 "白沙屯媽祖" "信徒跟隨媽祖的轎子前進" "https://mook-aws.hmgcdn.com/images/upload/article/11587/A11587_1432106005_1.jpg" "{\"activity\":\"白沙屯\",\"creator\":\"kunyilin\"}" --signer=emulator-account
flow transactions send ./cadence/transactions/updateSaleCutSentimen.cdc --signer=emulator-account
flow transactions send ./cadence/transactions/sellItem.cdc --arg="UInt64:1,UFix64:2.00,UInt:1" --signer=emulator-account-user1