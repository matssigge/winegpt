type headers = Js.Dict.t<string>
type postOptions
type getOptions
type createCollectionPayload
type inviteCollectionPayload

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
external makeCreateCollectionPayload: (~name: string, unit) => createCollectionPayload = ""

@obj
external makeInviteCollectionPayload: (~email: string, unit) => inviteCollectionPayload = ""

let stringify = value => value->Js.Json.stringifyAny->Belt.Option.getExn

let listCollections = token =>
  ApiClient.request(
    "/api/collections",
    makeGetOptions(~headers=ApiClient.authHeaders(token, Js.Dict.empty()), ()),
  )

let createCollection = (token, name) =>
  ApiClient.request(
    "/api/collections",
    makePostOptions(
      ~method_="POST",
      ~headers=ApiClient.authHeaders(token, ApiClient.jsonHeaders),
      ~body=makeCreateCollectionPayload(~name, ())->stringify,
      (),
    ),
  )

let inviteCollectionMember = (token, collectionId, email) =>
  ApiClient.request(
    "/api/collections/" ++ collectionId->Belt.Int.toString ++ "/invites",
    makePostOptions(
      ~method_="POST",
      ~headers=ApiClient.authHeaders(token, ApiClient.jsonHeaders),
      ~body=makeInviteCollectionPayload(~email, ())->stringify,
      (),
    ),
  )
