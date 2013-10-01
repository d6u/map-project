# ThePlacesSearch service

## API

1. getSearchPredictions(input)

    - input: (String) string which search prediction will be based on
    - return: (Promise) resolve into an array of predictions

2. searchPlacesWith(query)

    - query: (String) search term
    - return: (Promise) places array

    This method also put search results into `$searchResults` property

## Properties

1. $searchResults: (Array) contains last place service search results
