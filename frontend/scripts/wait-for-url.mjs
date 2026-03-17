const [url] = process.argv.slice(2)

if (!url) {
  throw new Error("Expected a URL to wait for")
}

const deadline = Date.now() + 30_000

while (Date.now() < deadline) {
  try {
    const response = await fetch(url)

    if (response.ok) {
      process.exit(0)
    }
  } catch {
    // Retry until the deadline expires.
  }

  await new Promise(resolve => setTimeout(resolve, 500))
}

throw new Error(`Timed out waiting for ${url}`)
