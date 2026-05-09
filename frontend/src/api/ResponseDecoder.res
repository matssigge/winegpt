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

let optionalStringField = (object_, key) =>
  switch object_->field(key) {
  | Some(value) =>
    switch value->string {
    | Some(text) => Some(Some(text))
    | None =>
      switch value->Js.Json.decodeNull {
      | Some(_) => Some(None)
      | None => None
      }
    }
  | None => Some(None)
  }

let intField = (object_, key) =>
  switch object_->field(key) {
  | Some(value) => value->int
  | None => None
  }

let optionalIntField = (object_, key) =>
  switch object_->field(key) {
  | Some(value) =>
    switch value->int {
    | Some(number) => Some(Some(number))
    | None =>
      switch value->Js.Json.decodeNull {
      | Some(_) => Some(None)
      | None => None
      }
    }
  | None => Some(None)
  }

let user = json =>
  switch json->asObject {
  | Some(object_) =>
    switch (
      object_->stringField("email"),
      object_->intField("default_collection_id"),
    ) {
    | (Some(email), Some(defaultCollectionId)) =>
      Some({email: email, defaultCollectionId: defaultCollectionId}: AuthSession.user)
    | _ => None
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

let wine = json =>
  switch json->asObject {
  | Some(object_) =>
    switch (
      object_->intField("id"),
      object_->optionalStringField("producer"),
      object_->stringField("name"),
      object_->optionalIntField("vintage"),
      object_->optionalStringField("style"),
      object_->optionalStringField("grape"),
      object_->optionalStringField("region"),
      object_->optionalStringField("country"),
    ) {
    | (
        Some(id),
        Some(producer),
        Some(name),
        Some(vintage),
        Some(style),
        Some(grape),
        Some(region),
        Some(country),
      ) =>
      Some({
        id: id,
        producer: producer,
        name: name,
        vintage: vintage,
        style: style,
        grape: grape,
        region: region,
        country: country,
      }: EntryModel.wine)
    | _ => None
    }
  | None => None
  }

let entry = json =>
  switch json->asObject {
  | Some(object_) =>
    switch (
      object_->intField("id"),
      object_->intField("collection_id"),
      object_->field("wine")->Belt.Option.flatMap(wine),
      object_->intField("created_by_user_id"),
      object_->optionalStringField("consumed_at"),
      object_->optionalStringField("venue_name"),
      object_->optionalStringField("location_text"),
      object_->optionalStringField("pairing_notes"),
      object_->optionalStringField("tasting_notes"),
      object_->optionalIntField("rating"),
    ) {
    | (
        Some(id),
        Some(collectionId),
        Some(wine),
        Some(createdByUserId),
        Some(consumedAt),
        Some(venueName),
        Some(locationText),
        Some(pairingNotes),
        Some(tastingNotes),
        Some(rating),
      ) =>
      Some({
        id: id,
        collectionId: collectionId,
        wine: wine,
        createdByUserId: createdByUserId,
        consumedAt: consumedAt,
        venueName: venueName,
        locationText: locationText,
        pairingNotes: pairingNotes,
        tastingNotes: tastingNotes,
        rating: rating,
      }: EntryModel.entry)
    | _ => None
    }
  | None => None
  }

let entries = json =>
  switch json->Js.Json.decodeArray {
  | Some(items) =>
    Belt.Array.reduce(items, Some([]), (decoded, item) =>
      switch (decoded, item->entry) {
      | (Some(entries), Some(entry)) => Some(Belt.Array.concat(entries, [entry]))
      | _ => None
      }
    )
  | None => None
  }

let wineSummary = json =>
  switch json->asObject {
  | Some(object_) =>
    switch (
      object_->field("wine")->Belt.Option.flatMap(wine),
      object_->intField("entry_count"),
      object_->stringField("last_consumed_at"),
    ) {
    | (Some(wine), Some(entryCount), Some(lastConsumedAt)) =>
      Some({
        wine: wine,
        entryCount: entryCount,
        lastConsumedAt: lastConsumedAt,
      }: WineModel.summary)
    | _ => None
    }
  | None => None
  }

let wineSummaries = json =>
  switch json->Js.Json.decodeArray {
  | Some(items) =>
    Belt.Array.reduce(items, Some([]), (decoded, item) =>
      switch (decoded, item->wineSummary) {
      | (Some(wines), Some(wineSummary)) => Some(Belt.Array.concat(wines, [wineSummary]))
      | _ => None
      }
    )
  | None => None
  }
