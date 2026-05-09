type form = AuthForm.form

let loginButtonClasses =
  "rounded-2xl px-4 py-2 text-sm font-medium transition bg-white text-stone-950 shadow-sm"

let inactiveButtonClasses = "rounded-2xl px-4 py-2 text-sm font-medium transition text-stone-500"

@react.component
let make = (
  ~mode,
  ~onModeChange: string => unit,
  ~form: AuthForm.form,
  ~onFormChange: (. string, string) => unit,
  ~onSubmit: ReactEvent.Form.t => unit,
  ~isSubmitting,
  ~error: Js.Nullable.t<string>,
) => {
  let isRegister = AuthForm.isRegisterMode(mode)
  let t = I18nContext.useT()

  <section className="w-full max-w-md rounded-[2rem] border border-stone-900/10 bg-white/80 p-8 shadow-[0_24px_80px_rgba(81,46,23,0.12)] backdrop-blur">
    <p className="mb-3 font-mono text-xs uppercase tracking-[0.35em] text-stone-600"> {React.string(t.authBrand)} </p>
    <h1 className="font-serif text-4xl leading-none tracking-[-0.04em] text-stone-950">
      {React.string(if isRegister { t.authCreateYourAccount } else { t.authWelcomeBack })}
    </h1>
    <p className="mt-4 text-sm leading-6 text-stone-700">
      {React.string(
         if isRegister {
           t.authRegisterIntro
         } else {
           t.authLoginIntro
         },
       )}
    </p>
    <div className="mt-6 grid grid-cols-2 gap-2 rounded-2xl bg-stone-100 p-1">
      <button
        type_="button"
        onClick={_ => onModeChange(AuthForm.loginMode)}
        className={if !isRegister { loginButtonClasses } else { inactiveButtonClasses }}>
        {React.string(t.authLogIn)}
      </button>
      <button
        type_="button"
        onClick={_ => onModeChange(AuthForm.registerMode)}
        className={if isRegister { loginButtonClasses } else { inactiveButtonClasses }}>
        {React.string(t.authSignUp)}
      </button>
    </div>
    <form className="mt-6 space-y-4" onSubmit>
      {if isRegister {
         <TextField
           label=t.authFullName
           value=form.fullName
           onChange={value => onFormChange(. "fullName", value)}
           autoComplete="name"
         />
       } else {
         React.null
       }}
      <TextField
        label=t.authEmail
        type_="email"
        value=form.email
        onChange={value => onFormChange(. "email", value)}
        autoComplete="email"
      />
      <TextField
        label=t.authPassword
        type_="password"
        value=form.password
        onChange={value => onFormChange(. "password", value)}
        autoComplete={if isRegister { "new-password" } else { "current-password" }}
      />
      {switch error->Js.Nullable.toOption {
      | Some(message) =>
        <div className="rounded-2xl border border-rose-200 bg-rose-50 px-4 py-3 text-sm text-rose-700">
          {React.string(message)}
        </div>
      | None => React.null
      }}
      <button
        type_="submit"
        disabled={isSubmitting}
        className="w-full rounded-2xl bg-stone-950 px-4 py-3 text-sm font-semibold text-white transition hover:bg-stone-800 disabled:cursor-wait disabled:bg-stone-400">
        {React.string(
           if isSubmitting {
             t.authWorking
           } else if isRegister {
             t.authCreateAccount
           } else {
             t.authLogIn
           },
         )}
      </button>
    </form>
  </section>
}
