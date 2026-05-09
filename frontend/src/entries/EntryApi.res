type headers = Js.Dict.t<string>
type postOptions
type getOptions
type patchOptions
type winePayload

@obj
external makePostOptions: (
  @as("method") ~method_: string,
  ~headers: headers,
  ~body: string,
  unit,
) => postOptions = ""

@obj
external makePatchOptions: (
  @as("method") ~method_: string,
  ~headers: headers,
  ~body: string,
  unit,
) => patchOptions = ""

@obj
external makeGetOptions: (~headers: headers, unit) => getOptions = ""

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

let buildEntryBody = (
  ~wine: winePayload,
  ~consumedAt: option<string>,
  ~venueName: option<string>,
  ~locationText: option<string>,
  ~pairingNotes: option<string>,
  ~tastingNotes: option<string>,
  ~rating: option<int>,
) => {
  let payload = Js.Dict.empty()
  payload->Js.Dict.set("wine", wine->Obj.magic)
  payload->Js.Dict.set(
    "consumed_at",
    consumedAt->Belt.Option.mapWithDefault(Js.Json.null, Js.Json.string),
  )
  payload->Js.Dict.set(
    "venue_name",
    venueName->Belt.Option.mapWithDefault(Js.Json.null, Js.Json.string),
  )
  payload->Js.Dict.set(
    "location_text",
    locationText->Belt.Option.mapWithDefault(Js.Json.null, Js.Json.string),
  )
  payload->Js.Dict.set(
    "pairing_notes",
    pairingNotes->Belt.Option.mapWithDefault(Js.Json.null, Js.Json.string),
  )
  payload->Js.Dict.set(
    "tasting_notes",
    tastingNotes->Belt.Option.mapWithDefault(Js.Json.null, Js.Json.string),
  )
  payload->Js.Dict.set(
    "rating",
    rating->Belt.Option.mapWithDefault(
      Js.Json.null,
      n => Js.Json.number(n->Belt.Int.toFloat),
    ),
  )
  payload->stringify
}

let listEntries = (token, collectionId) =>
  ApiClient.request(
    "/api/collections/" ++ collectionId->Belt.Int.toString ++ "/entries",
    makeGetOptions(~headers=ApiClient.authHeaders(token, Js.Dict.empty()), ()),
  )

let createEntry = (
  token,
  collectionId,
  ~producer: option<string>,
  ~name,
  ~vintage: option<int>,
  ~style: option<string>=?,
  ~grape: option<string>=?,
  ~region: option<string>=?,
  ~country: option<string>=?,
  ~consumedAt: option<string>,
  ~venueName: option<string>,
  ~locationText: option<string>,
  ~pairingNotes: option<string>,
  ~tastingNotes: option<string>,
  ~rating: option<int>,
  (),
) => {
  let style = style
  let grape = grape
  let region = region
  let country = country

  ApiClient.request(
    "/api/collections/" ++ collectionId->Belt.Int.toString ++ "/entries",
    makePostOptions(
      ~method_="POST",
      ~headers=ApiClient.authHeaders(token, ApiClient.jsonHeaders),
      ~body=buildEntryBody(
        ~wine=makeWinePayload(~producer, ~name, ~vintage, ~style, ~grape, ~region, ~country, ()),
        ~consumedAt,
        ~venueName,
        ~locationText,
        ~pairingNotes,
        ~tastingNotes,
        ~rating,
      ),
      (),
    ),
  )
}

let updateEntry = (
  token,
  collectionId,
  entryId,
  ~producer: option<string>,
  ~name,
  ~vintage: option<int>,
  ~style: option<string>=?,
  ~grape: option<string>=?,
  ~region: option<string>=?,
  ~country: option<string>=?,
  ~consumedAt: option<string>,
  ~venueName: option<string>,
  ~locationText: option<string>,
  ~pairingNotes: option<string>,
  ~tastingNotes: option<string>,
  ~rating: option<int>,
  (),
) => {
  let style = style
  let grape = grape
  let region = region
  let country = country

  ApiClient.request(
    "/api/collections/" ++
    collectionId->Belt.Int.toString ++
    "/entries/" ++
    entryId->Belt.Int.toString,
    makePatchOptions(
      ~method_="PATCH",
      ~headers=ApiClient.authHeaders(token, ApiClient.jsonHeaders),
      ~body=buildEntryBody(
        ~wine=makeWinePayload(~producer, ~name, ~vintage, ~style, ~grape, ~region, ~country, ()),
        ~consumedAt,
        ~venueName,
        ~locationText,
        ~pairingNotes,
        ~tastingNotes,
        ~rating,
      ),
      (),
    ),
  )
}
