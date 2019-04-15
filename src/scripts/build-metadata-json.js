var fs = require('fs');
var path = require('path');
var csv = require('csvtojson');
var saveData = require('./saveData.js').default;
var dir = './data';

function getMetadata(dataFile) {
    return new Promise((resolve, reject) => {
        csv()
            .fromFile(dataFile)
            .then(data => {
                resolve(data);
            });
    });
}

var dataFolders = [];

var descend = async function(dir) {
    //Read files in directory.
    var files = fs.readdirSync(dir).map(file => dir + '/' + file);

    //Filter out files with .csv extension.
    var dataFiles = files.filter(file => file.split('.').pop() === 'csv');

    if (dataFiles.length) {
        var parsedFiles = dataFiles.map(function(m) {
            return {
                fileName: m.substring(m.lastIndexOf('/') + 1),
                download_url:
                    'https://raw.githubusercontent.com/RhoInc/data-library/master/' + m.slice(2),
                rel_url: m
            };
        });
        dataFolders.push({
            relPath: dir,
            nDataFiles: dataFiles.length,
            dataFiles: parsedFiles,
            split: dir.split('/')
        });
        //Capture .csv metadata.
        var promises = dataFiles.map(dataFile => {
            return getMetadata(dataFile).then(data => {
                //console.log(`Processing ${dataFile}.`);
                var metadata = {
                    relPath: dataFile, // relative file path
                    path: dataFile.split('/').pop(), // file name with extension
                    name: dataFile
                        .split('/')
                        .pop()
                        .split('.')[0], // file name
                    //json: data,
                    nRows: data.length,
                    cols: Object.keys(data[0]),
                    nCols: Object.keys(data[0]).length
                };

                return metadata;
            });
        });

        //Wait for all Promises to complete.
        Promise.all(promises)
            .then(metadata => {
                console.log(`Outputting the contents of ${dir}.`);
                fs.writeFileSync(dir + '/' + 'data-files.json', JSON.stringify(metadata, null, 4));
            })
            .catch(e => console.error(e));
    }

    //Filter out files that are folders.
    var directories = files.filter(file => fs.statSync(file).isDirectory());

    if (directories.length) {
        directories.forEach(directory => {
            descend(directory);
        });
    }

    return files;
};

descend(dir);

//Export list of data folders.
dataFolders = dataFolders
    .map(dataFolder => {
        const obj = Object.assign({}, dataFolder);
        obj.nFolders = obj.split.length - 1;
        obj.folder = obj.split[obj.nFolders];
        obj.type = obj.split[2];
        obj.subtype = obj.split[3];
        obj.header = `${obj.folder
            .split('-')
            .map(str => str.substring(0, 1).toUpperCase() + str.substring(1).toLowerCase())
            .join(' ')
            .replace('Cdisc', 'CDISC')
            .replace('Sdtm', 'SDTM')
            .replace('Adam', 'ADaM')
            .replace(' Specific', '-Specific')} Datasets`;

        if (obj.subtype && obj.subtype !== obj.folder)
            obj.header = `${obj.subtype.replace('sdtm', 'SDTM').replace('adam', 'ADaM')} - ${
                obj.header
            }`;
        console.log(obj.header);

        return obj;
    })
    .sort((a, b) => {
        return a.folder === 'sdtm'
            ? -1
            : b.folder === 'sdtm'
            ? 1
            : a.relPath.indexOf('sdtm') > -1
            ? -1
            : b.relPath.indexOf('sdtm') > -1
            ? 1
            : a.folder === 'adam'
            ? -1
            : b.folder === 'adam'
            ? 1
            : a.relPath.indexOf('adam') > -1
            ? -1
            : b.relPath.indexOf('adam') > -1
            ? 1
            : a.folder === 'data-cleaning'
            ? -1
            : b.folder === 'data-cleaning'
            ? 1
            : a.folder === 'renderer-specific'
            ? -1
            : b.folder === 'renderer-specific'
            ? 1
            : a.folder === 'miscellaneous'
            ? 1
            : b.folder === 'miscellaneous'
            ? -1
            : a.folder < b.folder
            ? -1
            : 1;
    });
fs.writeFileSync('./src/data-folders.json', JSON.stringify(dataFolders, null, 4));
