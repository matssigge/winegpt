type error = Js.Promise2.error

@get
external message: error => string = "message"

let describeError = error =>
  switch error->message {
  | "email_taken" => "That email address is already registered."
  | "invalid_email" => "Enter a valid email address."
  | "password_too_short" => "Use a password with at least 8 characters."
  | "invalid_credentials" => "The email or password was not accepted."
  | "invalid_response" => "Something went wrong. Try again."
  | _ => "Something went wrong. Try again."
  }

let describeCollectionError = () => "Could not load your collections. Try refreshing."

let describeCreateCollectionError = error =>
  switch error->message {
  | "invalid_collection_name" => "Enter a name for the collection."
  | _ => "Could not create the collection. Try again."
  }

let describeInviteError = error =>
  switch error->message {
  | "invalid_email" => "Enter a valid email address."
  | "already_member" => "That person already belongs to this collection."
  | "user_not_found" => "That email does not match an existing account yet."
  | "forbidden" => "Only collection owners can invite people."
  | _ => "Could not send the invite. Try again."
  }
