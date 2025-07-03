import fs from "fs";

function go() {
    console.log("run packages");
    fs.copyFileSync("./package.json", "../build/aptos_commission/package.json");
}

go();