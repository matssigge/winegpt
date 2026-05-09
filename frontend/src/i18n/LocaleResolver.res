let resolve = (
  navigatorLanguage: option<string>,
  override: option<string>,
): AppLocale.locale =>
  switch override->Belt.Option.flatMap(AppLocale.fromCode) {
  | Some(locale) => locale
  | None =>
    switch navigatorLanguage {
    | Some(lang) when lang->Js.String2.toLowerCase->Js.String2.startsWith("sv") => Sv
    | _ => En
    }
  }
