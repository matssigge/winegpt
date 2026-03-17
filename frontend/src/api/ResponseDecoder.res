type json = Js.Json.t
type object_ = Js.Dict.t<json>

let parse = text =>
  try {
    Some(text->Js.Json.parseExn)
  } catch {
  | _ => None
  }

let asObject = json => json->Js.Json.decodeObject
let string = json => json->Js.Json.decodeString

let int = json =>
  switch json->Js.Json.decodeNumber {
  | Some(value) => Some(value->Belt.Int.fromFloat)
  | None => None
  }

let field = (object_, key) => object_->Js.Dict.get(key)

let stringField = (object_, key) =>
  switch object_->field(key) {
  | Some(value) => value->string
  | None => None
  }

let intField = (object_, key) =>
  switch object_->field(key) {
  | Some(value) => value->int
  | None => None
  }

let user = json =>
  switch json->asObject {
  | Some(object_) =>
    switch object_->stringField("email") {
    | Some(email) => Some({email: email}: AuthSession.user)
    | None => None
    }
  | None => None
  }

let authPayload = json =>
  switch json->asObject {
  | Some(object_) =>
    switch (object_->stringField("token"), object_->field("user")->Belt.Option.flatMap(user)) {
    | (Some(token), Some(user)) => Some({token: token, user: user}: AuthSession.authPayload)
    | _ => None
    }
  | None => None
  }

let collection = json =>
  switch json->asObject {
  | Some(object_) =>
    switch (
      object_->intField("id"),
      object_->stringField("name"),
      object_->stringField("role"),
    ) {
    | (Some(id), Some(name), Some(role)) =>
      Some({id: id, name: name, role: role}: CollectionModel.collection)
    | _ => None
    }
  | None => None
  }

let collections = json =>
  switch json->Js.Json.decodeArray {
  | Some(items) =>
    Belt.Array.reduce(items, Some([]), (decoded, item) =>
      switch (decoded, item->collection) {
      | (Some(collections), Some(collection)) => Some(Belt.Array.concat(collections, [collection]))
      | _ => None
      }
    )
  | None => None
  }

let invitedCollectionMember = json =>
  switch json->asObject {
  | Some(object_) =>
    switch (
      object_->intField("user_id"),
      object_->stringField("email"),
      object_->stringField("role"),
    ) {
    | (Some(userId), Some(email), Some(role)) =>
      Some({userId: userId, email: email, role: role}: CollectionInviteModel.invitedMember)
    | _ => None
    }
  | None => None
  }
