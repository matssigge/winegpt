type headers = Js.Dict.t<string>
type getOptions
type postOptions
type winePayload

@obj
external makeGetOptions: (~headers: headers, unit) => getOptions = ""

@obj
external makePostOptions: (
  @as("method") ~method_: string,
  ~headers: headers,
  ~body: string,
  unit,
) => postOptions = ""

@obj
external makeWinePayload: (
  ~producer: option<string>,
  ~name: string,
  ~vintage: option<int>,
  ~style: option<string>,
  ~grape: option<string>,
  ~region: option<string>,
  ~country: option<string>,
  unit,
) => winePayload = ""

let stringify = value => value->Js.Json.stringifyAny->Belt.Option.getExn

let listWines = (token, collectionId) =>
  ApiClient.request(
    "/api/collections/" ++ collectionId->Belt.Int.toString ++ "/wines",
    makeGetOptions(~headers=ApiClient.authHeaders(token, Js.Dict.empty()), ()),
  )

let createWine = (
  token,
  collectionId,
  ~producer: option<string>,
  ~name,
  ~vintage: option<int>,
  ~style: option<string>=?,
  ~grape: option<string>=?,
  ~region: option<string>=?,
  ~country: option<string>=?,
  (),
) => {
  let style = style
  let grape = grape
  let region = region
  let country = country

  ApiClient.request(
    "/api/collections/" ++ collectionId->Belt.Int.toString ++ "/wines",
    makePostOptions(
      ~method_="POST",
      ~headers=ApiClient.authHeaders(token, ApiClient.jsonHeaders),
      ~body=
        makeWinePayload(
          ~producer,
          ~name,
          ~vintage,
          ~style,
          ~grape,
          ~region,
          ~country,
          (),
        )->stringify,
      (),
    ),
  )
}
