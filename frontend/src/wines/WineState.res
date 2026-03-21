type summary = WineModel.summary

type status =
  | Idle
  | Loading
  | Ready(array<summary>)
  | Error(string)

let initialStatus = () => Idle
let loadingStatus = () => Loading
let readyStatus = wines => Ready(wines)
let errorStatus = message => Error(message)

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

let listWines = (token, collectionId) =>
  Js.Promise2.then(
    WineApi.listWines(token, collectionId),
    response =>
      switch response->ResponseDecoder.parse->Belt.Option.flatMap(ResponseDecoder.wineSummaries) {
      | Some(wines) => Js.Promise2.resolve(wines)
      | None => Js.Promise2.reject(ApiClient.invalidResponse())
      },
  )
