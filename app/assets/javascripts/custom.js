$(document).on('turbolinks:load', function() {
  $('.select2').select2();
  $('.dataTable').DataTable();

  if($('#price_variation_chart').length) {
    var price_chart = document.getElementById("price_variation_chart").getContext('2d');
    var theme_g1 = price_chart.createLinearGradient(0,0,500,0);
    theme_g1.addColorStop(0,'rgba(29, 233, 182, 0.4)');
    theme_g1.addColorStop(1,'rgba(29, 196, 233, 0.5)');
    console.log($(price_chart).data('labels'))
    console.log($(price_chart).data('prices'))
    var data1 = {
                  labels: $('#price_variation_chart').data('labels'),
                  datasets: [
                    {
                      label: $('.bag-name').text(),
                      data: $('#price_variation_chart').data('prices'),
                      fill: false,
                      borderWidth: 4,
                      borderColor: "#04a9f5",
                      backgroundColor:"#04a9f5",
                      tooltips: {
                        enabled: false
                      }
                    }]
                  };
    var new_price_chart = new Chart(price_chart, { type: 'line', data: data1, responsive: true });
  }
});