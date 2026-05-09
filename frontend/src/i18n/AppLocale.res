type locale =
  | En
  | Sv

let toCode = (locale: locale): string =>
  switch locale {
  | En => "en"
  | Sv => "sv"
  }

let fromCode = (code: string): option<locale> =>
  switch code {
  | "en" => Some(En)
  | "sv" => Some(Sv)
  | _ => None
  }
