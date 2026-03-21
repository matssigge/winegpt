# App Overview

## Purpose

This application helps users keep a record of wines they have drunk. 

The primary value is helping users remember good wines they have had before and the context around them.

Users can record:
- which wine they drank
- when they drank it
- where they drank it
- what food or other context it was paired with
- their own notes and impressions
- photos of the bottle
- photos of the pairing or meal

Users can maintain their own records or share collections with other people such as spouses or partners.

---

## Goals

The system should make it easy for a user to:

- quickly recall wines they have enjoyed before
- browse and search wines within a collection
- open a wine and inspect the occasions when they have had it before
- compare past experiences with the same wine
- remember what a wine paired well with
- quickly log a wine from a mobile device when needed
- capture useful context at the moment of drinking
- attach one or more photos
- maintain a shared wine history with a partner or household
- mark a wine as a favorite

The system should prioritize:

- wine browsing and recall over data entry density on the main screen
- low operational complexity
- simple deployment
- fast and reliable everyday use
- good mobile browser support
- clear and maintainable domain modeling

---

## Core Capabilities

### Entry capture

Users can create a wine entry with structured and free-form information.

Entry capture should be fast and easy to access, but it is not the primary focus of the main collection screen.

The main collection screen should emphasize browsing wines and then opening their related history.

Creating a new entry should happen through a clearly accessible action such as an add button that opens a dedicated capture flow.

A wine entry may include:

- wine name
- producer
- vintage
- grape or style
- region or country
- date and time consumed
- venue or location
- pairing notes
- tasting notes
- personal rating
- bottle photo
- pairing photo

Entries belong to a **wine collection**.

---

### Collections

A **Wine Collection** is a shared space where wine entries are stored.

Examples:

- a personal wine journal
- a shared household wine record
- a couple’s shared wine history

A collection may have one or multiple users who can add entries.

Typical use cases:

- spouses sharing a wine record
- partners logging wines they drink together
- one person logging wines for a shared household

Collections should be easy to create and share with another user.

---

### Wine browsing

Users can browse wines within a collection.

This is the central product surface.

The default collection view should help users:

- scan the wines they have recorded before
- search by producer, wine name, grape, vintage, pairings, or related text
- open a wine to inspect prior occasions
- quickly decide whether they are looking at a known wine or need to add a new one

---

### Entry history

Users can browse wine entries within a collection, usually through a selected wine.

Entries should be sortable and filterable.

This is an important supporting surface, not the first thing the user should land on.

Users should be able to:

- open a wine and quickly scan its related entries
- open an entry to inspect wine details and occasion details
- search or filter when trying to remember a bottle, producer, pairing, or prior impression

---

### Search and filtering

Users can find entries by fields such as:

- wine name
- producer
- vintage
- date
- venue
- rating
- pairing notes

---

### Repeated wines

Users should be able to record the same wine multiple times on different occasions.

Each drinking occasion should be preserved as a separate entry, but linked to the same wine.

---

### Photos

Users can capture or upload photos from mobile browsers:

- bottle photos
- pairing or meal photos

Camera access should work easily on mobile devices.

---

## Primary Users

The primary users are individuals or small groups maintaining a shared wine journal.

Typical scenarios:

- a single user keeping a personal wine log
- a couple sharing a wine collection
- a small household tracking wines together

The system is **not designed for large collaborative communities or public social feeds**.

---

## Architecture

### Frontend

Mobile-friendly web application built with ReScript and React.

### Backend

Rust service using Axum and SQLx.

### Database

PostgreSQL

### Deployment

Docker Compose on a single host.

### Media handling

Photos are uploaded through the web app and stored separately from structured entry data.

---

## Core User Flow

Typical flow:

1. User wants to remember a wine they had before
2. User opens the app
3. User selects a collection
4. User browses or searches wines in the collection
5. User opens a matching wine
6. User inspects the related occasions and notes for that wine
7. If needed, the user opens a specific entry to inspect the full wine and occasion details
8. If the wine is new, the user taps an add action
9. User records wine details
10. User adds notes, pairing information, and optionally photos
11. User saves the entry
12. Users in the same collection can later find that wine again and review its prior occasions

The logging flow should be fast and forgiving, but the default screen should optimize for finding wines first.

Users may not always know every structured detail about a wine.

---

## Design Principles

- Optimize for quick recall first and quick capture second
- Mobile first with a solid desktop experience
- Prefer simple and explicit data models
- Preserve user-entered history
- Separate wine identity from drinking occasions
- Treat photos as first-class supporting data
- Keep sharing simple and predictable
- Avoid complex permission systems

---

## Non-goals

The system does not currently aim to provide:

- public wine review platforms
- social timelines
- influencer features
- wine marketplace integrations
- professional cellar management
- restaurant inventory systems
- large-scale multi-tenant collaboration

---

## Constraints

- Must work well in mobile browsers
- Must support camera access easily
- Must run well on low-end hardware
- Must be deployable with a small number of containers
- Must remain easy to understand and maintain

---

## Initial Scope

Initial version should support:

- user authentication
- creating wine collections
- inviting another user to a collection
- creating wine entries in a collection
- browsing wines in a collection
- opening a wine and seeing its entry history
- opening an entry from history
- attaching photos
- basic search/filtering
- editing entries
