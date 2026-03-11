(function () {
  const palette = ['#3b82f6', '#06b6d4', '#22c55e', '#f59e0b', '#f97316', '#ef4444', '#8b5cf6', '#ec4899'];

  function resolveCanvas(canvasId) {
    if (!canvasId) return null;
    return typeof canvasId === 'string' ? document.getElementById(canvasId) : canvasId;
  }

  function destroyExistingChart(canvas) {
    if (canvas && canvas.__chartInstance) {
      canvas.__chartInstance.destroy();
    }
  }

  function baseOptions(extra) {
    return Object.assign({
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          labels: {
            color: '#cbd5e1',
            boxWidth: 12,
            usePointStyle: true
          }
        },
        tooltip: {
          backgroundColor: 'rgba(15, 23, 42, 0.96)',
          borderColor: 'rgba(148, 163, 184, 0.18)',
          borderWidth: 1,
          titleColor: '#f8fafc',
          bodyColor: '#cbd5e1',
          padding: 12
        }
      },
      scales: {
        x: {
          ticks: { color: '#94a3b8' },
          grid: { color: 'rgba(148, 163, 184, 0.08)' }
        },
        y: {
          ticks: { color: '#94a3b8' },
          grid: { color: 'rgba(148, 163, 184, 0.08)' }
        }
      }
    }, extra || {});
  }

  function createChart(canvasId, config) {
    const canvas = resolveCanvas(canvasId);
    if (!canvas || typeof Chart === 'undefined') return null;

    destroyExistingChart(canvas);
    const instance = new Chart(canvas, config);
    canvas.__chartInstance = instance;
    return instance;
  }

  window.renderLineChart = function (canvasId, labels, datasets, options) {
    return createChart(canvasId, {
      type: 'line',
      data: { labels: labels || [], datasets: datasets || [] },
      options: baseOptions(options)
    });
  };

  window.renderBarChart = function (canvasId, labels, data, options) {
    return createChart(canvasId, {
      type: 'bar',
      data: {
        labels: labels || [],
        datasets: [{
          label: (options && options.label) || '',
          data: data || [],
          backgroundColor: (options && options.backgroundColor) || palette[0],
          borderRadius: 10,
          maxBarThickness: 42
        }]
      },
      options: baseOptions(options)
    });
  };

  window.renderHorizontalBarChart = function (canvasId, labels, data, options) {
    return createChart(canvasId, {
      type: 'bar',
      data: {
        labels: labels || [],
        datasets: [{
          label: (options && options.label) || '',
          data: data || [],
          backgroundColor: (options && options.backgroundColor) || palette.slice(0, Math.max((data || []).length, 1)),
          borderRadius: 10
        }]
      },
      options: baseOptions(Object.assign({ indexAxis: 'y' }, options || {}))
    });
  };

  window.renderDoughnutChart = function (canvasId, labels, data, options) {
    return createChart(canvasId, {
      type: 'doughnut',
      data: {
        labels: labels || [],
        datasets: [{
          data: data || [],
          backgroundColor: palette,
          borderColor: 'rgba(15, 23, 42, 0.9)',
          borderWidth: 3
        }]
      },
      options: Object.assign(baseOptions({
        scales: {},
        cutout: '64%'
      }), options || {})
    });
  };

  window.getChartPalette = function () {
    return palette.slice();
  };
})();
