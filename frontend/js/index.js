document.getElementById('fetchGithubData').addEventListener('click', function() {
    fetch('http://localhost:8000/backend/', {
        method: 'GET',
        headers: new Headers({
            'Content-Type': 'application/json',
            'Accept': 'application/json'
        })
    })
    .then(response => {
        if (!response.ok) {
            throw new Error('Network response was not ok: ' + response.statusText);
        }
        return response.json();
    })
    .then(data => {
        console.log(data); // Print the entire data object to the console

        const ctx = document.getElementById('langChart').getContext('2d');
        const chart = new Chart(ctx, {
            type: 'pie',
            data: {
                labels: Object.keys(data.languages),
                datasets: [{
                    label: 'Language Usage',
                    data: Object.values(data.languages),
                    backgroundColor: [
                        'rgb(255, 99, 132)',
                        'rgb(54, 162, 235)',
                        'rgb(255, 206, 86)',
                        'rgb(75, 192, 192)',
                        'rgb(153, 102, 255)',
                    ]
                }]
            },
            options: {}
        });

        // Populate language stats table
        let statsHTML = '<table><tr><th>Language</th><th>Bytes</th></tr>';
        for (let lang in data.languages) {
            statsHTML += `<tr><td>${lang}</td><td>${data.languages[lang]}</td></tr>`;
        }
        statsHTML += '</table>';
        document.getElementById('languageStats').innerHTML = statsHTML;

        // Check if data.commits exists and is an array
        if (Array.isArray(data.commits) && data.commits.length > 0) {
            // Populate commit logs
            let commitHTML = '<h2>Recent Commits</h2><ul>';
            data.commits.forEach(commit => {
                const commitDate = new Date(commit.commit.author.date);
                commitHTML += `<li>${commit.commit.message} by ${commit.commit.author.name} on ${commitDate.toLocaleDateString()} at ${commitDate.toLocaleTimeString()}</li>`;
            });
            commitHTML += '</ul>';
            document.getElementById('commitLog').innerHTML = commitHTML;

            // Prepare data for the contributions graph
            const contributions = {};
            data.commits.forEach(commit => {
                const date = new Date(commit.commit.author.date).toDateString();
                contributions[date] = (contributions[date] || 0) + 1;
            });

            // Generate the contributions graph
            generateContributionsGraph(contributions);
        } else {
            console.log('No commit data found in the response.');
        }
    })
    .catch(error => console.error('Error:', error));
});

function generateContributionsGraph(contributions) {
    const cellSize = 20; // Size of each day cell
    const cellMargin = 3; // Margin around each cell
    const weekWidth = cellSize + cellMargin; // Width of each "week" column
    const daysOfWeek = 7;
    const monthLabelHeight = 20; // Space for month labels
    const cellYOffset = 20; // Space above cells for month labels

    const startDate = new Date(new Date().setMonth(new Date().getMonth() - 3));
    const endDate = new Date();

    const weeksToShow = d3.timeWeek.count(startDate, endDate) + 1; // Calculate weeks between dates
    const graphWidth = weeksToShow * weekWidth; // Dynamic width based on content
    const legendWidth = 200; // Width for the legend
    const totalWidth = graphWidth + legendWidth; // Total width including legend

    const height = daysOfWeek * (cellSize + cellMargin) + cellYOffset + monthLabelHeight;

    d3.select('#contributionsGraph svg').remove(); // Clear previous graph
    const svg = d3.select('#contributionsGraph').append('svg')
        .attr('width', totalWidth)
        .attr('height', height)
        .style('background-color', '#202530');

    let dates = d3.timeDays(startDate, endDate);

    let monthStarts = d3.timeMonths(startDate, endDate);
    monthStarts.forEach(monthStart => {
        let monthX = (d3.timeWeek.count(startDate, monthStart) * weekWidth);
        svg.append('text')
            .attr('class', 'month-label')
            .attr('x', monthX)
            .attr('y', monthLabelHeight)
            .text(d3.timeFormat('%b')(monthStart));
    });

    // Define gradient for half-pink and half-green days
    const defs = svg.append('defs');
    const gradient = defs.append('linearGradient')
        .attr('id', 'halfHalf')
        .attr('x1', '0%').attr('y1', '0%')
        .attr('x2', '100%').attr('y2', '0%');
    gradient.append('stop').attr('offset', '50%').attr('stop-color', 'pink').attr('stop-opacity', 1);
    gradient.append('stop').attr('offset', '50%').attr('stop-color', 'green').attr('stop-opacity', 1);

    const tooltip = d3.select('#tooltip');

    svg.selectAll('rect.day-cell')
        .data(dates)
        .enter().append('rect')
        .attr('class', 'day-cell')
        .attr('width', cellSize)
        .attr('height', cellSize)
        .attr('x', d => (d3.timeWeek.count(startDate, d) * weekWidth))
        .attr('y', d => (d.getDay() * (cellSize + cellMargin)) + cellYOffset + monthLabelHeight)
        .attr('fill', d => {
            let key = d.toDateString();
            let isClassDay = d.getDay() === 2 || d.getDay() === 4;
            let hasCommit = contributions[key];
            return isClassDay && hasCommit ? 'url(#halfHalf)' :
                isClassDay ? 'pink' :
                hasCommit ? 'green' : '#000000';
        })
        .on('mouseover', function(event, d) {
            let commitInfo = contributions[d.toDateString()] ? `${contributions[d.toDateString()]} commits` : 'No commits';
            let classDayInfo = (d.getDay() === 2 || d.getDay() === 4) ? 'Class day' : 'No class';
            tooltip.transition()
                .duration(200)  // Control the speed of the tooltip appearance
                .style('opacity', .9);
            tooltip.html(`${d.toDateString()}: ${commitInfo} <br> ${classDayInfo}`)
                .style('left', (event.pageX + 10) + 'px')  // Positioning tooltip to the right of the cursor
                .style('top', (event.pageY - 28) + 'px');
        })
        .on('mouseout', function(d) {
            tooltip.transition()
                .duration(500)
                .style('opacity', 0);
        });

    // Define the legend within the same SVG
    const legend = svg.append('g')
        .attr('transform', `translate(${graphWidth}, 0)`); // Position legend right next to the graph

    const colors = ['pink', 'green', 'url(#halfHalf)', '#000000'];
    const texts = ['Class Day', 'Commit Day', 'Both', 'No Events'];
    colors.forEach((color, index) => {
        legend.append('rect')
            .attr('x', 10)
            .attr('y', index * 30)
            .attr('width', 20)
            .attr('height', 20)
            .attr('fill', color);

        legend.append('text')
            .attr('x', 40)
            .attr('y', index * 30 + 15)
            .attr('fill', 'white') // Set text color to white
            .text(texts[index]);
    });
}