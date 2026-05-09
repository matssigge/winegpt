type error = Js.Promise2.error

@get
external message: error => string = "message"

let describeError = (errors: Translations.errors, error) =>
  switch error->message {
  | "email_taken" => errors.authEmailTaken
  | "invalid_email" => errors.authInvalidEmail
  | "password_too_short" => errors.authPasswordTooShort
  | "invalid_credentials" => errors.authInvalidCredentials
  | "invalid_response" => errors.authGeneric
  | _ => errors.authGeneric
  }

let describeEntryError = (errors: Translations.errors, error) =>
  switch error->message {
  | "invalid_consumed_at" => errors.entryInvalidConsumedAt
  | "invalid_rating" => errors.entryInvalidRating
  | "invalid_wine_name" => errors.entryInvalidWineName
  | "invalid_wine_vintage" => errors.entryInvalidWineVintage
  | "forbidden" => errors.entryForbidden
  | _ => errors.entryGeneric
  }

let describeEntryHistoryError = (errors: Translations.errors) => errors.entryHistoryGeneric

let describeWineError = (errors: Translations.errors, error) =>
  switch error->message {
  | "invalid_wine_name" => errors.wineInvalidName
  | "invalid_wine_vintage" => errors.wineInvalidVintage
  | "forbidden" => errors.wineForbidden
  | _ => errors.wineGeneric
  }
