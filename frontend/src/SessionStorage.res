type storage

@val
external localStorage: storage = "localStorage"

@send
external getItemUnsafe: (storage, string) => Js.Nullable.t<string> = "getItem"

@send
external setItem: (storage, string, string) => unit = "setItem"

@send
external removeItem: (storage, string) => unit = "removeItem"

let sessionTokenKey = "wine.sessionToken"

let loadSessionToken = () =>
  localStorage->getItemUnsafe(sessionTokenKey)->Js.Nullable.toOption

let saveSessionToken = token => localStorage->setItem(sessionTokenKey, token)

let clearSessionToken = () => localStorage->removeItem(sessionTokenKey)
