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


// Set up the client
const APTOS_NETWORK: Network = NetworkToNetworkName[process.env.APTOS_NETWORK ?? Network.TESTNET];
const config = new AptosConfig({ network: APTOS_NETWORK });
const aptos = new Aptos(config);

const MODULE_ADDRESS = process.env.MODULE_ADDRESS || "";

async function user_register(sender: Account, source: string, commission_address: string): Promise<string> {
    const transaction = await aptos.transaction.build.simple({
        sender: sender.accountAddress,
        data: {
            function: `${MODULE_ADDRESS}::user::register`,
            functionArguments: [source, commission_address],
        },
    });

    const senderAuthenticator = aptos.transaction.sign({ signer: sender, transaction });
    const pendingTxn = await aptos.transaction.submit.simple({ transaction, senderAuthenticator });

    return pendingTxn.hash;
}

async function main() {
    let key = PrivateKey.formatPrivateKey(process.env.USER_PRIVATE_KEY || "", PrivateKeyVariants.Ed25519)
    const privateKey = new Ed25519PrivateKey(key);

    const user = Account.fromPrivateKey({ privateKey });

    let source = "deepapt2";
    let commission_address = "0xfdfd5f37786e5ca47511928565d51bbf05a61c91412a1ec6bdce05eaff7af065";

    let r = await user_register(user, source, commission_address);

    console.log(r)
}

main();