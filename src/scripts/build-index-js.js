var path = './data/clinical-trials/adam'
var split = path.split('/');
var nFolders = split.length - 1;
var folder = split.slice().pop();
var type = folder
    .split('-')
    .map(str => str.substring(0,1).toUpperCase() + str.substring(1).toLowerCase())
    .join(' ')
    .replace('Adam', 'ADaM (Analysis Data Model)')
    .replace('Sdtm', 'SDTM (Study Data Tabulation Model)')
console.log(path);
console.log(split);
console.log(nFolders);
console.log(folder);
console.log(type);
var fs = require('fs');
var head = fs.readFileSync('./src/templates/head.html', 'utf8').split('\r\n');
var body = fs.readFileSync('./src/templates/body.html', 'utf8').split('\r\n');
var index = [
    '<!DOCTYPE HTML>',
    `<html lang = 'en'>`
];

// head
index.push('    <head>');
    head.forEach(line => {
        index.push(`        ${
            line.replace('[nFolders]/', '../'.repeat(nFolders))
                .replace('[type]', type)
                .replace('[folder]', folder)
        }`);
    });
index.push('    </head>\r\n');

// body
index.push('    <body>');
    body.forEach(line => {
        index.push(`        ${
            line.replace('[nFolders]/', '../'.repeat(nFolders))
                .replace('[type]', type)
                .replace('[folder]', folder)
        }`);
    });
index.push('    </body>\r\n');

// script
index.push(`    <script type = 'text/javascript' src = './index.js'></script>`);
index.push('</html>');

console.log(index);

//Output index.html.
fs.writeFile(
    `${path}/index.html`,
    index.join('\r\n'),
    err => {
        if (err)
            console.log(err);
            console.log('index.html was successfully built!');
    }
);
