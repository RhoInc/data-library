var fs = require('fs');
var head = fs.readFileSync('./src/templates/head.html', 'utf8').split(/\r?\n/);
var bodyHeader = fs.readFileSync('./src/templates/body-header.html', 'utf8').split(/\r?\n/);
var bodyContent = fs.readFileSync('./src/templates/body-content-main.html', 'utf8').split(/\r?\n/);
var bodyFooter = fs.readFileSync('./src/templates/body-footer.html', 'utf8').split(/\r?\n/);

function buildIndexHTML(dataFolder) {
    var index = ['<!DOCTYPE HTML>', `<html lang = 'en'>`];

    // head
    index.push('    <head>');
    head.forEach((line, i) => {
        if (i < head.length - 1)
            index.push(
                `        ${line.replace('[nFolders]/', './').replace('[header]', 'Data Library')}`
            );
    });
    index.push('    </head>\r\n');

    // body
    index.push('    <body>');
    bodyHeader.forEach((line, i) => {
        if (i < bodyHeader.length - 1)
            index.push(
                `        ${line.replace('[nFolders]/', './').replace('[header]', 'Data Library')}`
            );
    });
    bodyContent.forEach((line, i) => {
        if (i < bodyContent.length - 1)
            index.push(
                `        ${line.replace('[nFolders]/', './').replace('[header]', 'Data Library')}`
            );
    });
    index.push(`<script>var context="main"</script>`);

    bodyFooter.forEach((line, i) => {
        if (i < bodyFooter.length - 1)
            index.push(
                `        ${line.replace('[nFolders]/', './').replace('[header]', 'Data Library')}`
            );
    });
    index.push('    </body>\r\n');

    index.push('</html>');

    //Output index.html.
    fs.writeFile(`./index.html`, index.join('\r\n'), err => {
        if (err) console.log(err);
        console.log(`Main index.html was successfully built!`);
    });
}

buildIndexHTML('.');
