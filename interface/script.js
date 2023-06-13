async function plot_chart_1(){
    const route = 'http://127.0.0.1:8000/data1';

    let resp = await fetch(route);
    let data = await resp.json();
    var x = data.x;
    var y = data.y;
    plot_plotly(x,y)
};

async function plot_chart_2(){
    const route = 'http://127.0.0.1:8000/data2';

    let resp = await fetch(route);
    let data = await resp.json();
    var x = data.x;
    var y = data.y;
    plot_plotly(x,y)
};

async function plot_plotly(x,y){
    var delay = 100;
    var delay2 = 100;
    var frames = [];
    var steps = [];
    for (var i = 0; i < y.length; i++) {
        frames.push({
            name: i,
            data: [{ y: y[i][0] }, { y: y[i][1] }]
        });
        steps.push({
            label: i,
            method: 'animate',
            args: [[i], {
                mode: 'immediate',
                frame: { redraw: false, duration: delay },
                transition: { duration: delay }
            }]
        });
    }
    Plotly.plot('graph_slide', {
        data: [{
            x: x,
            y: y[0][0],
            mode: 'lines',//+markers
            name: 'Solution analytique'
        },
        {
            x: x,
            y: y[0][1],
            mode: 'lines',//+markers
            name: 'Solution réelle'
        }],
        layout: {
            title: 'Evolution temporelle de la solution analytique comparée à la solution réelle',
            showlegend: true,
            legend: {"orientation": "h"},
            autosize: true,
            sliders: [{
                pad: {t: 30},
                x: 0.05,
                len: 0.95,
                currentvalue: {
                    xanchor: 'right',
                    prefix: 'Step : ',
                    font: {
                        color: '#888',
                        size: 20
                    }
                },
                transition: { duration: delay },
                steps: steps
            }],
            updatemenus: [{
                type: 'buttons',
                showactive: false,
                x: 0.05,
                y: 0,
                xanchor: 'right',
                yanchor: 'top',
                direction: 'left',
                pad: {t: 60, r: 20},
                buttons: [{
                    label: 'Play',
                    method: 'animate',
                    args: [null, {
                        fromcurrent: true,
                        frame: { redraw: false, duration: delay2 },
                        transition: { duration: delay }
                    }]
                }, {
                    label: 'Pause',
                    method: 'animate',
                    args: [[null], {
                        mode: 'immediate',
                        frame: { redraw: false, duration: 0 }
                    }]
                }]
            }]
        },
        frames: frames
    }, {showSendToCloud: true});
};

async function plot_plotly_2D(data_send) {
    var graphContainer = document.getElementById('graph_slide');
    Plotly.purge(graphContainer);

    var url = "http://127.0.0.1:8000/data_2D_heatmap"
    start_loading();
    const resp = await fetch(url, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(data_send)
    });
    let data = await resp.json();
    plot_plotly_2D_heatmap(data.datas);
    end_loading();
};

async function ping() {
    start_loading();
    const route = 'http://127.0.0.1:8000/ping';
    let resp = await fetch(route);
    let data = await resp.json();
    console.log(data.data);
    end_loading();
};

async function plot_plotly_2D_heatmap(data) {
    var delay = 100;
    var delay2 = 100;
    var frames = [];
    var steps = [];
    for (var i = 0; i < data.length; i++) {
        var plotData = {
            z: data[i].map(point => point[2]),
            x: data[i].map(point => point[0]),
            y: data[i].map(point => point[1]),
            type: 'heatmap',
            zsmooth: 'best',
            colorscale: 'Jet'
        };
        frames.push({
            name: i,
            data: [plotData]
        });
        steps.push({
            label: i,
            method: 'animate',
            args: [[i], {
                mode: 'immediate',
                frame: { redraw: true, duration: delay },
                transition: { duration: delay }
            }]
        });
    }
    
    Plotly.plot('graph_slide', {
        data: [{
            z: data[0].map(point => point[2]),
            x: data[0].map(point => point[0]),
            y: data[0].map(point => point[1]),
            type: 'heatmap',
            zsmooth: 'best',
            colorscale: 'Jet'
        }],
        layout: {
            width: 720,
            height: 720,
            aspectmode: 'equal',
            showlegend: true,
            legend: {"orientation": "h"},
            autosize: true,
            sliders: [{
                pad: {t: 30},
                x: 0.05,
                len: 0.95,
                currentvalue: {
                    xanchor: 'right',
                    prefix: 'Step : ',
                    font: {
                        color: '#888',
                        size: 20
                    }
                },
                transition: { duration: delay },
                steps: steps
            }],
            updatemenus: [{
                type: 'buttons',
                showactive: false,
                x: 0.05,
                y: 0,
                xanchor: 'right',
                yanchor: 'top',
                direction: 'left',
                pad: {t: 60, r: 20},
                buttons: [{
                    label: 'Play',
                    method: 'animate',
                    args: [null, {
                    fromcurrent: true,
                    frame: { redraw: true, duration: delay2 },
                    transition: { duration: delay }
                    }]
                }, {
                    label: 'Pause',
                    method: 'animate',
                    args: [[null], {
                    mode: 'immediate',
                    frame: { redraw: true, duration: 0 }
                    }]
                }]
            }]
        },
        frames: frames
    }, {showSendToCloud: true});
};


async function compare_plotly(data_send) {
    var graphContainer = document.getElementById('graph_slide');
    Plotly.purge(graphContainer);

    var url = "http://127.0.0.1:8000/compare_data_1D"
    start_loading();
    const resp = await fetch(url, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(data_send)
    });
    let data = await resp.json();
    compare_plotly_1D_chart(data.datas);
    end_loading();
};

async function compare_plotly_1D_chart(data) {
    var plotData = [];

    for (var i = 0; i < data.length; i++) {
        plotData.push({
            x: data[i]["values"].map(point => point[0]),
            y: data[i]["values"].map(point => point[1]),
            type: 'scatter',
            mode: 'lines',
            line: {
                width: 2
            },
            name: data[i].name,
        });
    }
    
    Plotly.plot('graph_slide', {
        data: plotData,
        layout: {
            width: 720,
            height: 720,
            showlegend: true,
            legend: {"orientation": "h"},
            autosize: true,
        },
    });
};


async function plot() {
    start_loading();
    const myImage = new Image(300,300);
    myImage.src = "../src/logo.png";
    document.body.appendChild(myImage);
    var codeContainer = document.getElementById('graph_slide');
    codeContainer.appendChild(myImage);
    end_loading();
};

async function plot_chart(){
    //const route = 'http://127.0.0.1:8000/dataarray1';

    let resp = await fetch(route);
    let data = await resp.json();
    var x = data.x;
    var solution_initiale = data.y[0];
    var solution_finale = data.y[1];
    var solution_analytique = data.y[2];

    var speedCanvas = document.getElementById("graph");

    var dataFirst = {
        label: "solution_initiale",
        data: solution_initiale,
        lineTension: 0,
        fill: false,
        borderColor: 'red'
    };

    var dataSecond = {
        label: "solution_finale",
        data: solution_finale,
        lineTension: 0,
        fill: false,
        borderColor: 'blue'
    };

    var dataThird = {
        label: "solution_analytique",
        data: solution_analytique,
        lineTension: 0,
        fill: false,
        borderColor: 'green'
    };

    var speedData = {
        labels: x,
        datasets: [dataFirst, dataSecond, dataThird]
    };

    var chartOptions = {
        legend: {
            display: true,
            position: 'top',
            labels: {
                fontColor: 'black'
            }
        }
    };

    var lineChart = new Chart(speedCanvas, {
        type: 'line',
        data: speedData,
        options: chartOptions
    });
};

async function show_data_1() {
    const route = 'http://127.0.0.1:8000/data1';
    let resp = await fetch(route);
    let data = await resp.json();
    var x = [];
    var solution_initiale = [];
    var solution_finale = [];
    var solution_analytique = [];

    for (let i = 0; i < data.solution_initiale.length; i++) {
        x.push(data.solution_initiale[i].x);
        solution_initiale.push(data.solution_initiale[i].y);
    }
    for (let i = 0; i < data.solution_finale.length; i++) {
        solution_finale.push(data.solution_finale[i].y);
    }
    for (let i = 0; i < data.solution_analytique.length; i++) {
        solution_analytique.push(data.solution_analytique[i].y);
    }
    
    var dataContainer = document.getElementById('data');
    var content = '';
    content += '<thead><tr><th scope="col">x</th><th scope="col">solution_initiale</th><th scope="col">solution_finale</th><th scope="col">solution_analytique</th></tr></thead><tbody>'
    for (let i = 0; i < data.solution_initiale.length; i++) {
        content += '<tr><td>' + data.solution_initiale[i].x + '</td><td>' + data.solution_initiale[i].y + '</td><td>' + data.solution_finale[i].y + '</td><td>' + data.solution_analytique[i].y + '</td></tr>';
    }
    content += '</tbody>'
    dataContainer.innerHTML = content;
};

async function show_data_2() {
    const route = 'http://127.0.0.1:8000/data2';
    let resp = await fetch(route);
    let data = await resp.json();
    var x = [];
    var solution_initiale = [];
    var solution_finale = [];
    var solution_analytique = [];

    for (let i = 0; i < data.solution_initiale.length; i++) {
        x.push(data.solution_initiale[i].x);
        solution_initiale.push(data.solution_initiale[i].y);
    }
    for (let i = 0; i < data.solution_finale.length; i++) {
        solution_finale.push(data.solution_finale[i].y);
    }
    for (let i = 0; i < data.solution_analytique.length; i++) {
        solution_analytique.push(data.solution_analytique[i].y);
    }
    
    var dataContainer = document.getElementById('data');
    var content = '';
    content += '<thead><tr><th scope="col">x</th><th scope="col">solution_initiale</th><th scope="col">solution_finale</th><th scope="col">solution_analytique</th></tr></thead><tbody>'
    for (let i = 0; i < data.solution_initiale.length; i++) {
        content += '<tr><td>' + data.solution_initiale[i].x + '</td><td>' + data.solution_initiale[i].y + '</td><td>' + data.solution_finale[i].y + '</td><td>' + data.solution_analytique[i].y + '</td></tr>';
    }
    content += '</tbody>'
    dataContainer.innerHTML = content;
};

async function saveData(data) {
    start_loading();
    var url = "http://127.0.0.1:8000/saveData"
    const response = await fetch(url, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(data)
    });
    return response.json();
    end_loading();
};

async function runFortran(data) {
    start_loading();
    var url = "http://127.0.0.1:8000/runFortran"
    const response = await fetch(url, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(data)
    });
    return response.json();
    end_loading();
};

async function loadMarkdown(data) {
    start_loading();
    var url = "http://127.0.0.1:8000/loadMarkdown"
    const response = await fetch(url, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(data)
    });
    let content = await response.json()
    var codeContainer = document.getElementById(data.id);
    codeContainer.innerHTML = content.html;
    end_loading();
};

async function loadHome(data) {
    start_loading();
    var url = "http://127.0.0.1:8000/loadHome"
    let resp = await fetch(url);
    let content = await resp.json();
    var codeContainer = document.getElementById(data.id);
    codeContainer.innerHTML = content.html;
    console.log(content.error);
    end_loading();
};

async function load_input(data) {
    start_loading();
    var name = data.name
    var chemin = '../Projet_scientifique/' + name + '/input.dat';
    fetch(chemin)
        .then(response => response.text())
        .then(data => {
            const variables = data.split("\n")
                .map(line => line.trim().split(" "))
                .reduce((obj, [key, value]) => ({ ...obj, [key]: value }), {});
            const bloc = document.getElementById("input");
            const form = document.createElement("form");
            for (const key in variables) {
                const row = document.createElement("div");
                row.classList.add("row", "mb-3");
                const label = document.createElement("label");
                label.classList.add("col-sm-7", "col-form-label");
                label.textContent = key;
                const inputDiv = document.createElement("div");
                inputDiv.classList.add("col-sm-4");
                const input = document.createElement("input");
                input.type = "text";
                input.classList.add("form-control");
                input.id = key;
                input.value = variables[key];
                inputDiv.appendChild(input);
                row.appendChild(label);
                row.appendChild(inputDiv);
                form.appendChild(row);
            }
            const button = document.createElement("button");
            button.type = "submit";
            button.classList.add("btn", "btn-primary");
            button.textContent = "Calculer";
            form.appendChild(button);
            if (name == "etape_finale") {
                const button = document.createElement("button");
                button.type = "submit";
                button.style.marginLeft = 5;
                button.classList.add("btn", "btn-primary");
                button.textContent = "Calculer en parallèle";
                form.appendChild(button);
            }
            bloc.appendChild(form);
            form.addEventListener("submit", (event) => {
                event.preventDefault();
                for (const key in variables) {
                    if (variables.hasOwnProperty(key)) {
                        const input = document.getElementById(key);
                        if (input) {
                            variables[key] = input.value;
                        }
                    }
                }
                const newContent = Object.entries(variables)
                    .map(([key, value]) => `${key} ${value}`)
                    .join("\n");
                console.log(newContent);

                var chemin1 = 'Projet_scientifique/' + name + '/input.dat';
                saveData({path: chemin1, text: newContent});
                var chemin2 = 'Projet_scientifique/' + name + '/' + name + '.f90';
                runFortran({path: chemin2});
                location.reload();
            });
        });
        end_loading();
};


async function start_loading() {
    document.getElementById("loading-container").style.display = "flex";
};
async function end_loading() {
    document.getElementById("loading-container").style.display = "none";
};