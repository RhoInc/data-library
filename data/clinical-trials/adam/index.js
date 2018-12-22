function readTextFile(file)
{
    var rawFile = new XMLHttpRequest();
    rawFile.open("GET", file, false);
    rawFile.onreadystatechange = function ()
    {
        if(rawFile.readyState === 4)
        {
            if(rawFile.status === 200 || rawFile.status == 0)
            {
                var allText = rawFile.responseText;
                d3.select('.data-standard').html(allText);
            }
        }
    }
    rawFile.send(null);
}

d3.json('data-files.json', data => {
    readTextFile('./data-standard.html');
    const explorer = webcodebook.createExplorer(
        '.web-codebook-container',
        {
            files: data,
            labelColumn: 'name',
            defaultCodebookSettings: {
                chartVisibility: 'visible',
            },
            tableConfig: {
                cols: [
                    'name',
                    'nRows',
                    'nCols',
                ],
                headers: [
                    'Dataset',
                    '# rows',
                    '# columns',
                ],
                sortable: true,
                searchable: true,
                pagination: false,
                exportable: false,
            },
            ignoredColumns: [
                'relPath',
                'path',
                'file',
                'cols'
            ],
        }
    );
    explorer.init();
});
