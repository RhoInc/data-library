function readTextFile(file, element) {
    var rawFile = new XMLHttpRequest();
    rawFile.open("GET", file, false);
    rawFile.onreadystatechange = function ()
    {
        if(rawFile.readyState === 4)
        {
            if(rawFile.status === 200 || rawFile.status == 0)
            {
                var allText = rawFile.responseText;
                element.html(allText);
            }
        }
    }
    rawFile.send(null);
}

d3.json('./src/data-folders.json', function(data) {
    d3.select('.data-group')
        .selectAll('div.data-grouping')
            .data(data)
            .enter()
        .append('div')
        .classed('data-grouping', true)
        .each(function(d) {
            const container = d3.select(this);

            if (['sdtm', 'adam'].indexOf(d.subtype) > -1 && d.folder !== d.subtype) {
                const header = container.append('small')
                    .append('a')
                    .attr('href', d.relPath)
                    .style('margin-left', '50px')
                    .text(d.header.replace(' Datasets', ''));
            } else {
                const header = container.append('h2')
                    .classed('data-header', true)
                    .append('a')
                    .attr('href', d.relPath)
                    .text(d.header.replace(' Datasets', ''));
                const dataStandard = container.append('div');
                readTextFile(d.relPath + '/data-standard.html', dataStandard);
            }

            if (['sdtm', 'adam'].indexOf(d.subtype) > -1 && d.folder === d.subtype && data.filter(di => di.subtype === d.subtype).length > 1) {
                container.append('h3')
                    .style({
                        'margin-bottom': '5px',
                        'margin-left': '25px',
                    })
                    .text('Additional Examples:');
            }
        });
});
