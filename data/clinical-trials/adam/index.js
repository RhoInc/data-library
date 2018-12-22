d3.json('data-files.json', data => {
    console.table(data);
                //{
                //    name: 'ADSL',
                //    path: './adsl.csv',
                //    rows: 150,
                //    columns: 10,
                //},
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
                'path',
                'file',
                'cols'
            ],
        }
    );
    explorer.init();
});
