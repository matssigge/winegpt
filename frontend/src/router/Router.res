type route =
  | Home
  | Wine(int)
  | NewWine
  | NewEntry(int)
  | EditEntry(int, int)

type location
@val @scope(("globalThis", "window")) external location: location = "location"
@get external locationHash: location => string = "hash"
@set external setHash: (location, string) => unit = "hash"
@val @scope(("globalThis", "window")) external addListener: (string, unit => unit) => unit = "addEventListener"
@val @scope(("globalThis", "window")) external removeListener: (string, unit => unit) => unit = "removeEventListener"

let parse = (raw: string): route => {
  let trimmed =
    if raw->Js.String2.startsWith("#") {
      raw->Js.String2.substr(~from=1)
    } else {
      raw
    }
  let path =
    if trimmed->Js.String2.startsWith("/") {
      trimmed->Js.String2.substr(~from=1)
    } else {
      trimmed
    }
  let segments =
    path
    ->Js.String2.split("/")
    ->Belt.Array.keep(segment => segment !== "")

  switch segments {
  | [] => Home
  | ["wines", "new"] => NewWine
  | ["wines", id] =>
    switch Belt.Int.fromString(id) {
    | Some(wineId) => Wine(wineId)
    | None => Home
    }
  | ["wines", wine, "entries", "new"] =>
    switch Belt.Int.fromString(wine) {
    | Some(wineId) => NewEntry(wineId)
    | None => Home
    }
  | ["wines", wine, "entries", entry, "edit"] =>
    switch (Belt.Int.fromString(wine), Belt.Int.fromString(entry)) {
    | (Some(wineId), Some(entryId)) => EditEntry(wineId, entryId)
    | _ => Home
    }
  | _ => Home
  }
}

let format = (route: route): string =>
  switch route {
  | Home => "#/"
  | Wine(id) => "#/wines/" ++ Belt.Int.toString(id)
  | NewWine => "#/wines/new"
  | NewEntry(wineId) => "#/wines/" ++ Belt.Int.toString(wineId) ++ "/entries/new"
  | EditEntry(wineId, entryId) =>
    "#/wines/" ++
    Belt.Int.toString(wineId) ++
    "/entries/" ++
    Belt.Int.toString(entryId) ++
    "/edit"
  }

let navigate = (route: route): unit => setHash(location, format(route))

let useRoute = (): route => {
  let (current, setCurrent) = React.useState(() => parse(location->locationHash))

  React.useEffect0(() => {
    let handler = () => setCurrent(_ => parse(location->locationHash))
    addListener("hashchange", handler)
    Some(() => removeListener("hashchange", handler))
  })

  current
}
