{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  serviceWorker: {
    serviceWorkerVersion: '{{flutter_service_worker_version}}',
  },
  onEntrypointLoaded: function(engineInitializer) {
    engineInitializer.initializeEngine().then(function(appRunner) {
      appRunner.runApp();
    });
  }
}); 