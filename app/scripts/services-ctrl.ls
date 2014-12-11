angular.module('app').controller 'ServicesCtrl', ($scope,$http,$state,services) !->
  $scope.newService = (service) !->
    $state.go('main.service',{service})
  response <-! $http.get(services+"services").then(_,$scope.handleError)
  $scope.services = response.data
