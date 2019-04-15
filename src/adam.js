const explorer = webcodebook.createExplorer('#container', {
    files: [
        {
            name: 'ADSL',
            path: './adsl.csv',
            rows: 150,
            columns: 10
        },
        {
            name: 'ADAE',
            path: './adae.csv',
            rows: 150,
            columns: 10
        },
        {
            name: 'ADCM',
            path: './adcm.csv',
            rows: 150,
            columns: 10
        },
        {
            name: 'ADVS',
            path: './advs.csv',
            rows: 150,
            columns: 10
        },
        {
            name: 'ADLB',
            path: './adlb.csv',
            rows: 150,
            columns: 10
        }
    ]
});
explorer.init();
