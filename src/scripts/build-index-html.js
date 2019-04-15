var fs = require('fs');
var dataFolders = JSON.parse(fs.readFileSync('./src/data-folders.json', 'utf8'));
var head = fs.readFileSync('./src/templates/head.html', 'utf8').split(/\r?\n/);
var bodyHeader = fs.readFileSync('./src/templates/body-header.html', 'utf8').split(/\r?\n/);
var bodyContent = fs.readFileSync('./src/templates/body-content.html', 'utf8').split(/\r?\n/);
var bodyFooter = fs.readFileSync('./src/templates/body-footer.html', 'utf8').split(/\r?\n/);

var path = require('path');
global.appRoot = path.resolve(__dirname);

function buildIndexHTML(dataFolder) {
    var index = ['<!DOCTYPE HTML>', `<html lang = 'en'>`];

    // head
    index.push('    <head>');
    head.forEach((line, i) => {
        if (i < head.length - 1)
            index.push(
                `        ${line
                    .replace('[nFolders]/', '../'.repeat(dataFolder.nFolders))
                    .replace('[header]', dataFolder.header)}`
            );
    });
    index.push('    </head>\r\n');

    // body
    index.push('    <body>');
    bodyHeader.forEach((line, i) => {
        if (i < bodyHeader.length - 1)
            index.push(
                `        ${line
                    .replace('[nFolders]/', '../'.repeat(dataFolder.nFolders))
                    .replace('[header]', dataFolder.header)}`
            );
    });
    bodyContent.forEach((line, i) => {
        if (i < bodyContent.length - 1)
            index.push(
                `        ${line
                    .replace('[nFolders]/', '../'.repeat(dataFolder.nFolders))
                    .replace('[header]', dataFolder.header)}`
            );
    });
    bodyFooter.forEach((line, i) => {
        if (i < bodyFooter.length - 1)
            index.push(
                `        ${line
                    .replace('[nFolders]/', '../'.repeat(dataFolder.nFolders))
                    .replace('[header]', dataFolder.header)}`
            );
    });
    index.push('    </body>\r\n');

    //Output index.html.
    fs.writeFile(`${dataFolder.relPath}/index.html`, index.join('\r\n'), err => {
        if (err) console.log(err);
        console.log(`index.html was successfully built in ${dataFolder.folder}!`);
    });
}

dataFolders.forEach(dataFolder => {
    buildIndexHTML(dataFolder);
});
