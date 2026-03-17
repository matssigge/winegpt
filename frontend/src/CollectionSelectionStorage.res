type storage

@val
external localStorage: storage = "localStorage"

@send
external getItemUnsafe: (storage, string) => Js.Nullable.t<string> = "getItem"

@send
external setItem: (storage, string, string) => unit = "setItem"

@send
external removeItem: (storage, string) => unit = "removeItem"

let selectedCollectionIdKey = "wine.selectedCollectionId"

let loadSelectedCollectionId = () =>
  switch localStorage->getItemUnsafe(selectedCollectionIdKey)->Js.Nullable.toOption {
  | Some(value) => Belt.Int.fromString(value)
  | None => None
  }

let saveSelectedCollectionId = collectionId =>
  localStorage->setItem(selectedCollectionIdKey, collectionId->Belt.Int.toString)

let clearSelectedCollectionId = () =>
  localStorage->removeItem(selectedCollectionIdKey)
