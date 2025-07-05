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

async function do_large_package(sender: Account) {
    const transaction = await aptos.transaction.build.simple({
        sender: sender.accountAddress,
        data: {
            function: `0xe1ca3011bdd07246d4d16d909dbb2d6953a86c4735d5acf5865d962c630cce7::large_packages::cleanup_staging_area`,
            functionArguments: [],
        },
    });

    const senderAuthenticator = aptos.transaction.sign({ signer: sender, transaction });
    const pendingTxn = await aptos.transaction.submit.simple({ transaction, senderAuthenticator });
    // const [userTransactionResponse] = await aptos.transaction.simulate.simple({ transaction, signerPublicKey: sender.publicKey })
    // console.log(userTransactionResponse);
    console.log(pendingTxn)

    // return pendingTxn.hash;
}

async function main() {
    let key = PrivateKey.formatPrivateKey(process.env.APTOS_PRIVATE_KEY || "", PrivateKeyVariants.Ed25519)
    const privateKey = new Ed25519PrivateKey(key);

    const admin = Account.fromPrivateKey({ privateKey });

    await do_large_package(admin);
    // console.log(result)
}

main();