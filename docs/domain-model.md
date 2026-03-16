# Domain Model

## Overview

The domain is centered around **Wine Entries recorded within Wine Collections**.

Key distinction:

- **Wine** = the wine itself
- **Wine Entry** = a specific occasion when a wine was consumed
- **Wine Collection** = a shared container for wine entries

This allows multiple users to share the same wine history.

---

# Core Entities

## User

A person with an account in the system.

Users can:

- belong to one or more wine collections
- create wine entries
- upload photos
- view entries within collections they belong to

Key properties:

- id
- email
- optional full name
- authentication credentials
- created_at
- updated_at

---

## Wine Collection

A shared container for wine entries.

A collection represents a shared wine journal.

Examples:

- a personal wine log
- a shared household wine record
- a couple’s wine history

Key properties:

- id
- name
- created_at
- updated_at

---

## Collection Membership

Links users to collections.

Defines which users can access and contribute to a collection.

Key properties:

- id
- collection_id
- user_id
- role

Roles may initially be simple:

- owner
- member

---

## Wine

A wine as an identifiable product.

Wine represents the relatively stable identity of a wine across occasions.

Possible attributes:

- producer
- name
- vintage
- style
- grape
- region
- country

Key properties:

- id
- producer
- name
- vintage
- style
- grape
- region
- country
- created_at
- updated_at

Wine information may be incomplete.

---

## Wine Entry

A specific drinking occasion.

Wine entries belong to a **collection**.

Key properties:

- id
- collection_id
- wine_id
- created_by_user_id
- consumed_at
- venue_name
- location_text
- pairing_notes
- tasting_notes
- rating
- created_at
- updated_at

Notes:

- multiple entries may reference the same wine
- different users in the same collection may add entries

---

## Photo

An image associated with a Wine or a Wine Entry.

Key properties:

- id
- wine_entry_id
- kind
- storage_key
- original_filename
- mime_type
- width
- height
- created_at

Photo kinds:

- bottle
- label
- pairing
- other

---

# Relationships

User
- belongs to many Wine Collections

Wine Collection
- has many Users
- has many Wine Entries

Wine Entry
- belongs to one Wine Collection
- belongs to one Wine
- has many Photos
- created by one User

Wine
- has many Wine Entries
- has many Photos

Photo
- belongs to one Wine Entry or one Wine, not both

---

# Invariants

### Collection ownership

Wine entries always belong to exactly one collection.

### Access

Users may only view or modify entries within collections they belong to.

### Entry identity

Each wine entry represents a single drinking occasion.

Entries must not be merged automatically.

### Wine reuse

Multiple entries may reference the same wine.

### Ratings

Ratings belong to a wine entry, not to the wine globally.

### Photos

Photos belong to wine entries or wines, not both

### Partial data

Wine information may be incomplete.

---

# Modeling Guidance

Interpret the model as:

Wine Collection  
→ shared journal

Wine  
→ the product

Wine Entry  
→ an occasion

Photo  
→ supporting evidence for a Wine Entry
OR 
→ "profile photo" for a Wine

Avoid:

- storing tasting notes on wine instead of entry
- over-normalizing venues early
- building complex permission systems

---

# Initial Simplifications

The first version should remain simple:

- collections have simple roles
- venue remains text
- pairing notes remain text
- wine matching can be basic
- no public sharing
- no complex invitation workflows

Introduce additional structure only when real use cases justify it.