import fs from "fs";

let cwd = process.cwd();

function go() {
    console.log("run packages");
    console.log(cwd);
    fs.copyFileSync(`${cwd}/ghscripts/package.json`, `${cwd}/build/aptos_commission/package.json`);
}

go();