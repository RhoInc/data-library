var fs = require('fs');
var path = require('path');
var csv = require('csvtojson');
var saveData = require('./saveData.js').default;
var dir = './data';

function getMetadata(dataFile) {
    return new Promise((resolve,reject) => {
        csv()
            .fromFile(dataFile)
            .then(data => {
                resolve(data);
            });
    });
}

var descend = async function(dir) {
    //Read files in directory.
    var files = fs.readdirSync(dir)
        .map(file => dir + '/' + file);

    //Filter out files with .csv extension.
    var dataFiles = files
        .filter(file => file.split('.').pop() === 'csv');

    if (dataFiles.length) {
        //Capture .csv metadata.
        var promises = dataFiles
            .map(dataFile => {
                return getMetadata(dataFile)
                    .then(data => {
                        //console.log(`Processing ${dataFile}.`);
                        var metadata = {
                            path: dataFile, // relative file path
                            file: dataFile.split('/').pop(), // file name with extension
                            name: dataFile.split('/').pop().split('.')[0], // file name
                            //json: data,
                            nRows: data.length,
                            cols: Object.keys(data[0]),
                            nCols: Object.keys(data[0]).length,
                        };

                        return metadata;
                    });
            });

        //Wait for all Promises to complete.
        Promise.all(promises)
            .then(metadata => {
                console.log(`Outputting the contents of ${dir}.`);
                fs.writeFileSync(
                    dir + '/' + 'data-files.json',
                    JSON.stringify(metadata, null, 4)
                );
            })
            .catch(e => console.error(e));
    }

    //Filter out files that are folders.
    var directories = files
        .filter(file => fs.statSync(file).isDirectory());

    if (directories.length) {
        directories.forEach(directory => {
            descend(directory);
        });
    }

    return files;
}

descend(dir);
