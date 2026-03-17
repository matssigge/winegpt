type mode = string
type field = string

type form = {
  email: string,
  fullName: string,
  password: string,
}

let loginMode = "login"
let registerMode = "register"

let initialForm = {
  email: "",
  fullName: "",
  password: "",
}

let isRegisterMode = mode => mode == registerMode

let updateForm = (form, field, value) =>
  switch field {
  | "email" => {...form, email: value}
  | "fullName" => {...form, fullName: value}
  | "password" => {...form, password: value}
  | _ => form
  }

let submit = (mode, form) => {
  let request =
    if mode->isRegisterMode {
      AuthApi.register(form.email, form.fullName, form.password)
    } else {
      AuthApi.login(form.email, form.password)
    }

  Js.Promise2.then(
    request,
    response =>
      switch response->ResponseDecoder.parse->Belt.Option.flatMap(ResponseDecoder.authPayload) {
      | Some(payload) => Js.Promise2.resolve(payload)
      | None => Js.Promise2.reject(ApiClient.invalidResponse())
      },
  )
}
