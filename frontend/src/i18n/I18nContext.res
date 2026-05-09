type contextValue = {
  locale: AppLocale.locale,
  override: option<AppLocale.locale>,
  setOverride: option<AppLocale.locale> => unit,
}

let defaultContext: contextValue = {
  locale: En,
  override: None,
  setOverride: _ => (),
}

let context = React.createContext(defaultContext)

module Provider = {
  let make = React.Context.provider(context)
}

let useContext = () => React.useContext(context)
let useLocale = () => useContext().locale
let useT = () => Translations.pick(useContext().locale)
let useOverride = () => useContext().override
let useSetOverride = () => useContext().setOverride
