angular.module('app', [ 'ui.router','toastr' ])
  .constant 'services','http://localhost:9000/'
  .config ($stateProvider, $urlRouterProvider) !->
    $urlRouterProvider.otherwise '/'
    $stateProvider.state 'main',
      abstract:true
      templateUrl: 'partials/main.html'
      controller:'MainCtrl'
    $stateProvider.state 'main.services',
      url: '/'
      templateUrl: 'partials/services.html'
      controller:'ServicesCtrl'
    $stateProvider.state 'main.service',
      url: '/:service'
      templateUrl: 'partials/service.html'
      controller:'ServiceCtrl'
  .config (toastrConfig) !->
    angular.extend toastrConfig,
      allowHtml: false
      closeButton: false
      closeHtml: '<button>&times;</button>'
      containerId: 'toast-container'
      extendedTimeOut: 1000
      iconClasses:
        error: 'toast-error'
        info: 'toast-info'
        success: 'toast-success'
        warning: 'toast-warning'
      messageClass: 'toast-message'
      positionClass: 'toast-top-full-width'
      tapToDismiss: true
      timeOut: 1500
      titleClass: 'toast-title'
      toastClass: 'toast'

