type entry = EntryModel.entry
type wine = EntryModel.wine

type status =
  | Idle
  | Loading
  | Ready(array<entry>)
  | Error(string)

type form = {
  dateMode: bool,
  consumedAt: option<string>,
  venueName: string,
  locationText: string,
  pairingNotes: string,
  tastingNotes: string,
  rating: string,
  isSubmitting: bool,
  error: option<string>,
  success: option<string>,
}

type error

@new
external makeError: string => error = "Error"

type date

@new
external makeDateNow: unit => date = "Date"

@send
external getFullYear: date => int = "getFullYear"

@send
external getMonth: date => int = "getMonth"

@send
external getDate: date => int = "getDate"

let initialStatus = () => Idle
let loadingStatus = () => Loading
let emptyStatus = () => Ready([])
let readyStatus = entries => Ready(entries)
let errorStatus = message => Error(message)

let initialForm = {
  dateMode: false,
  consumedAt: None,
  venueName: "",
  locationText: "",
  pairingNotes: "",
  tastingNotes: "",
  rating: "",
  isSubmitting: false,
  error: None,
  success: None,
}

let padTwo = value => {
  let text = value->Belt.Int.toString
  if value < 10 {"0" ++ text} else {text}
}

let todayDateString = () => {
  let now = makeDateNow()
  now->getFullYear->Belt.Int.toString ++
  "-" ++
  (now->getMonth + 1 |> padTwo) ++
  "-" ++
  (now->getDate |> padTwo)
}

let consumedAtToDateValue = consumedAt => consumedAt

let updateForm = (form, field, value) =>
  switch field {
  | "consumedAt" => {
      ...form,
      consumedAt: switch value {
      | "" => None
      | text => Some(text)
      },
      error: None,
      success: None,
    }
  | "venueName" => {...form, venueName: value, error: None, success: None}
  | "locationText" => {...form, locationText: value, error: None, success: None}
  | "pairingNotes" => {...form, pairingNotes: value, error: None, success: None}
  | "tastingNotes" => {...form, tastingNotes: value, error: None, success: None}
  | "rating" => {...form, rating: value, error: None, success: None}
  | _ => form
  }

let toggleDateMode = (form, enabled) =>
  if enabled {
    {
      ...form,
      dateMode: true,
      consumedAt: switch form.consumedAt {
      | Some(_) as existing => existing
      | None => Some(todayDateString())
      },
      error: None,
      success: None,
    }
  } else {
    {...form, dateMode: false, consumedAt: None, error: None, success: None}
  }

let startSubmitting = form => {...form, isSubmitting: true, error: None, success: None}
let failForm = (form, message) => {...form, isSubmitting: false, error: Some(message), success: None}
let succeedForm = () => {...initialForm, success: Some("Entry saved.")}

let formFromEntry = (entry: entry) => {
  let dateValue = consumedAtToDateValue(entry.consumedAt)
  {
    dateMode: Belt.Option.isSome(dateValue),
    consumedAt: dateValue,
    venueName: entry.venueName->Belt.Option.getWithDefault(""),
    locationText: entry.locationText->Belt.Option.getWithDefault(""),
    pairingNotes: entry.pairingNotes->Belt.Option.getWithDefault(""),
    tastingNotes: entry.tastingNotes->Belt.Option.getWithDefault(""),
    rating: entry.rating->Belt.Option.map(Belt.Int.toString)->Belt.Option.getWithDefault(""),
    isSubmitting: false,
    error: None,
    success: None,
  }
}

let entries = status =>
  switch status {
  | Ready(entries) => entries
  | Idle | Loading | Error(_) => []
  }

let appendEntry = (entries: array<entry>, entry: entry) => Belt.Array.concat([entry], entries)

let replaceEntry = (entries: array<entry>, nextEntry: entry) =>
  Belt.Array.map(entries, entry => if entry.id == nextEntry.id {nextEntry} else {entry})

let isReady = status =>
  switch status {
  | Ready(_) => true
  | Idle | Loading | Error(_) => false
  }

let stringOption = value =>
  switch value->String.trim {
  | "" => None
  | trimmed => Some(trimmed)
  }

let intOption = (value, ~errorCode) =>
  switch value->String.trim {
  | "" => Js.Promise2.resolve(None)
  | trimmed =>
    switch Belt.Int.fromString(trimmed) {
    | Some(number) => Js.Promise2.resolve(Some(number))
    | None => Js.Promise2.reject(makeError(errorCode)->Obj.magic)
    }
  }

let consumedAtForSubmit = form =>
  if form.dateMode {
    switch form.consumedAt {
    | Some(date) when date->String.trim != "" => Some(date->String.trim)
    | _ => None
    }
  } else {
    None
  }

let listEntries = (token, collectionId) =>
  Js.Promise2.then(
    EntryApi.listEntries(token, collectionId),
    response =>
      switch response->ResponseDecoder.parse->Belt.Option.flatMap(ResponseDecoder.entries) {
      | Some(entries) => Js.Promise2.resolve(entries)
      | None => Js.Promise2.reject(ApiClient.invalidResponse())
      },
  )

let createEntry = (token, collectionId, wine: wine, form: form) =>
  Js.Promise2.then(intOption(form.rating, ~errorCode="invalid_rating"), rating => {
    let consumedAt = consumedAtForSubmit(form)
    let venueName = stringOption(form.venueName)
    let locationText = stringOption(form.locationText)
    let pairingNotes = stringOption(form.pairingNotes)
    let tastingNotes = stringOption(form.tastingNotes)

    Js.Promise2.then(
      EntryApi.createEntry(
        token,
        collectionId,
        ~producer=wine.producer,
        ~name=wine.name,
        ~vintage=wine.vintage,
        ~style=?wine.style,
        ~grape=?wine.grape,
        ~region=?wine.region,
        ~country=?wine.country,
        ~consumedAt,
        ~venueName,
        ~locationText,
        ~pairingNotes,
        ~tastingNotes,
        ~rating,
        (),
      ),
      response =>
        switch response->ResponseDecoder.parse->Belt.Option.flatMap(ResponseDecoder.entry) {
        | Some(entry) => Js.Promise2.resolve(entry)
        | None => Js.Promise2.reject(ApiClient.invalidResponse())
        },
    )
  })

let updateEntry = (token, collectionId, entryId, wine: wine, form: form) =>
  Js.Promise2.then(intOption(form.rating, ~errorCode="invalid_rating"), rating => {
    let consumedAt = consumedAtForSubmit(form)
    let venueName = stringOption(form.venueName)
    let locationText = stringOption(form.locationText)
    let pairingNotes = stringOption(form.pairingNotes)
    let tastingNotes = stringOption(form.tastingNotes)

    Js.Promise2.then(
      EntryApi.updateEntry(
        token,
        collectionId,
        entryId,
        ~producer=wine.producer,
        ~name=wine.name,
        ~vintage=wine.vintage,
        ~style=?wine.style,
        ~grape=?wine.grape,
        ~region=?wine.region,
        ~country=?wine.country,
        ~consumedAt,
        ~venueName,
        ~locationText,
        ~pairingNotes,
        ~tastingNotes,
        ~rating,
        (),
      ),
      response =>
        switch response->ResponseDecoder.parse->Belt.Option.flatMap(ResponseDecoder.entry) {
        | Some(entry) => Js.Promise2.resolve(entry)
        | None => Js.Promise2.reject(ApiClient.invalidResponse())
        },
    )
  })
