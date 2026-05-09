@send
external preventDefault: ReactEvent.Form.t => unit = "preventDefault"

@react.component
let make = () => {
  let route = Router.useRoute()
  let (mode, setMode) = React.useState(() => AuthForm.loginMode)
  let (form, setForm) = React.useState(() => AuthForm.initialForm)
  let (currentUser, setCurrentUser) = React.useState(() => None)
  let (sessionToken, setSessionToken) = React.useState(() => None)
  let (isInitializing, setIsInitializing) = React.useState(() => true)
  let (isSubmitting, setIsSubmitting) = React.useState(() => false)
  let (error, setError) = React.useState(() => None)
  let (wineStatus, setWineStatus) = React.useState(() => WineState.initialStatus())
  let (wineForm, setWineForm) = React.useState(() => WineCapture.initialForm)
  let (wineOccasionFilter, setWineOccasionFilter) = React.useState(() => WineState.initialOccasionFilter)
  let (wineQuery, setWineQuery) = React.useState(() => "")
  let (entryStatus, setEntryStatus) = React.useState(() => EntryState.initialStatus())
  let (entryForm, setEntryForm) = React.useState(() => EntryState.initialForm)

  let defaultCollectionId =
    currentUser->Belt.Option.map((user: AuthSession.user) => user.defaultCollectionId)

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
        setIsInitializing(_ => false)
        Js.Promise2.resolve()
      })
      ->ignore
    | None =>
      setIsInitializing(_ => false)
    }
    None
  })

  React.useEffect2(() => {
    switch (sessionToken, defaultCollectionId) {
    | (Some(token), Some(collectionId)) =>
      setWineStatus(_ => WineState.loadingStatus())
      WineState.listWines(token, collectionId)
      ->Js.Promise2.then(wines => {
        setWineStatus(_ => WineState.readyStatus(wines))
        Js.Promise2.resolve()
      })
      ->Js.Promise2.catch(_ => {
        setWineStatus(_ => WineState.errorStatus(AuthAppSupport.describeEntryHistoryError()))
        Js.Promise2.resolve()
      })
      ->ignore

      setEntryStatus(_ => EntryState.loadingStatus())
      EntryState.listEntries(token, collectionId)
      ->Js.Promise2.then(entries => {
        setEntryStatus(_ => EntryState.readyStatus(entries))
        Js.Promise2.resolve()
      })
      ->Js.Promise2.catch(_ => {
        setEntryStatus(_ => EntryState.errorStatus(AuthAppSupport.describeEntryHistoryError()))
        Js.Promise2.resolve()
      })
      ->ignore
    | _ =>
      setWineStatus(_ => WineState.initialStatus())
      setEntryStatus(_ => EntryState.initialStatus())
    }
    None
  }, (sessionToken, defaultCollectionId))

  let updateForm = (field, value) => {
    setForm(current => AuthForm.updateForm(current, field, value))
    setError(_ => None)
  }

  let handleModeChange = nextMode => {
    setMode(_ => nextMode)
    setError(_ => None)
  }

  let updateEntryForm = (field, value) =>
    setEntryForm(current => EntryState.updateForm(current, field, value))

  let updateWineForm = (field, value) =>
    setWineForm(current => WineCapture.updateForm(current, field, value))

  let handleSubmit = event => {
    event->preventDefault
    setIsSubmitting(_ => true)
    setError(_ => None)
    AuthForm.submit(mode, form)
    ->Js.Promise2.then(payload => {
      SessionStorage.saveSessionToken(payload.token)
      setSessionToken(_ => Some(payload.token))
      setCurrentUser(_ => Some(payload.user))
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
    setWineStatus(_ => WineState.initialStatus())
    setWineForm(_ => WineCapture.initialForm)
    setEntryStatus(_ => EntryState.initialStatus())
    setEntryForm(_ => EntryState.initialForm)
    setError(_ => None)
    setMode(_ => AuthForm.loginMode)
    Router.navigate(Home)
  }

  let useSelectedWineForEntry = () =>
    switch route {
    | Router.NewEntry(wineId) | Router.EditEntry(wineId, _) =>
      switch WineState.wines(wineStatus)->Belt.Array.getBy(summary => summary.wine.id == wineId) {
      | Some(summary) => setEntryForm(current => EntryState.useExistingWine(current, summary.wine))
      | None => ()
      }
    | _ => ()
    }

  let useNewWineForEntry = () =>
    setEntryForm(current => EntryState.useNewWine(current))

  let handleCreateWine = () =>
    switch (sessionToken, defaultCollectionId) {
    | (Some(token), Some(collectionId)) if !wineForm.isSubmitting =>
      setWineForm(current => WineCapture.startSubmitting(current))
      WineCapture.createWine(token, collectionId, wineForm)
      ->Js.Promise2.then((summary: WineModel.summary) => {
        WineState.listWines(token, collectionId)
        ->Js.Promise2.then(wines => {
          setWineStatus(_ => WineState.readyStatus(wines))
          Js.Promise2.resolve()
        })
        ->ignore
        setWineForm(_ => WineCapture.initialForm)
        Router.navigate(Wine(summary.wine.id))
        Js.Promise2.resolve()
      })
      ->Js.Promise2.catch(reason => {
        setWineForm(current => WineCapture.failForm(current, AuthAppSupport.describeWineError(reason)))
        Js.Promise2.resolve()
      })
      ->ignore
    | _ => ()
    }

  let handleCreateEntry = () =>
    switch (sessionToken, defaultCollectionId, route) {
    | (Some(token), Some(collectionId), Router.EditEntry(wineId, entryId)) if !entryForm.isSubmitting =>
      setEntryForm(current => EntryState.startSubmitting(current))
      EntryState.updateEntry(token, collectionId, entryId, entryForm)
      ->Js.Promise2.then(entry => {
        WineState.listWines(token, collectionId)
        ->Js.Promise2.then(wines => {
          setWineStatus(_ => WineState.readyStatus(wines))
          Js.Promise2.resolve()
        })
        ->ignore
        setEntryStatus(current =>
          if EntryState.isReady(current) {
            EntryState.readyStatus(EntryState.replaceEntry(EntryState.entries(current), entry))
          } else {
            current
          }
        )
        setEntryForm(_ => EntryState.succeedForm())
        Router.navigate(Wine(wineId))
        Js.Promise2.resolve()
      })
      ->Js.Promise2.catch(reason => {
        setEntryForm(current => EntryState.failForm(current, AuthAppSupport.describeEntryError(reason)))
        Js.Promise2.resolve()
      })
      ->ignore
    | (Some(token), Some(collectionId), Router.NewEntry(wineId)) if !entryForm.isSubmitting =>
      setEntryForm(current => EntryState.startSubmitting(current))
      EntryState.createEntry(token, collectionId, entryForm)
      ->Js.Promise2.then(entry => {
        WineState.listWines(token, collectionId)
        ->Js.Promise2.then(wines => {
          setWineStatus(_ => WineState.readyStatus(wines))
          Js.Promise2.resolve()
        })
        ->ignore
        setEntryStatus(current =>
          if EntryState.isReady(current) {
            EntryState.readyStatus(EntryState.appendEntry(EntryState.entries(current), entry))
          } else {
            current
          }
        )
        setEntryForm(_ => EntryState.succeedForm())
        Router.navigate(Wine(wineId))
        Js.Promise2.resolve()
      })
      ->Js.Promise2.catch(reason => {
        setEntryForm(current => EntryState.failForm(current, AuthAppSupport.describeEntryError(reason)))
        Js.Promise2.resolve()
      })
      ->ignore
    | _ => ()
    }

  // Slice 1 has no UI affordance to edit a specific occasion (deferred to a later slice).
  // The EditEntry route is reachable only by typing the URL; a no-op handler keeps the
  // prop wiring honest without speculating on UX.
  let openEntryEditor = () => ()

  let visibleWineStatus = WineState.filterStatus(wineStatus, wineQuery, wineOccasionFilter)

  <main className="min-h-screen bg-[radial-gradient(circle_at_top,_rgba(234,214,196,0.9),_transparent_45%),linear-gradient(180deg,_#f7efe7_0%,_#ead9ca_100%)] px-6 py-12 text-stone-950">
    <div className="mx-auto flex min-h-[calc(100vh-6rem)] max-w-5xl items-center justify-center">
      {if isInitializing {
         <section className="w-full max-w-md rounded-3xl border border-stone-900/10 bg-white/80 p-8 text-sm text-stone-600 shadow-xl backdrop-blur">
           {React.string("Checking your session...")}
         </section>
       } else {
         switch currentUser {
         | Some(user) =>
           <AppShell
             user
             route
             wineStatus=visibleWineStatus
             wineForm
             wineOccasionFilter
             wineQuery
             totalWineCount={WineState.wines(wineStatus)->Belt.Array.length}
             entryStatus
             entryForm
             onEntryFormChange=updateEntryForm
             onUseSelectedWineForEntry=useSelectedWineForEntry
             onUseNewWineForEntry=useNewWineForEntry
             onWineFormChange=updateWineForm
             onCreateWine=handleCreateWine
             onCreateEntry=handleCreateEntry
             onEditEntry=openEntryEditor
             onWineQueryChange={query => setWineQuery(_ => query)}
             onSelectOccasionFilter={filter => setWineOccasionFilter(_ => filter)}
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
