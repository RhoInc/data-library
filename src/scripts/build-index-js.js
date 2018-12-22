var fs = require('fs');
var dataFolders = JSON.parse(fs.readFileSync('./src/data-folders.json', 'utf8'))

function buildIndexJS(dataFolder) {
    var code = fs.readFileSync('./src/templates/index.js', 'utf8');
    fs.writeFile(
        `${dataFolder}/index.js`,
        code,
        err => {
            if (err)
                console.log(err);
                console.log(`index.js was successfully build in ${dataFolder}!`);
        }
    );
}

dataFolders.forEach(dataFolder => {
    buildIndexJS(dataFolder);
});
