type headers = Js.Dict.t<string>
type postOptions
type getOptions
type winePayload
type createEntryPayload

@obj
external makePostOptions: (
  @as("method") ~method_: string,
  ~headers: headers,
  ~body: string,
  unit,
) => postOptions = ""

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

@obj
external makeCreateEntryPayload: (
  ~wine: winePayload,
  ~consumed_at: string,
  ~venue_name: option<string>,
  ~location_text: option<string>,
  ~pairing_notes: option<string>,
  ~tasting_notes: option<string>,
  ~rating: option<int>,
  unit,
) => createEntryPayload = ""

let stringify = value => value->Js.Json.stringifyAny->Belt.Option.getExn

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
  ~consumedAt,
  ~venueName: option<string>,
  ~locationText: option<string>,
  ~pairingNotes: option<string>,
  ~tastingNotes: option<string>,
  ~rating: option<int>,
  (),
) =>
  {
    let style = style
    let grape = grape
    let region = region
    let country = country
    let venue_name = venueName
    let location_text = locationText
    let pairing_notes = pairingNotes
    let tasting_notes = tastingNotes

  ApiClient.request(
    "/api/collections/" ++ collectionId->Belt.Int.toString ++ "/entries",
    makePostOptions(
      ~method_="POST",
      ~headers=ApiClient.authHeaders(token, ApiClient.jsonHeaders),
      ~body=
        makeCreateEntryPayload(
          ~wine=
            makeWinePayload(
              ~producer,
              ~name,
              ~vintage,
              ~style,
              ~grape,
              ~region,
              ~country,
              (),
            ),
          ~consumed_at=consumedAt,
          ~venue_name,
          ~location_text,
          ~pairing_notes,
          ~tasting_notes,
          ~rating,
          (),
        )->stringify,
      (),
    ),
  )
  }
