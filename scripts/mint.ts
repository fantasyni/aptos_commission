import {
    Account,
    AnyNumber,
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

const MODULE_ADDRESS = process.env.DEX_MODULE_ADDRESS || "";

async function mint_coin(admin: Account, receiver: Account, amount: AnyNumber): Promise<string> {
    const transaction = await aptos.transaction.build.simple({
        sender: admin.accountAddress,
        data: {
            function: `${MODULE_ADDRESS}::justin_coin::mint`,
            functionArguments: [receiver.accountAddress, amount],
        },
    });

    const senderAuthenticator = aptos.transaction.sign({ signer: admin, transaction });
    const pendingTxn = await aptos.transaction.submit.simple({ transaction, senderAuthenticator });

    return pendingTxn.hash;
}

async function main() {
    let key = PrivateKey.formatPrivateKey(process.env.APTOS_PRIVATE_KEY || "", PrivateKeyVariants.Ed25519)
    const privateKey = new Ed25519PrivateKey(key);

    const admin = Account.fromPrivateKey({ privateKey });

    let result = await mint_coin(admin, admin, 10000_0000);
    console.log(result)
}

main();