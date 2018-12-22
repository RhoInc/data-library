var fs = require('fs');
var dataFolders = JSON.parse(fs.readFileSync('./src/data-folders.json', 'utf8'))
var head = fs.readFileSync('./src/templates/head.html', 'utf8').split('\r\n');
var body = fs.readFileSync('./src/templates/body.html', 'utf8').split('\r\n');

function buildIndexHTML(dataFolder) {
    var split = dataFolder.split('/');
    var nFolders = split.length - 1;
    var folder = split.slice().pop();
    var type = `${
        folder
            .split('-')
            .map(str => str.substring(0,1).toUpperCase() + str.substring(1).toLowerCase())
            .join(' ')
            .replace('Cdisc', 'CDISC')
            .replace('Sdtm', 'SDTM')
            .replace('Adam', 'ADaM')
    } Datasets`;
    var index = [
        '<!DOCTYPE HTML>',
        `<html lang = 'en'>`
    ];

    // head
    index.push('    <head>');
        head.forEach((line,i) => {
            if (i < head.length - 1)
                index.push(`        ${
                    line.replace('[nFolders]/', '../'.repeat(nFolders))
                        .replace('[type]', type)
                        .replace('[folder]', folder)
                }`);
        });
    index.push('    </head>\r\n');

    // body
    index.push('    <body>');
        body.forEach((line,i) => {
            if (i < body.length - 1)
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


    //Output index.html.
    fs.writeFile(
        `${dataFolder}/index.html`,
        index.join('\r\n'),
        err => {
            if (err)
                console.log(err);
                console.log(`index.html was successfully built in ${dataFolder}!`);
        }
    );
}

dataFolders.forEach(dataFolder => {
    buildIndexHTML(dataFolder);
});
