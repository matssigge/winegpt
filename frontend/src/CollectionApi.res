type headers = Js.Dict.t<string>
type postOptions
type getOptions
type createCollectionPayload

@module("./apiClient.js")
external requestWithPost: (string, postOptions) => promise<string> = "request"

@module("./apiClient.js")
external requestWithGet: (string, getOptions) => promise<string> = "request"

@module("./apiClient.js")
external authHeaders: (string, headers) => headers = "authHeaders"

@module("./apiClient.js")
external jsonHeaders: headers = "jsonHeaders"

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

let stringify = value => value->Js.Json.stringifyAny->Belt.Option.getExn

let listCollections = token =>
  requestWithGet(
    "/api/collections",
    makeGetOptions(~headers=authHeaders(token, Js.Dict.empty()), ()),
  )

let createCollection = (token, name) =>
  requestWithPost(
    "/api/collections",
    makePostOptions(
      ~method_="POST",
      ~headers=authHeaders(token, jsonHeaders),
      ~body=makeCreateCollectionPayload(~name, ())->stringify,
      (),
    ),
  )
