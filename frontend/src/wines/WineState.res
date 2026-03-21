type summary = WineModel.summary

type occasionFilter =
  | All
  | WithOccasions
  | WithoutOccasions

@send
external toLowerCase: string => string = "toLowerCase"

@send
external includes: (string, string) => bool = "includes"

type status =
  | Idle
  | Loading
  | Ready(array<summary>)
  | Error(string)

let initialStatus = () => Idle
let loadingStatus = () => Loading
let readyStatus = wines => Ready(wines)
let errorStatus = message => Error(message)
let initialOccasionFilter = All

let wines = status =>
  switch status {
  | Ready(wines) => wines
  | Idle | Loading | Error(_) => []
  }

let isReady = status =>
  switch status {
  | Ready(_) => true
  | Idle | Loading | Error(_) => false
  }

let searchableText = (summary: summary) =>
  Belt.Array.keepMap(
    [
      Some(summary.wine.name),
      summary.wine.producer,
      summary.wine.grape,
      summary.wine.vintage->Belt.Option.map(Belt.Int.toString),
    ],
    value => value,
  )
  ->Js.Array2.joinWith(" ")
  ->toLowerCase

let matchesOccasionFilter = (summary: summary, occasionFilter) =>
  switch occasionFilter {
  | All => true
  | WithOccasions => summary.entryCount > 0
  | WithoutOccasions => summary.entryCount == 0
  }

let filterWines = (wines: array<summary>, query: string, occasionFilter) => {
  let normalizedQuery = query->String.trim->toLowerCase

  wines->Belt.Array.keep(summary => {
    let matchesQuery =
      if normalizedQuery == "" {
        true
      } else {
        summary->searchableText->includes(normalizedQuery)
      }

    matchesQuery && matchesOccasionFilter(summary, occasionFilter)
  })
}

let filterStatus = (status, query: string, occasionFilter) =>
  switch status {
  | Ready(wines) => Ready(filterWines(wines, query, occasionFilter))
  | Idle => Idle
  | Loading => Loading
  | Error(message) => Error(message)
  }

let listWines = (token, collectionId) =>
  Js.Promise2.then(
    WineApi.listWines(token, collectionId),
    response =>
      switch response->ResponseDecoder.parse->Belt.Option.flatMap(ResponseDecoder.wineSummaries) {
      | Some(wines) => Js.Promise2.resolve(wines)
      | None => Js.Promise2.reject(ApiClient.invalidResponse())
      },
  )
