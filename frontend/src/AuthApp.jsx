import React, { useEffect, useState } from "react"
import {
  describeCreateCollectionError,
  describeError
} from "./AuthAppSupport.bs.js"
import {
  initialForm,
  loginMode,
  submit as submitAuthForm,
  updateForm as updateAuthForm
} from "./AuthForm.bs.js"
import {
  appendCollection,
  createCollection,
  emptyCollectionStatus,
  errorCollectionStatus,
  finishCollectionForm,
  initialCollectionForm,
  initialCollectionStatus,
  listCollections,
  loadingCollectionStatus,
  readyCollectionStatus,
  resolveSelectedCollectionId,
  startSubmittingCollectionForm,
  updateCollectionForm as updateCollectionFormState,
  failCollectionForm
} from "./CollectionState.bs.js"
import {
  clearSelectedCollectionId,
  loadSelectedCollectionId,
  saveSelectedCollectionId
} from "./CollectionSelectionStorage.bs.js"
import {
  loadSessionToken as loadStoredSessionToken,
  restoreSession
} from "./SessionBootstrap.bs.js"
import {
  clearSessionToken,
  saveSessionToken
} from "./SessionStorage.bs.js"
import { make as AuthCard } from "./AuthCard.bs.js"
import { make as AuthField } from "./AuthField.bs.js"
import { make as CollectionList } from "./CollectionList.bs.js"

function AppShell({
  user,
  collectionStatus,
  collectionForm,
  selectedCollectionId,
  onCollectionFormChange,
  onCreateCollection,
  onSelectCollection,
  onLogout
}) {
  return (
    <section className="w-full max-w-3xl rounded-[2rem] border border-stone-900/10 bg-white/80 p-8 shadow-[0_24px_80px_rgba(81,46,23,0.12)] backdrop-blur md:p-12">
      <p className="mb-3 font-mono text-xs uppercase tracking-[0.35em] text-stone-600">
        Wine
      </p>
      <div className="flex flex-col gap-6 md:flex-row md:items-start md:justify-between">
        <div>
          <h1 className="max-w-xl font-serif text-5xl leading-none tracking-[-0.04em] text-stone-950 md:text-6xl">
            Collections are ready for your first entries.
          </h1>
          <p className="mt-6 max-w-xl text-base leading-7 text-stone-700 md:text-lg">
            Signed in as <span className="font-semibold text-stone-900">{user.email}</span>.
            Choose a collection once it exists, then entry capture is the next slice.
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
      <div className="mt-8">
        <section className="mb-6 rounded-[1.75rem] border border-stone-900/10 bg-stone-50/80 p-6">
          <div className="flex flex-col gap-4 md:flex-row md:items-end">
            <div className="flex-1">
              <AuthField
                label="New collection"
                value={collectionForm.name}
                onChange={onCollectionFormChange}
                autoComplete="off"
              />
            </div>
            <button
              type="button"
              onClick={onCreateCollection}
              disabled={collectionForm.isSubmitting}
              className="rounded-2xl bg-stone-950 px-5 py-3 text-sm font-semibold text-white transition hover:bg-stone-800 disabled:cursor-wait disabled:bg-stone-400"
            >
              {collectionForm.isSubmitting ? "Creating..." : "Create collection"}
            </button>
          </div>
          {collectionForm.error ? (
            <div className="mt-4 rounded-2xl border border-rose-200 bg-rose-50 px-4 py-3 text-sm text-rose-700">
              {collectionForm.error}
            </div>
          ) : null}
        </section>
        <CollectionList
          status={collectionStatus}
          selectedCollectionId={selectedCollectionId}
          onSelectCollection={onSelectCollection}
        />
      </div>
    </section>
  )
}

export default function AuthApp() {
  const [mode, setMode] = useState(loginMode)
  const [form, setForm] = useState(initialForm)
  const [currentUser, setCurrentUser] = useState(null)
  const [sessionToken, setSessionToken] = useState(null)
  const [isInitializing, setIsInitializing] = useState(true)
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [error, setError] = useState(null)
  const [collectionStatus, setCollectionStatus] = useState(initialCollectionStatus())
  const [selectedCollectionId, setSelectedCollectionId] = useState(null)
  const [collectionForm, setCollectionForm] = useState(initialCollectionForm)

  useEffect(() => {
    const sessionToken = loadStoredSessionToken()

    if (!sessionToken) {
      setSessionToken(null)
      setCollectionStatus(emptyCollectionStatus())
      setSelectedCollectionId(null)
      setIsInitializing(false)
      return
    }

    restoreSession(sessionToken)
      .then(restoredSession => {
        setSessionToken(restoredSession.sessionToken)
        setCurrentUser(restoredSession.user)
        setIsInitializing(false)
      })
      .catch(() => {
        clearSessionToken()
        setSessionToken(null)
        setCurrentUser(null)
        setCollectionStatus(emptyCollectionStatus())
        setSelectedCollectionId(null)
        setIsInitializing(false)
      })
  }, [])

  useEffect(() => {
    if (!currentUser || !sessionToken) {
      setCollectionStatus(emptyCollectionStatus())
      setSelectedCollectionId(null)
      return
    }

    setCollectionStatus(loadingCollectionStatus())

    listCollections(sessionToken)
      .then(collections => {
        setCollectionStatus(readyCollectionStatus(collections))
      })
      .catch(() => {
        setCollectionStatus(errorCollectionStatus("Could not load your collections. Try refreshing."))
      })
  }, [currentUser, sessionToken])

  useEffect(() => {
    if (collectionStatus.kind !== "ready") {
      return
    }

    if (collectionStatus.collections.length === 0) {
      setSelectedCollectionId(null)
      clearSelectedCollectionId()
      return
    }

    const nextSelectedCollectionId = resolveSelectedCollectionId(
      collectionStatus.collections,
      selectedCollectionId,
      loadSelectedCollectionId()
    )

    if (nextSelectedCollectionId === selectedCollectionId) {
      return
    }

    setSelectedCollectionId(nextSelectedCollectionId)
    saveSelectedCollectionId(nextSelectedCollectionId)
  }, [collectionStatus, selectedCollectionId])

  function updateForm(field, value) {
    setForm(current => updateAuthForm(current, field, value))
  }

  function handleModeChange(nextMode) {
    setMode(nextMode)
    setError(null)
  }

  function updateCollectionForm(value) {
    setCollectionForm(current => updateCollectionFormState(current, value))
  }

  function handleSubmit(event) {
    event.preventDefault()
    setIsSubmitting(true)
    setError(null)
    submitAuthForm(mode, form)
      .then(payload => {
        saveSessionToken(payload.token)
        setSessionToken(payload.token)
        setCurrentUser(payload.user)
        setCollectionForm(finishCollectionForm())
        setForm(initialForm)
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
    setSessionToken(null)
    setCurrentUser(null)
    setCollectionStatus(emptyCollectionStatus())
    setSelectedCollectionId(null)
    clearSelectedCollectionId()
    setCollectionForm(finishCollectionForm())
    setError(null)
    setMode(loginMode)
  }

  function handleCreateCollection() {
    if (!sessionToken || collectionForm.isSubmitting) {
      return
    }

    setCollectionForm(current => startSubmittingCollectionForm(current))

    createCollection(sessionToken, collectionForm.name)
      .then(collection => {
        setSelectedCollectionId(collection.id)
        saveSelectedCollectionId(collection.id)
        setCollectionStatus(current => {
          const collections = current.kind === "ready" ? current.collections : []

          return readyCollectionStatus(appendCollection(collections, collection))
        })
        setCollectionForm(finishCollectionForm())
      })
      .catch(reason => {
        setCollectionForm(current => failCollectionForm(current, describeCreateCollectionError(reason)))
      })
  }

  function handleSelectCollection(collectionId) {
    setSelectedCollectionId(collectionId)
    saveSelectedCollectionId(collectionId)
  }

  return (
    <main className="min-h-screen bg-[radial-gradient(circle_at_top,_rgba(234,214,196,0.9),_transparent_45%),linear-gradient(180deg,_#f7efe7_0%,_#ead9ca_100%)] px-6 py-12 text-stone-950">
      <div className="mx-auto flex min-h-[calc(100vh-6rem)] max-w-5xl items-center justify-center">
        {isInitializing ? (
          <section className="w-full max-w-md rounded-[2rem] border border-stone-900/10 bg-white/80 p-8 text-sm text-stone-600 shadow-[0_24px_80px_rgba(81,46,23,0.12)] backdrop-blur">
            Checking your session...
          </section>
        ) : currentUser ? (
          <AppShell
            user={currentUser}
            collectionStatus={collectionStatus}
            collectionForm={collectionForm}
            selectedCollectionId={selectedCollectionId}
            onCollectionFormChange={updateCollectionForm}
            onCreateCollection={handleCreateCollection}
            onSelectCollection={handleSelectCollection}
            onLogout={handleLogout}
          />
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
