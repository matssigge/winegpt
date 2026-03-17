type headers = Js.Dict.t<string>
type postOptions
type getOptions
type registerPayload
type loginPayload

@module("./ApiClient.bs.js")
external requestWithPost: (string, postOptions) => promise<string> = "request"

@module("./ApiClient.bs.js")
external requestWithGet: (string, getOptions) => promise<string> = "request"

@module("./ApiClient.bs.js")
external authHeaders: (string, headers) => headers = "authHeaders"

@module("./ApiClient.bs.js")
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
external makeRegisterPayload: (
  ~email: string,
  @as("full_name") ~fullName: string,
  ~password: string,
  unit,
) => registerPayload = ""

@obj
external makeLoginPayload: (~email: string, ~password: string, unit) => loginPayload = ""

let stringify = value => value->Js.Json.stringifyAny->Belt.Option.getExn

let register = (email, fullName, password) =>
  requestWithPost(
    "/api/auth/register",
    makePostOptions(
      ~method_="POST",
      ~headers=jsonHeaders,
      ~body=makeRegisterPayload(~email, ~fullName, ~password, ())->stringify,
      (),
    ),
  )

let login = (email, password) =>
  requestWithPost(
    "/api/auth/login",
    makePostOptions(
      ~method_="POST",
      ~headers=jsonHeaders,
      ~body=makeLoginPayload(~email, ~password, ())->stringify,
      (),
    ),
  )

let me = token =>
  requestWithGet(
    "/api/me",
    makeGetOptions(~headers=authHeaders(token, Js.Dict.empty()), ()),
  )
