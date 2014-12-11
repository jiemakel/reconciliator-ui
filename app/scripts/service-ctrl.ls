angular.module('app').controller 'ServiceCtrl', ($scope,$http,$stateParams,toastr,services) !->
  $scope.service = $stateParams.service
  $scope.name=$scope.service
  $scope.queries =
    'Generic':
      suggestTypeQuery : '''
        PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
        PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
        SELECT ?value ?label ?type ?typeLabel {
          {
            SELECT DISTINCT ?value {
              {
                SELECT DISTINCT ?value {
                  ?entity a ?value .
                }
              }
              BIND(LCASE(<QUERY>) AS ?queryTerm)
              ?value rdfs:label|skos:prefLabel ?label .
              FILTER(STRSTARTS(LCASE(STR(?label)),?queryTerm))
            }
            LIMIT 40
          }
          ?value rdfs:label|skos:prefLabel ?label .
          OPTIONAL {
            ?value a ?type .
            OPTIONAL {
              ?type rdfs:label|skos:prefLabel ?typeLabel .
            }
          }
        }
      '''
      suggestPropertyQuery : '''
        PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
        PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
        SELECT ?value ?label ?type ?typeLabel {
          {
            SELECT DISTINCT ?value {
              {
                SELECT DISTINCT ?value {
                  # TYPE_FILTER
                  ?entity ?value ?v .
                }
              }
              BIND(LCASE(<QUERY>) AS ?queryTerm)
              ?value rdfs:label|skos:prefLabel ?label .
              FILTER(STRSTARTS(LCASE(STR(?label)),?queryTerm))
            }
            LIMIT 40
          }
          ?value rdfs:label|skos:prefLabel ?label .
          OPTIONAL {
            ?value a ?type .
            OPTIONAL {
              ?type rdfs:label|skos:prefLabel ?typeLabel .
            }
          }
        }
      '''
      suggestEntityQuery : '''
        PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
        PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
        SELECT ?value ?label ?type ?typeLabel {
          {
            SELECT DISTINCT ?value {
              BIND(LCASE(<QUERY>) AS ?queryTerm)
              # TYPE_FILTER
              BIND(?entity AS ?value)
              ?value rdfs:label|skos:prefLabel ?label .
              FILTER(STRSTARTS(LCASE(STR(?label)),?queryTerm))
            }
            LIMIT 40
          }
          ?value rdfs:label|skos:prefLabel ?label .
          OPTIONAL {
            ?value a ?type .
            OPTIONAL {
              ?type rdfs:label|skos:prefLabel ?typeLabel .
            }
          }
        }
      '''
      reconcileQuery : '''
        PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
        PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
        SELECT DISTINCT ?queryId ?entity ?label ?type {
          { # QUERY
            SELECT ?queryId ?entity ?queryTerm {
              BIND(<QUERY_ID> AS ?queryId)
              BIND(<QUERY> AS ?queryTerm)
              ?entity rdfs:label|skos:prefLabel|skos:altLabel ?queryTerm .
              # TYPE_FILTER
              # PROPERTY_FILTERS
            } LIMIT 0
          } # /QUERY
          BIND(?queryTerm AS ?label)
          ?entity a ?type .
        }
      '''
      typeFilter : '?entity a <TYPE> .'
      propertyFilter : '?entity <PROPERTY> <VALUE> .'
    'Jena-Text':
      suggestTypeQuery : '''
        PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
        PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
        PREFIX text: <http://jena.apache.org/text#>
        SELECT ?value ?label ?type ?typeLabel {
          {
            SELECT DISTINCT ?value {
              BIND(CONCAT(<QUERY>,'*') AS ?queryTerm)
              ?value text:query ?queryTerm .
              ?value rdfs:label|skos:prefLabel ?label .
              FILTER(STRSTARTS(LCASE(STR(?label)),LCASE(<QUERY>)))
              FILTER EXISTS {
                ?entity a ?value .
              }
            }
            LIMIT 40
          }
          ?value rdfs:label|skos:prefLabel ?label .
          OPTIONAL {
            ?value a ?type .
            OPTIONAL {
              ?type rdfs:label|skos:prefLabel ?typeLabel .
            }
          }
        }
      '''
      suggestPropertyQuery : '''
        PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
        PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
        PREFIX text: <http://jena.apache.org/text#>
        SELECT ?value ?label ?type ?typeLabel {
          {
            SELECT DISTINCT ?value {
              BIND(CONCAT(<QUERY>,'*') AS ?queryTerm)
              ?value text:query ?queryTerm .
              ?value rdfs:label|skos:prefLabel ?label .
              FILTER(STRSTARTS(LCASE(STR(?label)),LCASE(<QUERY>)))
              FILTER EXISTS {
                ?entity ?value ?v .
                # TYPE_FILTER
              }
            }
            LIMIT 40
          }
          ?value rdfs:label|skos:prefLabel ?label .
          OPTIONAL {
            ?value a ?type .
            OPTIONAL {
              ?type rdfs:label|skos:prefLabel ?typeLabel .
            }
          }
        }
      '''
      suggestEntityQuery : '''
        PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
        PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
        PREFIX text: <http://jena.apache.org/text#>
        SELECT ?value ?label ?type ?typeLabel {
          {
            SELECT DISTINCT ?value {
              BIND(CONCAT(<QUERY>,'*') AS ?queryTerm)
              ?entity text:query ?queryTerm .
              # TYPE_FILTER
              BIND(?entity AS ?value)
              ?value rdfs:label|skos:prefLabel ?label .
              FILTER(STRSTARTS(LCASE(STR(?label)),LCASE(<QUERY>)))
            }
            LIMIT 40
          }
          ?value rdfs:label|skos:prefLabel ?label .
          OPTIONAL {
            ?value a ?type .
            OPTIONAL {
              ?type rdfs:label|skos:prefLabel ?typeLabel .
            }
          }
        }
      '''
      reconcileQuery : '''
        PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
        PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
        PREFIX text: <http://jena.apache.org/text#>
        PREFIX pf: <http://jena.hpl.hp.com/ARQ/property#>
        PREFIX sf: <http://ldf.fi/similarity-functions#>
        SELECT ?queryId ?entity ?label ?type ?score {
          { # QUERY
            {
              SELECT ?entity ?label (SUM(?s)/COUNT(?s) AS ?score) {
                {
                  SELECT ?entity {
                    BIND(CONCAT(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(<QUERY>,"([\\+\\-\\&\\|\\!\\(\\)\\{\\}\\[\\]\\^\\\"\\~\\*\\?\\:\\\\])","\\\\$1"),"^ +| +$", ""),",",""),"\\. ","* "),"([^*]) ","$1~0.8 "),"~0.8") AS ?queryTerm)
                    ?entity text:query ?queryTerm .
                    # TYPE_FILTER
                    # PROPERTY_FILTERS
                  } LIMIT 0
                }
                ?entity rdfs:label|skos:prefLabel|skos:altLabel ?label .
                ?str pf:strSplit (<QUERY> " ")
                BIND(sf:levenshteinSubstring(?str,STR(?label)) AS ?s)
              }
              GROUP BY ?entity ?label
            }
            BIND(<QUERY_ID> AS ?queryId)
            FILTER(BOUND(?entity))
          } # /QUERY
          ?entity a ?type .
        }
      '''
      typeFilter : '?entity a <TYPE> .'
      propertyFilter : '?entity <PROPERTY> <VALUE> .'
  $scope.$watch 'preset', (nv) !->
    for k,v of $scope.queries[nv]
      $scope[k]=v
  for k,v of $scope.queries['Generic']
    $scope[k]=v
  $scope.entityViewURL = '{{id}}'
  $scope.entityPreviewURL = '{{id}}'
  $scope.entityPreviewHeight = 430
  $scope.entityPreviewWidth = 400
  $scope.typeFlyoutURL = '${id}'
  $scope.typeFlyoutHeight = 430
  $scope.typeFlyoutWidth = 400
  $scope.propertyFlyoutURL = '${id}'
  $scope.propertyFlyoutHeight = 430
  $scope.propertyFlyoutWidth = 400
  $scope.entityFlyoutURL = '${id}'
  $scope.entityFlyoutHeight = 430
  $scope.entityFlyoutWidth = 400
  $scope.matchThreshold = 0.9
  $scope.delete = !->
    response <-! $http.delete(services+$scope.service).then(_,$scope.handleError)
    toastr.success("Successfully removed service #{$scope.service} (#{$scope.name})")
  $scope.submit = !->
    response <-! $http.put(services+$scope.service,{
      $scope.name
      $scope.endpointURL
      $scope.suggestTypeQuery
      $scope.suggestPropertyQuery
      $scope.reconcileQuery
      $scope.typeFilter
      $scope.propertyFilter
      $scope.suggestEntityQuery
      $scope.entityViewURL
      $scope.entityPreviewURL
      entityPreviewHeight:parseInt($scope.entityPreviewHeight)
      entityPreviewWidth:parseInt($scope.entityPreviewWidth)
      $scope.typeFlyoutURL
      typeFlyoutHeight:parseInt($scope.typeFlyoutHeight)
      typeFlyoutWidth:parseInt($scope.typeFlyoutWidth)
      $scope.propertyFlyoutURL
      propertyFlyoutHeight:parseInt($scope.propertyFlyoutHeight)
      propertyFlyoutWidth:parseInt($scope.propertyFlyoutWidth)
      $scope.entityFlyoutURL
      entityFlyoutHeight:parseInt($scope.entityFlyoutHeight)
      entityFlyoutWidth:parseInt($scope.entityFlyoutWidth)
      $scope.matchThreshold
    }).then(_,$scope.handleError)
    toastr.success("Successfully saved service #{$scope.service} (#{$scope.name})")
  $scope.loading = true
  response <-! $http.get(services+$scope.service+'/configuration').then(_,(response) !-> if response.status!=404 then $scope.handleError(response) else $scope.loading=false)
  $scope.loading=false
  for item,value of response.data
    $scope[item]=value
