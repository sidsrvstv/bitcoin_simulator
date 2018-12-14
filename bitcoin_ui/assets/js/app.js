// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"

var chart1, chart2, chart3, chart4;

function renderNonceChart(data, labels) {
  var ctx = document.getElementById("nonceChart").getContext('2d');
  var chart3 = new Chart(ctx, {
      type: 'line',
      data: {
          labels: labels,
          datasets: [{
              label: 'Nonce vs time',
              data: data,
          }]
      },
      options: {
        animation: {
          duration: 0
        }
      }
  });
}

function renderTotalChart(data, labels) {
  var ctx = document.getElementById("totalChart").getContext('2d');
  var chart4 = new Chart(ctx, {
      type: 'line',
      data: {
          labels: labels,
          datasets: [{
              label: 'Total Bitcoins vs time',
              data: data,
          }]
      },
      options: {
        animation: {
          duration: 0
        }
      }
  });
}

function renderChart(data, labels) {
    var ctx = document.getElementById("myChart").getContext('2d');
    var chart1 = new Chart(ctx, {
        type: 'line',
        data: {
            labels: labels,
            datasets: [{
                label: 'Transaction vs time',
                data: data,
            }]
        },
        options: {
          animation: {
            duration: 0
          }
        }
    });
}

function makeChart(data, labels) {
        var ctx = document.getElementById("myChart2").getContext('2d');
        var chart2 = new Chart(ctx, {
            type: 'line',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Months',
                    data: data,
                }]
            },
            options: {
              animation: {
                duration: 0
              }
            }
        });
}

$(function(){
      //Stop button click
      $(".stop").click(function(){
        clearInterval(timer);
        clearInterval(timer2);
        clearInterval(timer3);
        clearInterval(timer4);
      });

      var timer = setInterval(function() {
       $.getJSON('/test', { get_param: 'value' }, function(data) {
         var x=[], y = [];
           $.each(data, function(index, element) {
             x.push(element.age);
             y.push(element.name);
           });
           makeChart(x,y);
       });
     }, 1000);

     var timer2 = setInterval(function() {
      $.getJSON('/transactiontime', { get_param: 'value' }, function(data) {
        var x=[], y = [];
          $.each(data, function(index, element) {
            x.push(element.x);
            y.push(element.y);
          });
          renderChart(y,x);
      });
    }, 500);

    var timer3 = setInterval(function() {
      $.getJSON('/nonce', { get_param: 'value' }, function(data) {
        var x=[], y = [];
          $.each(data, function(index, element) {
            x.push(element.x);
            y.push(element.y);
          });
          renderNonceChart(y,x);
      });
    }, 500);

    var timer4 = setInterval(function() {
      $.getJSON('/total', { get_param: 'value' }, function(data) {
        var x=[], y = [];
          $.each(data, function(index, element) {
            x.push(element.x);
            y.push(element.y);
          });
          renderTotalChart(y,x);
      });
    }, 500);
});


// function float2dollar(value){
//     return "U$ "+(value).toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,');
// }

// function renderChart(data, labels) {
//     var ctx = document.getElementById("myChart").getContext('2d');
//     var myChart = new Chart(ctx, {
//         type: 'line',
//         data: {
//             labels: labels,
//             datasets: [{
//                 label: 'This week',
//                 data: data,
//                 borderColor: 'rgba(75, 192, 192, 1)',
//                 backgroundColor: 'rgba(75, 192, 192, 0.2)',
//             }]
//         },
//         options: {            
//             scales: {
//                 yAxes: [{
//                     ticks: {
//                         beginAtZero: true,
//                         callback: function(value, index, values) {
//                             return float2dollar(value);
//                         }
//                     }
//                 }]                
//             }
//         },
//     });
// }

// function renderChart2(data, labels) {
//     var ctx = document.getElementById("myChart2").getContext('2d');
//     var myChart = new Chart(ctx, {
//         type: 'line',
//         data: {
//             labels: labels,
//             datasets: [{
//                 label: 'This week',
//                 data: data,
//                 borderColor: 'rgba(75, 192, 192, 1)',
//                 backgroundColor: 'rgba(75, 192, 110, 0.2)',
//             }]
//         },
//         options: {            
//             scales: {
//                 yAxes: [{
//                     ticks: {
//                         beginAtZero: true,
//                         callback: function(value, index, values) {
//                             return float2dollar(value);
//                         }
//                     }
//                 }]                
//             }
//         },
//     });
// }

// $("#renderBtn").click(
//     function () {
//         var data = [20000, 14000, 12000, 15000, 18000, 19000, 22000];
//         var labels =  ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"];
//         renderChart(data, labels);
//     }
// );

//     var data = [20000, 14000, 12000, 15000, 18000, 19000, 22000];
//     var labels =  ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"];
//     renderChart2(data, labels);
