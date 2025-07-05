import {
    Account,
    Aptos,
    AptosConfig,
    Ed25519PrivateKey,
    Network,
    NetworkToNetworkName,
    PrivateKey,
    PrivateKeyVariants,
} from "@aptos-labs/ts-sdk";

import dotenv from 'dotenv'
dotenv.config()

const APTOS_NETWORK: Network = NetworkToNetworkName[process.env.APTOS_NETWORK ?? Network.TESTNET];
const config = new AptosConfig({ network: APTOS_NETWORK });
const aptos = new Aptos(config);

const MODULE_ADDRESS = process.env.DEX_MODULE_ADDRESS || "";

async function do_swap(sender: Account, user_address: string, fa_address: string, fa_amount: number) {
    const transaction = await aptos.transaction.build.simple({
        sender: sender.accountAddress,
        data: {
            function: `${MODULE_ADDRESS}::dex::do_swap`,
            functionArguments: [user_address, fa_address, fa_amount],
        },
    });

    const senderAuthenticator = aptos.transaction.sign({ signer: sender, transaction });
    const pendingTxn = await aptos.transaction.submit.simple({ transaction, senderAuthenticator });

    return pendingTxn.hash;
}

async function main() {
    let key = PrivateKey.formatPrivateKey(process.env.APTOS_PRIVATE_KEY || "", PrivateKeyVariants.Ed25519)
    const privateKey = new Ed25519PrivateKey(key);

    const admin = Account.fromPrivateKey({ privateKey });

    let user_address = "0xfdfd5f37786e5ca47511928565d51bbf05a61c91412a1ec6bdce05eaff7af065";
    // user_address = "0xe488be1325a0a2438aac3d347a8378cf03916a4d59d965365832900516365cab";
    let fa_address = process.env.FA_ADDRESS || "";
    let fa_amount = 10000;

    let result = await do_swap(admin, user_address, fa_address, fa_amount);
    console.log(result)
}

main();