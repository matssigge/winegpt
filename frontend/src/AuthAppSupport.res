type error

@get
external message: error => string = "message"

let parseJson = text => text->Js.Json.deserializeUnsafe

let describeError = error =>
  switch error->message {
  | "email_taken" => "That email address is already registered."
  | "invalid_email" => "Enter a valid email address."
  | "password_too_short" => "Use a password with at least 8 characters."
  | "invalid_credentials" => "The email or password was not accepted."
  | _ => "Something went wrong. Try again."
  }

let describeCollectionError = () => "Could not load your collections. Try refreshing."

let describeCreateCollectionError = error =>
  switch error->message {
  | "invalid_collection_name" => "Enter a name for the collection."
  | _ => "Could not create the collection. Try again."
  }
