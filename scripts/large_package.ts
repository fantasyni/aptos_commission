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

function getByteCode(file_path: string) {
    return "0x" + Buffer.from(fs.readFileSync(file_path)).toString("hex");
}

function get_build_dir() {
    let cwd = process.cwd();

    let build_path = `${cwd}/build`;
    let build_dirs = fs.readdirSync(build_path);
    let build_dir = build_dirs[0];
    return `${build_path}/${build_dir}`;
}

// Set up the client
const APTOS_NETWORK: Network = NetworkToNetworkName[process.env.APTOS_NETWORK ?? Network.TESTNET];
const config = new AptosConfig({ network: APTOS_NETWORK });
const aptos = new Aptos(config);

async function do_large_package(sender: Account, metadata_chunk: string, code_indices: number[], code_chunks: string[]) {
    console.log(code_indices)
    console.log(code_chunks)
    const transaction = await aptos.transaction.build.simple({
        sender: sender.accountAddress,
        data: {
            function: `0xe1ca3011bdd07246d4d16d909dbb2d6953a86c4735d5acf5865d962c630cce7::large_packages::stage_code_chunk_and_publish_to_account`,
            functionArguments: [metadata_chunk, code_indices, code_chunks],
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

    let build_path = get_build_dir();
    let metadata_chunk = getByteCode(`${build_path}/package-metadata.bcs`);
    let code_indices = [];
    let code_chunks = [];

    let bytecodes_dir = `${build_path}/bytecode_modules`;
    let files = fs.readdirSync(bytecodes_dir);

    let index = 0;
    for (var i = 0; i < files.length; i++) {
        let file = files[i];
        let file_path = `${bytecodes_dir}/${file}`;
        if (file.endsWith('.mv')) {
            code_indices.push(index++);
            let code = getByteCode(file_path);
            code_chunks.push(code)
        }
    }

    await do_large_package(admin, metadata_chunk, code_indices, code_chunks);
    // console.log(result)
}

main();