import fs from "fs";

let cwd = process.cwd();

function go() {
    console.log("run packages");
    console.log(cwd);
    console.log("1111111111")
    console.log(process.env.NODE_AUTH_TOKEN)
    fs.copyFileSync(`${cwd}/ghscripts/package.json`, `${cwd}/build/aptos_commission/package.json`);
    fs.copyFileSync(`${cwd}/ghscripts/.npmrc`, `${cwd}/build/aptos_commission/.npmrc`);
}

go();