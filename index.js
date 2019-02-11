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
            container.classed(d.subtype, true)
            const header = container.append('h2').classed('header', true);
            const link = header
                .append('a')
                .attr('href', d.relPath)
                .text(d.header.replace(' Datasets', ''));
            const nDataFiles = header.append('span').classed('n-data-files', true).text(` (${d.nDataFiles} datasets)`);

            if (!(['sdtm', 'adam'].indexOf(d.subtype) > -1 && d.folder !== d.subtype)) {
                const details = container
                    .append('div')
                    .classed('details', true);
                const detailsHeader = details
                    .append('div')
                    .classed('details-header', true)
                    .html('<span class = "view-hide">View</span> details')
                    .on('click', function() {
                        const detailsHeader = d3.select(this);
                        const detailsToggle = detailsHeader.select('.details-toggle');
                        const detailsContent = d3.select(this.parentNode).select('.details-content');
                        const hidden = detailsContent.classed('hidden');
                        if (hidden) {
                            detailsHeader.select('.view-hide').text('Hide');
                            detailsToggle.text('-');
                            detailsContent.classed('hidden', false);
                        } else {
                            detailsHeader.select('.view-hide').text('View');
                            detailsToggle.text('+');
                            detailsContent.classed('hidden', true);
                        }
                    });
                const detailsToggle = detailsHeader
                    .append('span')
                    .classed('details-toggle', true)
                    .text('+');
                const detailsContent = details
                    .append('div')
                    .classed('details-content hidden', true);
                readTextFile(d.relPath + '/data-standard.html', detailsContent);
            }

            //if (['sdtm', 'adam'].indexOf(d.subtype) > -1 && d.folder === d.subtype && data.filter(di => di.subtype === d.subtype).length > 1) {
            //    container.append('h3')
            //        .style({
            //            'margin-bottom': '5px',
            //            'margin-left': '25px',
            //        })
            //        .text('Additional Examples:');
            //}
        });
});
