type wine = {
  id: int,
  producer: option<string>,
  name: string,
  vintage: option<int>,
  style: option<string>,
  grape: option<string>,
  region: option<string>,
  country: option<string>,
}

type entry = {
  id: int,
  collectionId: int,
  wine: wine,
  createdByUserId: int,
  consumedAt: string,
  venueName: option<string>,
  locationText: option<string>,
  pairingNotes: option<string>,
  tastingNotes: option<string>,
  rating: option<int>,
}
