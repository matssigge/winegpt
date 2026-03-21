type form = {
  wineName: string,
  producer: string,
  style: string,
  grape: string,
  region: string,
  country: string,
  vintage: string,
  isSubmitting: bool,
  error: option<string>,
}

type summary = WineModel.summary
type error

@new
external makeError: string => error = "Error"

let initialForm = {
  wineName: "",
  producer: "",
  style: "",
  grape: "",
  region: "",
  country: "",
  vintage: "",
  isSubmitting: false,
  error: None,
}

let updateForm = (form, field, value) =>
  switch field {
  | "wineName" => {...form, wineName: value, error: None}
  | "producer" => {...form, producer: value, error: None}
  | "style" => {...form, style: value, error: None}
  | "grape" => {...form, grape: value, error: None}
  | "region" => {...form, region: value, error: None}
  | "country" => {...form, country: value, error: None}
  | "vintage" => {...form, vintage: value, error: None}
  | _ => form
  }

let startSubmitting = form => {...form, isSubmitting: true, error: None}
let failForm = (form, message) => {...form, isSubmitting: false, error: Some(message)}

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

let createWine = (token, collectionId, form: form) =>
  Js.Promise2.then(intOption(form.vintage, ~errorCode="invalid_wine_vintage"), vintage => {
    let producer = stringOption(form.producer)
    let style = stringOption(form.style)
    let grape = stringOption(form.grape)
    let region = stringOption(form.region)
    let country = stringOption(form.country)

    Js.Promise2.then(
      WineApi.createWine(
        token,
        collectionId,
        ~producer,
        ~name=form.wineName,
        ~vintage,
        ~style?,
        ~grape?,
        ~region?,
        ~country?,
        (),
      ),
      response =>
        switch response->ResponseDecoder.parse->Belt.Option.flatMap(ResponseDecoder.wineSummary) {
        | Some(summary) => Js.Promise2.resolve(summary)
        | None => Js.Promise2.reject(ApiClient.invalidResponse())
        },
    )
  })
