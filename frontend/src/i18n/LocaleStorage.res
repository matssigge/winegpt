@val @scope(("globalThis", "window")) external localStorage: 'storage = "localStorage"
@send external getItem: ('storage, string) => Js.Nullable.t<string> = "getItem"
@send external setItem: ('storage, string, string) => unit = "setItem"
@send external removeItem: ('storage, string) => unit = "removeItem"

let storageKey = "locale"

let loadOverride = (): option<AppLocale.locale> =>
  switch localStorage->getItem(storageKey)->Js.Nullable.toOption {
  | Some(value) => AppLocale.fromCode(value)
  | None => None
  }

let saveOverride = (locale: AppLocale.locale): unit =>
  localStorage->setItem(storageKey, AppLocale.toCode(locale))

let clearOverride = (): unit => localStorage->removeItem(storageKey)
