@react.component
let make = () => {
  <main className="min-h-screen bg-[radial-gradient(circle_at_top,_rgba(234,214,196,0.9),_transparent_45%),linear-gradient(180deg,_#f7efe7_0%,_#ead9ca_100%)] px-6 py-12 text-stone-950">
    <div className="mx-auto flex min-h-[calc(100vh-6rem)] max-w-5xl items-center justify-center">
      <section className="w-full max-w-3xl rounded-[2rem] border border-stone-900/10 bg-white/75 p-8 shadow-[0_24px_80px_rgba(81,46,23,0.12)] backdrop-blur md:p-12">
        <p className="mb-3 font-mono text-xs uppercase tracking-[0.35em] text-stone-600">
          {"Wine"->React.string}
        </p>
        <h1 className="max-w-2xl font-serif text-5xl leading-none tracking-[-0.04em] text-stone-950 md:text-7xl">
          {"Scaffold is wired up."->React.string}
        </h1>
        <p className="mt-6 max-w-xl text-base leading-7 text-stone-700 md:text-lg">
          {"Backend health endpoint: http://127.0.0.1:3000/api/health"->React.string}
        </p>
      </section>
    </div>
  </main>
}
