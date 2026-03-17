type collection = {
  id: int,
  name: string,
  role: string,
}

let isOwner = collection => collection.role == "owner"
