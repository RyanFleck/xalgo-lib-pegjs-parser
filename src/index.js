import fs from 'fs';
import { parse } from './parser-exported.js';

export function add(a, b) {
    return a + b;
}

export function subtract(a, b) {
    return a - b;
}

console.log(`${'\n'.repeat(20)}Parsing...`);

const testRulePath = 'test-rules/singapore-stamp-duty.rule';

function cleanData(data) {
    return data.replace(/[\u{0080}-\u{FFFF}]/gu, '').replace(/[\n]/g, '\n');
}

try {
    console.log(`Reading ${testRulePath}:\n`);
    const data = cleanData(fs.readFileSync(testRulePath, 'utf8'));
    console.log(data.toString());
    console.log('\n\nParsing rule...\nResult:\n\n');
    const parsedJSON = parse(data);
    console.log(JSON.stringify(parsedJSON));
} catch (e) {
    console.log('Error:', e.stack);
}

// const parser = peg.generate("start = ('a' / 'b')+");
// console.log(parser.parse('iw'));
