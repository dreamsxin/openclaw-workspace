const fs = require("fs");

const [inputPath, outputPath, minLenArg] = process.argv.slice(2);
if (!inputPath || !outputPath) {
  console.error("Usage: node extract-ascii-strings.js <input> <output> [minLen]");
  process.exit(2);
}

const minLen = minLenArg ? Number.parseInt(minLenArg, 10) : 4;
const data = fs.readFileSync(inputPath);
const out = [];
let cur = "";

function flush() {
  if (cur.length >= minLen) out.push(cur);
  cur = "";
}

for (const b of data) {
  if (b >= 0x20 && b <= 0x7e) {
    cur += String.fromCharCode(b);
  } else {
    flush();
  }
}
flush();

fs.writeFileSync(outputPath, out.join("\n"), "utf8");
console.log(`strings=${out.length} output=${outputPath}`);
