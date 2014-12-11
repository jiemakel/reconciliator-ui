angular.module('app').controller 'MainCtrl', ($scope) !->
  $scope.handleError = (response) !->
    $scope.errorSource = response.config.url
    $scope.errorStatus = response.status + ( if (response.statusText) then " ("+response.statusText+")" else "")
    $scope.errorRequest = response.config.data ? response.config.params?.query
    $scope.errorMessage = response.data
    $scope.showError = true
