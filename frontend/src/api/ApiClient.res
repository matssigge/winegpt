type location
type response
type error

@val
@scope("globalThis")
external locationUnsafe: Js.Nullable.t<location> = "location"

@val
@scope("import.meta.env")
external viteApiBaseUrlUnsafe: Js.Nullable.t<string> = "VITE_API_BASE_URL"

@get
external hostname: location => string = "hostname"

@get
external protocol: location => string = "protocol"

@val
external fetch: (string, 'options) => promise<response> = "fetch"

@new
external makeError: string => error = "Error"

@get
external ok: response => bool = "ok"

@send
external text: response => promise<string> = "text"

let jsonHeaders = {
  let headers = Js.Dict.empty()
  headers->Js.Dict.set("content-type", "application/json")
  headers
}

let defaultApiBaseUrl = () =>
  switch locationUnsafe->Js.Nullable.toOption {
  | None => "http://127.0.0.1:3000"
  | Some(currentLocation) =>
    let currentHostname = currentLocation->hostname
    let host = if currentHostname == "frontend" { "backend" } else { currentHostname }

    currentLocation->protocol ++ "//" ++ host ++ ":3000"
  }

let apiBaseUrl =
  switch viteApiBaseUrlUnsafe->Js.Nullable.toOption->Belt.Option.map(String.trim) {
  | Some(value) if value != "" => value
  | _ => defaultApiBaseUrl()
  }

let copyHeaders = headers => {
  let nextHeaders = Js.Dict.empty()

  headers
  ->Js.Dict.entries
  ->Belt.Array.forEach(((key, value)) => nextHeaders->Js.Dict.set(key, value))

  nextHeaders
}

let invalidResponse = () => makeError("invalid_response")->Obj.magic

let authHeaders = (token, extraHeaders) => {
  let headers = copyHeaders(extraHeaders)
  headers->Js.Dict.set("authorization", "Bearer " ++ token)
  headers
}

let extractError = body =>
  try {
    switch body->Js.Json.parseExn->Js.Json.decodeObject {
    | Some(parsed) =>
      switch parsed->Js.Dict.get("error") {
      | Some(value) =>
        switch value->Js.Json.decodeString {
        | Some(error) => error
        | None => "request_failed"
        }
      | None => "request_failed"
      }
    | None => "request_failed"
    }
  } catch {
  | _ => "request_failed"
  }

let request = (path, options) =>
  Js.Promise2.then(fetch(apiBaseUrl ++ path, options), response =>
    Js.Promise2.then(text(response), body =>
      if response->ok {
        Js.Promise2.resolve(body)
      } else {
        Js.Promise2.reject(makeError(body->extractError)->Obj.magic)
      }
    )
  )
