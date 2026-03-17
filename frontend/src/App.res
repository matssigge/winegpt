@send
external preventDefault: ReactEvent.Form.t => unit = "preventDefault"

@react.component
let make = () => {
  let (mode, setMode) = React.useState(() => AuthForm.loginMode)
  let (form, setForm) = React.useState(() => AuthForm.initialForm)
  let (currentUser, setCurrentUser) = React.useState(() => None)
  let (sessionToken, setSessionToken) = React.useState(() => None)
  let (isInitializing, setIsInitializing) = React.useState(() => true)
  let (isSubmitting, setIsSubmitting) = React.useState(() => false)
  let (error, setError) = React.useState(() => None)
  let (collectionStatus, setCollectionStatus) = React.useState(() => CollectionState.initialCollectionStatus())
  let (selectedCollectionId, setSelectedCollectionId) = React.useState(() => None)
  let (collectionForm, setCollectionForm) = React.useState(() => CollectionState.initialCollectionForm)

  React.useEffect0(() => {
    switch SessionBootstrap.loadSessionToken() {
    | Some(restoredToken) =>
      SessionBootstrap.restoreSession(restoredToken)
      ->Js.Promise2.then(restoredSession => {
        setSessionToken(_ => Some(restoredSession.sessionToken))
        setCurrentUser(_ => Some(restoredSession.user))
        setIsInitializing(_ => false)
        Js.Promise2.resolve()
      })
      ->Js.Promise2.catch(_ => {
        SessionStorage.clearSessionToken()
        setSessionToken(_ => None)
        setCurrentUser(_ => None)
        setCollectionStatus(_ => CollectionState.emptyCollectionStatus())
        setSelectedCollectionId(_ => None)
        setIsInitializing(_ => false)
        Js.Promise2.resolve()
      })
      ->ignore
    | None =>
      setSessionToken(_ => None)
      setCollectionStatus(_ => CollectionState.emptyCollectionStatus())
      setSelectedCollectionId(_ => None)
      setIsInitializing(_ => false)
    }

    None
  })

  React.useEffect2(() => {
    switch (currentUser, sessionToken) {
    | (Some(_), Some(token)) =>
      setCollectionStatus(_ => CollectionState.loadingCollectionStatus())

      CollectionState.listCollections(token)
      ->Js.Promise2.then(collections => {
        setCollectionStatus(_ => CollectionState.readyCollectionStatus(collections))
        Js.Promise2.resolve()
      })
      ->Js.Promise2.catch(_ => {
        setCollectionStatus(_ => CollectionState.errorCollectionStatus(AuthAppSupport.describeCollectionError()))
        Js.Promise2.resolve()
      })
      ->ignore
    | _ =>
      setCollectionStatus(_ => CollectionState.emptyCollectionStatus())
      setSelectedCollectionId(_ => None)
    }

    None
  }, (currentUser, sessionToken))

  React.useEffect2(() => {
    if CollectionState.isReady(collectionStatus) {
      let collections = CollectionState.collections(collectionStatus)

      if Belt.Array.length(collections) == 0 {
        setSelectedCollectionId(_ => None)
        CollectionSelectionStorage.clearSelectedCollectionId()
      } else {
        let nextSelectedCollectionId =
          CollectionState.resolveSelectedCollectionId(
            collections,
            selectedCollectionId,
            CollectionSelectionStorage.loadSelectedCollectionId(),
          )

        if nextSelectedCollectionId != selectedCollectionId {
          setSelectedCollectionId(_ => nextSelectedCollectionId)
          switch nextSelectedCollectionId {
          | Some(collectionId) => CollectionSelectionStorage.saveSelectedCollectionId(collectionId)
          | None => CollectionSelectionStorage.clearSelectedCollectionId()
          }
        }
      }
    }

    None
  }, (collectionStatus, selectedCollectionId))

  let updateForm = (field, value) => {
    setForm(current => AuthForm.updateForm(current, field, value))
    setError(_ => None)
  }

  let handleModeChange = nextMode => {
    setMode(_ => nextMode)
    setError(_ => None)
  }

  let updateCollectionForm = value => {
    setCollectionForm(current => CollectionState.updateCollectionForm(current, value))
  }

  let handleSubmit = event => {
    event->preventDefault
    setIsSubmitting(_ => true)
    setError(_ => None)

    AuthForm.submit(mode, form)
    ->Js.Promise2.then(payload => {
      let nextSessionToken = payload.token
      SessionStorage.saveSessionToken(nextSessionToken)
      setSessionToken(_ => Some(nextSessionToken))
      setCurrentUser(_ => Some(payload.user))
      setCollectionForm(_ => CollectionState.finishCollectionForm())
      setForm(_ => AuthForm.initialForm)
      setIsSubmitting(_ => false)
      Js.Promise2.resolve()
    })
    ->Js.Promise2.catch(reason => {
      setError(_ => Some(AuthAppSupport.describeError(reason)))
      setIsSubmitting(_ => false)
      Js.Promise2.resolve()
    })
    ->ignore
  }

  let handleLogout = () => {
    SessionStorage.clearSessionToken()
    setSessionToken(_ => None)
    setCurrentUser(_ => None)
    setCollectionStatus(_ => CollectionState.emptyCollectionStatus())
    setSelectedCollectionId(_ => None)
    CollectionSelectionStorage.clearSelectedCollectionId()
    setCollectionForm(_ => CollectionState.finishCollectionForm())
    setError(_ => None)
    setMode(_ => AuthForm.loginMode)
  }

  let handleCreateCollection = () =>
    switch sessionToken {
    | Some(token) if !collectionForm.isSubmitting =>
      setCollectionForm(current => CollectionState.startSubmittingCollectionForm(current))

      CollectionState.createCollection(token, collectionForm.name)
      ->Js.Promise2.then((collection: CollectionModel.collection) => {
        let nextSelectedCollectionId = Some(collection.id)
        setSelectedCollectionId(_ => nextSelectedCollectionId)
        CollectionSelectionStorage.saveSelectedCollectionId(collection.id)
        setCollectionStatus(current => {
          let collections =
            if CollectionState.isReady(current) {
              CollectionState.collections(current)
            } else {
              []
            }

          CollectionState.readyCollectionStatus(CollectionState.appendCollection(collections, collection))
        })
        setCollectionForm(_ => CollectionState.finishCollectionForm())
        Js.Promise2.resolve()
      })
      ->Js.Promise2.catch(reason => {
        setCollectionForm(current =>
          CollectionState.failCollectionForm(current, AuthAppSupport.describeCreateCollectionError(reason))
        )
        Js.Promise2.resolve()
      })
      ->ignore
    | _ => ()
    }

  let handleSelectCollection = collectionId => {
    let nextSelectedCollectionId = Some(collectionId)
    setSelectedCollectionId(_ => nextSelectedCollectionId)
    CollectionSelectionStorage.saveSelectedCollectionId(collectionId)
  }

  <main className="min-h-screen bg-[radial-gradient(circle_at_top,_rgba(234,214,196,0.9),_transparent_45%),linear-gradient(180deg,_#f7efe7_0%,_#ead9ca_100%)] px-6 py-12 text-stone-950">
    <div className="mx-auto flex min-h-[calc(100vh-6rem)] max-w-5xl items-center justify-center">
      {if isInitializing {
         <section className="w-full max-w-md rounded-[2rem] border border-stone-900/10 bg-white/80 p-8 text-sm text-stone-600 shadow-[0_24px_80px_rgba(81,46,23,0.12)] backdrop-blur">
           {React.string("Checking your session...")}
         </section>
       } else {
         switch currentUser {
         | Some(user) =>
           <AppShell
             user
             collectionStatus
             collectionForm
             selectedCollectionId
             onCollectionFormChange=updateCollectionForm
             onCreateCollection=handleCreateCollection
             onSelectCollection=handleSelectCollection
             onLogout=handleLogout
           />
         | None =>
           <AuthCard
             mode
             onModeChange=handleModeChange
             form
             onFormChange=updateForm
             onSubmit=handleSubmit
             isSubmitting
             error={error->Js.Nullable.fromOption}
           />
         }
       }}
    </div>
  </main>
}
