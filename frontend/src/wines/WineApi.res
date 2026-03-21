type headers = Js.Dict.t<string>
type getOptions

@obj
external makeGetOptions: (~headers: headers, unit) => getOptions = ""

let listWines = (token, collectionId) =>
  ApiClient.request(
    "/api/collections/" ++ collectionId->Belt.Int.toString ++ "/wines",
    makeGetOptions(~headers=ApiClient.authHeaders(token, Js.Dict.empty()), ()),
  )
