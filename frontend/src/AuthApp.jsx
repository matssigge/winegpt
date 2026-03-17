import React, { useEffect, useState } from "react"
import { login, me, register } from "./authApi.js"
import {
  clearSessionToken,
  loadSessionToken,
  saveSessionToken
} from "./sessionStorage.js"

function parseJson(text) {
  return JSON.parse(text)
}

function describeError(error) {
  switch (error.message) {
    case "email_taken":
      return "That email address is already registered."
    case "invalid_email":
      return "Enter a valid email address."
    case "password_too_short":
      return "Use a password with at least 8 characters."
    case "invalid_credentials":
      return "The email or password was not accepted."
    default:
      return "Something went wrong. Try again."
  }
}

function Field({ label, type = "text", value, onChange, autoComplete }) {
  return (
    <label className="block">
      <span className="mb-2 block text-sm font-medium text-stone-700">{label}</span>
      <input
        type={type}
        value={value}
        onChange={event => onChange(event.target.value)}
        autoComplete={autoComplete}
        className="w-full rounded-2xl border border-stone-300 bg-white px-4 py-3 text-base text-stone-950 outline-none transition focus:border-stone-500"
      />
    </label>
  )
}

function AuthCard({
  mode,
  onModeChange,
  form,
  onFormChange,
  onSubmit,
  isSubmitting,
  error
}) {
  const isRegister = mode === "register"

  return (
    <section className="w-full max-w-md rounded-[2rem] border border-stone-900/10 bg-white/80 p-8 shadow-[0_24px_80px_rgba(81,46,23,0.12)] backdrop-blur">
      <p className="mb-3 font-mono text-xs uppercase tracking-[0.35em] text-stone-600">
        Wine
      </p>
      <h1 className="font-serif text-4xl leading-none tracking-[-0.04em] text-stone-950">
        {isRegister ? "Create your account" : "Welcome back"}
      </h1>
      <p className="mt-4 text-sm leading-6 text-stone-700">
        {isRegister
          ? "Start your wine journal with a personal account."
          : "Sign in to continue to your wine journal."}
      </p>
      <div className="mt-6 grid grid-cols-2 gap-2 rounded-2xl bg-stone-100 p-1">
        <button
          type="button"
          onClick={() => onModeChange("login")}
          className={`rounded-2xl px-4 py-2 text-sm font-medium transition ${
            !isRegister ? "bg-white text-stone-950 shadow-sm" : "text-stone-500"
          }`}
        >
          Log in
        </button>
        <button
          type="button"
          onClick={() => onModeChange("register")}
          className={`rounded-2xl px-4 py-2 text-sm font-medium transition ${
            isRegister ? "bg-white text-stone-950 shadow-sm" : "text-stone-500"
          }`}
        >
          Sign up
        </button>
      </div>
      <form className="mt-6 space-y-4" onSubmit={onSubmit}>
        {isRegister ? (
          <Field
            label="Full name"
            value={form.fullName}
            onChange={value => onFormChange("fullName", value)}
            autoComplete="name"
          />
        ) : null}
        <Field
          label="Email"
          type="email"
          value={form.email}
          onChange={value => onFormChange("email", value)}
          autoComplete="email"
        />
        <Field
          label="Password"
          type="password"
          value={form.password}
          onChange={value => onFormChange("password", value)}
          autoComplete={isRegister ? "new-password" : "current-password"}
        />
        {error ? (
          <div className="rounded-2xl border border-rose-200 bg-rose-50 px-4 py-3 text-sm text-rose-700">
            {error}
          </div>
        ) : null}
        <button
          type="submit"
          disabled={isSubmitting}
          className="w-full rounded-2xl bg-stone-950 px-4 py-3 text-sm font-semibold text-white transition hover:bg-stone-800 disabled:cursor-wait disabled:bg-stone-400"
        >
          {isSubmitting ? "Working..." : isRegister ? "Create account" : "Log in"}
        </button>
      </form>
    </section>
  )
}

function AppShell({ user, onLogout }) {
  return (
    <section className="w-full max-w-3xl rounded-[2rem] border border-stone-900/10 bg-white/80 p-8 shadow-[0_24px_80px_rgba(81,46,23,0.12)] backdrop-blur md:p-12">
      <p className="mb-3 font-mono text-xs uppercase tracking-[0.35em] text-stone-600">
        Wine
      </p>
      <div className="flex flex-col gap-6 md:flex-row md:items-start md:justify-between">
        <div>
          <h1 className="max-w-xl font-serif text-5xl leading-none tracking-[-0.04em] text-stone-950 md:text-6xl">
            Auth foundation is in place.
          </h1>
          <p className="mt-6 max-w-xl text-base leading-7 text-stone-700 md:text-lg">
            Signed in as <span className="font-semibold text-stone-900">{user.email}</span>.
            Collections and entry capture are the next slices on the roadmap.
          </p>
        </div>
        <button
          type="button"
          onClick={onLogout}
          className="rounded-2xl border border-stone-300 px-4 py-3 text-sm font-medium text-stone-700 transition hover:border-stone-500 hover:text-stone-950"
        >
          Log out
        </button>
      </div>
    </section>
  )
}

export default function AuthApp() {
  const [mode, setMode] = useState("login")
  const [form, setForm] = useState({
    email: "",
    fullName: "",
    password: ""
  })
  const [currentUser, setCurrentUser] = useState(null)
  const [isInitializing, setIsInitializing] = useState(true)
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [error, setError] = useState(null)

  useEffect(() => {
    const sessionToken = loadSessionToken()

    if (!sessionToken) {
      setIsInitializing(false)
      return
    }

    me(sessionToken)
      .then(response => {
        setCurrentUser(parseJson(response))
        setIsInitializing(false)
      })
      .catch(() => {
        clearSessionToken()
        setCurrentUser(null)
        setIsInitializing(false)
      })
  }, [])

  function updateForm(field, value) {
    setForm(current => ({
      ...current,
      [field]: value
    }))
  }

  function handleModeChange(nextMode) {
    setMode(nextMode)
    setError(null)
  }

  function handleSubmit(event) {
    event.preventDefault()
    setIsSubmitting(true)
    setError(null)

    const request = mode === "register"
      ? register(form.email, form.fullName || null, form.password)
      : login(form.email, form.password)

    request
      .then(response => {
        const payload = parseJson(response)
        saveSessionToken(payload.token)
        setCurrentUser(payload.user)
        setForm({
          email: "",
          fullName: "",
          password: ""
        })
      })
      .catch(reason => {
        setError(describeError(reason))
      })
      .finally(() => {
        setIsSubmitting(false)
      })
  }

  function handleLogout() {
    clearSessionToken()
    setCurrentUser(null)
    setError(null)
    setMode("login")
  }

  return (
    <main className="min-h-screen bg-[radial-gradient(circle_at_top,_rgba(234,214,196,0.9),_transparent_45%),linear-gradient(180deg,_#f7efe7_0%,_#ead9ca_100%)] px-6 py-12 text-stone-950">
      <div className="mx-auto flex min-h-[calc(100vh-6rem)] max-w-5xl items-center justify-center">
        {isInitializing ? (
          <section className="w-full max-w-md rounded-[2rem] border border-stone-900/10 bg-white/80 p-8 text-sm text-stone-600 shadow-[0_24px_80px_rgba(81,46,23,0.12)] backdrop-blur">
            Checking your session...
          </section>
        ) : currentUser ? (
          <AppShell user={currentUser} onLogout={handleLogout} />
        ) : (
          <AuthCard
            mode={mode}
            onModeChange={handleModeChange}
            form={form}
            onFormChange={updateForm}
            onSubmit={handleSubmit}
            isSubmitting={isSubmitting}
            error={error}
          />
        )}
      </div>
    </main>
  )
}
