var fs = require('fs');
var dataFolders = JSON.parse(fs.readFileSync('./src/data-folders.json', 'utf8'))
var head = fs.readFileSync('./src/templates/head.html', 'utf8').split(/\r?\n/);
var body = fs.readFileSync('./src/templates/body.html', 'utf8').split(/\r?\n/);

function buildIndexHTML(dataFolder) {
    var index = [
        '<!DOCTYPE HTML>',
        `<html lang = 'en'>`
    ];

    // head
    index.push('    <head>');
        head.forEach((line,i) => {
            if (i < head.length - 1)
                index.push(`        ${
                    line.replace('[nFolders]/', '../'.repeat(dataFolder.nFolders))
                        .replace('[header]', dataFolder.header)
                }`);
        });
    index.push('    </head>\r\n');

    // body
    index.push('    <body>');
        body.forEach((line,i) => {
            if (i < body.length - 1)
                index.push(`        ${
                    line.replace('[nFolders]/', '../'.repeat(dataFolder.nFolders))
                        .replace('[header]', dataFolder.header)
            }`);
        });
    index.push('    </body>\r\n');

    // script
    index.push(`    <script type = 'text/javascript' src = './index.js'></script>`);
    index.push('</html>');


    //Output index.html.
    fs.writeFile(
        `${dataFolder.relPath}/index.html`,
        index.join('\r\n'),
        err => {
            if (err)
                console.log(err);
                console.log(`index.html was successfully built in ${dataFolder.folder}!`);
        }
    );
}

dataFolders.forEach(dataFolder => {
    buildIndexHTML(dataFolder);
});
