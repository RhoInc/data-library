export default function makeMainDataList() {
    function readTextFile(file, element) {
        var rawFile = new XMLHttpRequest();
        rawFile.open('GET', file, false);
        rawFile.onreadystatechange = function() {
            if (rawFile.readyState === 4) {
                if (rawFile.status === 200 || rawFile.status == 0) {
                    var allText = rawFile.responseText;
                    element.html(allText);
                }
            }
        };
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
                container.classed(d.subtype, true);
                const header = container.append('h2').classed('header', true);
                const link = header
                    .append('a')
                    .attr('href', d.relPath)
                    .text(d.header.replace(' Datasets', ''));

                /* Expandable Details */
                if (!(['sdtm', 'adam'].indexOf(d.subtype) > -1 && d.folder !== d.subtype)) {
                    const details = container.append('div').classed('details', true);
                    const detailsHeader = details
                        .append('div')
                        .classed('details-header', true)
                        .html('Details')
                        .on('click', function() {
                            const detailsHeader = d3.select(this);
                            const detailsToggle = detailsHeader.select('.details-toggle');
                            const detailsContent = d3
                                .select(this.parentNode)
                                .select('.details-content');
                            const hidden = detailsContent.classed('hidden');
                            if (hidden) {
                                detailsToggle.text('-');
                                detailsContent.classed('hidden', false);
                            } else {
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
                /* Expandable Files List */
                const files = container.append('div');
                const filesHeader = files
                    .append('div')
                    .attr('class', 'files-header')
                    .text(` ${d.nDataFiles} datasets`)
                    .on('click', function() {
                        const filesHeader = d3.select(this);
                        const filesToggle = filesHeader.select('.files-toggle');
                        const filesContent = d3.select(this.parentNode).select('.files-content');
                        const hidden = filesContent.classed('hidden');
                        if (hidden) {
                            filesToggle.text('-');
                            filesContent.classed('hidden', false);
                        } else {
                            filesToggle.text('+');
                            filesContent.classed('hidden', true);
                        }
                    });
                const filesToggle = filesHeader
                    .append('span')
                    .classed('files-toggle toggle', true)
                    .text('+');
                const filesContent = files
                    .append('div')
                    .classed('files-content content hidden', true)
                    .append('ul');

                const files_lis = filesContent
                    .selectAll('li')
                    .data(d => d.dataFiles)
                    .enter()
                    .append('li');

                files_lis
                    .append('div')
                    .attr('title', d => d.fileName)
                    .text(d => d.fileName.replace(/\.(csv|json)$/, ''));
                //.text(d => d.fileName.length < 25 ? d.fileName : d.fileName.substring(0,25) + '...');

                files_lis
                    .append('a')
                    .html("<i class='fa fa-download'></i>")
                    .attr('title', d => 'Download ' + d.fileName)
                    .attr('href', d => d.rel_url)
                    .attr('download', d => d.fileName);

                function copyToClipboard(text) {
                    var dummy = document.createElement('input');
                    document.body.appendChild(dummy);
                    dummy.setAttribute('value', text);
                    dummy.select();
                    document.execCommand('copy');
                    document.body.removeChild(dummy);
                }

                files_lis
                    .append('a')
                    .attr('title', d => 'Copy URL for ' + d.fileName + ' to clipboard')
                    .html("<i class='fa fa-clipboard'></i>")
                    .on('click', function(d) {
                        var icon = d3.select(this);
                        copyToClipboard(d.download_url);
                        icon.html("<i style='color:green;' class='fa fa-check'></i>");
                        setTimeout(function() {
                            icon.html("<i class='fa fa-clipboard'></i>");
                        }, 1000);
                    });
            });
    });
}
