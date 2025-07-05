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

async function admin_modify_source_level(sender: Account, source: string, level: number) {
    const transaction = await aptos.transaction.build.simple({
        sender: sender.accountAddress,
        data: {
            function: `${MODULE_ADDRESS}::admin::modify_source_level`,
            functionArguments: [source, level],
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

    let source = "deepapt2";
    let level = 2;

    let result = await admin_modify_source_level(admin, source, level);
    console.log(result)
}

main();