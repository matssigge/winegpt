type headers = Js.Dict.t<string>
type postOptions
type getOptions
type registerPayload
type loginPayload

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
  ApiClient.request(
    "/api/auth/register",
    makePostOptions(
      ~method_="POST",
      ~headers=ApiClient.jsonHeaders,
      ~body=makeRegisterPayload(~email, ~fullName, ~password, ())->stringify,
      (),
    ),
  )

let login = (email, password) =>
  ApiClient.request(
    "/api/auth/login",
    makePostOptions(
      ~method_="POST",
      ~headers=ApiClient.jsonHeaders,
      ~body=makeLoginPayload(~email, ~password, ())->stringify,
      (),
    ),
  )

let me = token =>
  ApiClient.request(
    "/api/me",
    makeGetOptions(~headers=ApiClient.authHeaders(token, Js.Dict.empty()), ()),
  )
