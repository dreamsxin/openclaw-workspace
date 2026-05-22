const fs = require("fs");
const path = require("path");

const [inputPath, outputPath, prefixArg, keyArg] = process.argv.slice(2);
if (!inputPath || !outputPath || !prefixArg) {
  console.error("Usage: node decrypt-yoo-xor16-prefix.js <input> <output> <prefixBytes> [keyHex]");
  process.exit(2);
}

const prefixBytes = Number.parseInt(prefixArg, 10);
const key = keyArg ? Number.parseInt(keyArg, 16) : 0x16;
const data = fs.readFileSync(inputPath);
for (let i = 0; i < Math.min(prefixBytes, data.length); i++) {
  data[i] ^= key;
}
fs.mkdirSync(path.dirname(outputPath), { recursive: true });
fs.writeFileSync(outputPath, data);
console.log(`decoded-prefix input=${inputPath} output=${outputPath} prefix=${prefixBytes} key=0x${key.toString(16)}`);
