var fs = require('fs');
var path = require('path');
var csv = require('csvtojson');
var saveData = require('./saveData.js').default;
var dir = './data';

var descend = function(dir) {
    //Read files in directory.
    var files = fs.readdirSync(dir)
        .map(file => dir + '/' + file);

    //Filter out files with .csv extension.
    var dataFiles = files
        .filter(file => file.split('.').pop() === 'csv');

    if (dataFiles.length) {
        //Capture .csv metadata.
        var metadata = dataFiles
            .map(dataFile => {
                var metadata = {
                    path: dataFile, // relative file path
                    name: dataFile.split('/').pop().split('.')[0], // file name
                    //json: await csv().fromFile(dataFile),
                };
                const test = await csv().fromFile(dataFile);
                console.log(test);
                metadata.rows = test.length;
                metadata.cols = Object.keys(test).length;
                //metadata.json
                //    .subscribe(d => {
                //        console.log(d);
                //        metadata.rows += 1; // count rows
                //        if (!file.cols) file.cols = Object.keys(d).length; // count columns
                //    });

                return metadata;
            });

        //Write .csv meatadata to current directory.
        fs.writeFileSync(
            dir + '/' + 'data-files.json',
            JSON.stringify(metadata, null, 4)
        );
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
