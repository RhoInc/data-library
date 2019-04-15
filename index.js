(function(factory) {
    typeof define === 'function' && define.amd ? define(factory) : factory();
})(function() {
    'use strict';

    function makeMainDataList() {
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
                    var container = d3.select(this);
                    container.classed(d.subtype, true);
                    var header = container.append('h2').classed('header', true);
                    var link = header
                        .append('a')
                        .attr('href', d.relPath)
                        .text(d.header.replace(' Datasets', ''));
                    /* Expandable Details */

                    if (!(['sdtm', 'adam'].indexOf(d.subtype) > -1 && d.folder !== d.subtype)) {
                        var details = container.append('div').classed('details', true);
                        var detailsHeader = details
                            .append('div')
                            .classed('details-header', true)
                            .html('Details')
                            .on('click', function() {
                                var detailsHeader = d3.select(this);
                                var detailsToggle = detailsHeader.select('.details-toggle');
                                var detailsContent = d3
                                    .select(this.parentNode)
                                    .select('.details-content');
                                var hidden = detailsContent.classed('hidden');

                                if (hidden) {
                                    detailsToggle.text('-');
                                    detailsContent.classed('hidden', false);
                                } else {
                                    detailsToggle.text('+');
                                    detailsContent.classed('hidden', true);
                                }
                            });
                        var detailsToggle = detailsHeader
                            .append('span')
                            .classed('details-toggle', true)
                            .text('+');
                        var detailsContent = details
                            .append('div')
                            .classed('details-content hidden', true);
                        readTextFile(d.relPath + '/data-standard.html', detailsContent);
                    }
                    /* Expandable Files List */

                    var files = container.append('div');
                    var filesHeader = files
                        .append('div')
                        .attr('class', 'files-header')
                        .text(' '.concat(d.nDataFiles, ' datasets'))
                        .on('click', function() {
                            var filesHeader = d3.select(this);
                            var filesToggle = filesHeader.select('.files-toggle');
                            var filesContent = d3.select(this.parentNode).select('.files-content');
                            var hidden = filesContent.classed('hidden');

                            if (hidden) {
                                filesToggle.text('-');
                                filesContent.classed('hidden', false);
                            } else {
                                filesToggle.text('+');
                                filesContent.classed('hidden', true);
                            }
                        });
                    var filesToggle = filesHeader
                        .append('span')
                        .classed('files-toggle toggle', true)
                        .text('+');
                    var filesContent = files
                        .append('div')
                        .classed('files-content content hidden', true)
                        .append('ul');
                    var files_lis = filesContent
                        .selectAll('li')
                        .data(function(d) {
                            return d.dataFiles;
                        })
                        .enter()
                        .append('li')
                        .text(function(d) {
                            return d.fileName;
                        });
                    files_lis
                        .append('a')
                        .html("<i class='fa fa-download'></i>")
                        .attr('title', function(d) {
                            return 'Download ' + d.fileName;
                        })
                        .attr('href', function(d) {
                            return d.rel_url;
                        })
                        .attr('download', function(d) {
                            return d.fileName;
                        });

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
                        .attr('title', function(d) {
                            return 'Copy URL for ' + d.fileName + ' to clipboard';
                        })
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

    function makeSubDataList() {
        function readTextFile(file) {
            var rawFile = new XMLHttpRequest();
            rawFile.open('GET', file, false);

            rawFile.onreadystatechange = function() {
                if (rawFile.readyState === 4) {
                    if (rawFile.status === 200 || rawFile.status == 0) {
                        var allText = rawFile.responseText;
                        d3.select('.data-standard').html(allText);
                    }
                }
            };

            rawFile.send(null);
        }

        d3.json('data-files.json', function(data) {
            readTextFile('./data-standard.html');
            var explorer = webcodebook.createExplorer('.web-codebook-container', {
                files: data,
                labelColumn: 'name',
                defaultCodebookSettings: {
                    chartVisibility: 'visible'
                },
                tableConfig: {
                    cols: ['name', 'nRows', 'nCols'],
                    headers: ['Dataset', '# rows', '# columns'],
                    sortable: true,
                    searchable: true,
                    pagination: false,
                    exportable: false
                },
                ignoredColumns: ['relPath', 'path', 'file', 'cols']
            });
            explorer.init();
        });
    }

    if (typeof context !== 'undefined' && context == 'main') {
        makeMainDataList();
    } else {
        makeSubDataList();
    }
});
