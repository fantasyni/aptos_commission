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

import fs from "fs";

import dotenv from 'dotenv'
dotenv.config()

// Set up the client
const APTOS_NETWORK: Network = NetworkToNetworkName[process.env.APTOS_NETWORK ?? Network.TESTNET];
const config = new AptosConfig({ network: APTOS_NETWORK });
const aptos = new Aptos(config);

async function do_large_package(sender: Account, payload: any) {
    const transaction = await aptos.transaction.build.simple({
        sender: sender.accountAddress,
        data: payload
    });

    const senderAuthenticator = aptos.transaction.sign({ signer: sender, transaction });
    const pendingTxn = await aptos.transaction.submit.simple({ transaction, senderAuthenticator });
    console.log(pendingTxn)
}

async function main() {
    let key = PrivateKey.formatPrivateKey(process.env.APTOS_PRIVATE_KEY || "", PrivateKeyVariants.Ed25519)
    const privateKey = new Ed25519PrivateKey(key);

    const admin = Account.fromPrivateKey({ privateKey });

    let payload_str = fs.readFileSync("payload_1.json").toString();
    let payload = JSON.parse(payload_str);

    console.log(payload)

    let args: any = [];

    for (var i = 0; i < payload.args.length; i++) {
        let arg = payload.args[i];
        args.push(arg.value);
    }

    let new_payload = {
        function: payload.function_id,
        typeArguments: payload.type_args,
        functionArguments: args
    }
    await do_large_package(admin, new_payload);
    // console.log(result)
}

main();