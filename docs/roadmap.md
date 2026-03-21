# Roadmap

This roadmap breaks the app into small, useful milestones that can be delivered and tested incrementally.

It is based on:

- [App Overview](/Users/mats/src/personal/wine/docs/app-overview.md)
- [Domain Model](/Users/mats/src/personal/wine/docs/domain-model.md)

The intent is to build thin vertical slices rather than large batches of backend-only or frontend-only work.

## Principles

- Keep each task small enough to finish in one focused change.
- Prefer end-to-end slices over broad scaffolding.
- Add tests with each behavior change.
- Commit after every stable change, not only at milestone boundaries.
- Preserve simple domain boundaries:
  - auth and access control at the edge
  - business rules in testable backend modules
  - browser/media handling isolated in frontend wrappers

## Commit strategy

Milestones are planning buckets, not commit sizes.

Prefer small commits that leave the app in a stable, understandable state.

Good commit units:

- one migration or schema step
- one backend behavior
- one frontend behavior
- one focused refactor with tests
- one test-only fix

Avoid bundling an entire milestone into one commit if the work can be split into smaller verified steps.

Examples:

- `add users migration`
- `add password hashing service`
- `add register endpoint`
- `add signup form`

## Milestone 1: Authentication foundation

Goal: a user can create an account, log in, and reach an authenticated app shell.

### 1.1 Add schema migrations for core tables

Scope:

- add migrations for `users`
- add migrations for `collections`
- add migrations for `collection_memberships`
- add migrations for `wines`
- add migrations for `wine_entries`

Acceptance criteria:

- backend can initialize the schema from migrations
- schema reflects the current domain model at a basic level
- migration behavior is covered by at least one integration test or startup verification path

### 1.2 Add backend migration runner

Scope:

- run migrations on backend startup or through a dedicated startup path
- fail clearly if migrations cannot be applied

Acceptance criteria:

- local Docker workflow starts with schema applied
- startup failure is explicit when database setup is invalid

### 1.3 Add backend database/repository layer

Scope:

- introduce small modules for DB access
- keep HTTP handlers thin
- move ad hoc SQL out of route handlers

Acceptance criteria:

- new backend behavior does not embed SQL directly in handlers
- at least one repository/service path is covered by focused tests

### 1.4 Add user registration

Scope:

- create `POST /api/auth/register`
- store email and password hash
- reject invalid or duplicate registrations

Acceptance criteria:

- user can register with email and password
- duplicate email registration is rejected
- password is stored hashed, not plaintext
- happy path and failure path are tested

### 1.5 Add login and session/token auth

Scope:

- create `POST /api/auth/login`
- return a session/token the frontend can reuse
- add auth middleware/extractor

Acceptance criteria:

- valid credentials log the user in
- invalid credentials are rejected
- authenticated routes can identify the current user
- auth behavior has regression coverage

### 1.6 Add `GET /api/me`

Scope:

- return current user identity for an authenticated session

Acceptance criteria:

- authenticated request returns user identity
- unauthenticated request is rejected

### 1.7 Add frontend auth flow

Scope:

- add sign-up screen
- add login screen
- persist session/token in the frontend
- add logout

Acceptance criteria:

- user can register, log in, reload, and remain signed in
- user can log out and return to the auth screen
- UI handles loading and auth errors explicitly

## Milestone 2: Collections

Goal: a user can create and access wine collections.

### 2.1 Add collection persistence module

Scope:

- add a small backend module for collection queries and commands
- keep collection SQL out of route handlers

Acceptance criteria:

- collection-related handlers depend on a dedicated backend module
- at least one collection persistence path has focused tests

### 2.2 Add create-collection backend behavior

Scope:

- add backend service/repository logic to create a collection
- create an owner membership for the creator in the same operation

Acceptance criteria:

- creating a collection persists both the collection and owner membership
- creator becomes owner automatically
- failure paths do not leave partial collection state behind

### 2.3 Add create-collection endpoint

Scope:

- create `POST /api/collections`

Acceptance criteria:

- authenticated user can create a collection
- request/response payloads are explicit
- unauthenticated request is rejected

### 2.4 Add list-my-collections backend behavior

Scope:

- add backend query logic to return collections for the current user
- include membership role needed by the frontend

Acceptance criteria:

- user only sees collections they belong to
- collection listing order is explicit and stable
- focused tests cover both visible and non-visible collections

### 2.5 Add list-my-collections endpoint

Scope:

- create `GET /api/collections`

Acceptance criteria:

- user only sees collections they belong to
- response shape is stable and explicit

### 2.6 Add frontend collection API module

Scope:

- add dedicated frontend collection API calls
- isolate collection transport details from components

Acceptance criteria:

- collection fetch/create calls live outside UI components
- loading and error paths are explicit at the module boundary

### 2.7 Add frontend collection list and empty state

Scope:

- show current user collections in the authenticated shell
- add a clear empty state when none exist

Acceptance criteria:

- empty state is handled clearly
- collection loading and fetch errors are visible in the UI

### 2.8 Add collection creation UI

Scope:

- add a minimal create-collection form
- append or refresh the collection list after successful creation

Acceptance criteria:

- authenticated user can create a collection from the UI
- newly created collections appear in the UI
- duplicate submit and failure states are handled explicitly

### 2.9 Add frontend collection selection state

Scope:

- allow selecting a collection from the list
- persist selected collection in frontend state

Acceptance criteria:

- selected collection is reflected in app state
- reloading preserves a sensible selection when possible
- empty and missing-selection states are handled explicitly

### 2.10 Enforce membership-based access control

Scope:

- require membership for collection-scoped routes

Acceptance criteria:

- users cannot read or modify collections they do not belong to
- access-control checks are covered by tests

### 2.11 Add invite lookup/create backend behavior

Scope:

- add backend logic to invite a user by email
- create membership for an existing user or record an invite path for later completion

Acceptance criteria:

- owner can invite by email through a single backend path
- inviting an existing member is rejected cleanly
- non-owners cannot create memberships

### 2.12 Add invite endpoint

Scope:

- create collection invite API endpoint
- validate collection membership and role at the edge

Acceptance criteria:

- collection owner can invite another user
- non-members and non-owners are rejected
- request and error payloads are explicit

### 2.13 Add frontend invite UI

Scope:

- add a minimal invite-by-email form on the selected collection view
- surface success and error states clearly

Acceptance criteria:

- owner can invite another user from the UI
- invite success is visible without page reload
- authorization failures are visible in the UI

### 2.14 Add invited-user access verification

Scope:

- verify that an invited or newly added user can list and access the collection
- keep the first implementation simple even if the invite flow is immediate membership

Acceptance criteria:

- invited user can gain access to the collection
- collection appears in the invited user’s list
- regression coverage proves the end-to-end collection sharing path

### 2.15 Add browser-level collection smoke test

Scope:

- extend Playwright coverage to the core collection flow
- cover create and list behavior against the isolated test stack

Acceptance criteria:

- browser test can create a collection and see it appear in the UI
- test runs only against the isolated test stack

## Milestone 3: Wine browsing, history, and entry capture

Goal: a user can browse wines within a collection, inspect their prior occasions, and quickly add a new wine-drinking occasion when needed.

Notes:

- treat wines as the main collection screen
- keep entry creation easy to reach, but do not make an inline capture form the default primary surface

### 3.1 Add wine create/reuse backend logic

Scope:

- create a wine when no match exists
- reuse an existing wine when the user selects one
- keep matching logic simple at first

Acceptance criteria:

- repeated entries can reference the same wine
- separate occasions remain separate entries

### 3.2 Add create-entry endpoint

Scope:

- create `POST /api/collections/:id/entries`
- accept essential wine and occasion fields

Acceptance criteria:

- authenticated collection member can create an entry
- entry is linked to both collection and wine
- invalid input is rejected with explicit errors

### 3.3 Add entry history endpoint

Scope:

- create `GET /api/collections/:id/entries`
- return entries ordered by `consumed_at`

Acceptance criteria:

- collection member can browse history for one collection
- non-member access is rejected
- ordering is deterministic

### 3.4 Add collection wines endpoint

Scope:

- create `GET /api/collections/:id/wines`
- return wines in a collection with enough summary data for browsing
- include summary metadata needed for sorting and scanning

Acceptance criteria:

- collection member can browse wines for one collection
- non-member access is rejected
- response shape makes wine-first UI practical without extra client-side stitching

### 3.5 Add wine-first collection screen

Scope:

- make wines the primary content for the selected collection
- show enough wine summary data for quick browsing
- include a clear empty state and a clearly accessible add action

Acceptance criteria:

- user can browse wines from the main collection screen
- empty wine state is clear
- the main screen is optimized for browsing wines rather than inline data entry
- add-entry action is easy to find on mobile widths

### 3.6 Add wine detail with related entry history

Scope:

- let the user open a wine from the main wine list
- show the related entries/occasions for that wine
- keep wine identity and occasion details visually distinct

Acceptance criteria:

- user can open a wine from the main collection screen
- user can browse the related occasions for that wine
- repeated wines are clearly represented as one wine with multiple entries

### 3.7 Add mobile-first entry creation flow

Scope:

- implement a minimal dedicated “new entry” flow
- start with essential fields only:
  - wine name
  - producer
  - grape
  - vintage
  - consumed date/time, which defaults to "now"
  - venue/location
  - pairing notes
  - tasting notes
  - rating

Acceptance criteria:

- user can create an entry from a mobile-sized viewport
- form handles missing optional wine metadata gracefully
- success and validation errors are visible in the UI

### 3.8 Add entry detail screen

Scope:

- show wine details, occasion details, notes, and rating

Acceptance criteria:

- user can open an entry from history
- detail screen shows stable wine data separately from occasion data

### 3.9 Add entry editing

Scope:

- support editing the main mutable fields on an entry

Acceptance criteria:

- collection member can edit an existing entry
- updates are reflected in history and detail views
- unauthorized edits are rejected

## Milestone 4: Search and repeated use

Goal: users can find past entries and compare repeated wines.

### 4.1 Add basic search/filter endpoint

Scope:

- support filtering by:
  - wine name
  - producer
  - date
  - rating

Acceptance criteria:

- filters return only entries in the current collection
- empty results are explicit and not treated as errors

### 4.2 Add frontend search/filter UI

Scope:

- add simple search/filter controls to the history view

Acceptance criteria:

- user can narrow entry history without leaving the page
- filters are understandable on mobile

### 4.3 Add repeated-wine comparison support

Scope:

- surface prior entries for the same wine on entry detail or wine-related views

Acceptance criteria:

- user can tell when a wine has been logged before
- repeated occasions remain separate records

## Milestone 5: Photos

Goal: users can attach bottle and meal/pairing photos from mobile.

### 5.1 Add photo metadata schema

Scope:

- add `photos` table and relations

Acceptance criteria:

- schema supports photos attached to a wine entry
- photo kinds are explicit

### 5.2 Add backend upload/storage abstraction

Scope:

- add upload endpoint(s)
- store structured photo metadata in PostgreSQL
- keep binary storage separate from relational data

Acceptance criteria:

- uploaded photos produce stored metadata records
- storage concerns are isolated behind a small backend module

### 5.3 Add mobile photo capture/upload UI

Scope:

- support choosing or capturing:
  - bottle photo
  - pairing photo

Acceptance criteria:

- flow works in mobile browsers
- user can attach at least one photo during entry creation or edit
- upload failures are shown clearly

### 5.4 Show photos in entry detail

Scope:

- render uploaded images in entry detail

Acceptance criteria:

- photos appear in the associated entry view
- missing photos do not break the screen

## Milestone 6: Optional polish

Goal: add only the features that still feel valuable after the core workflow is stable.

### 6.1 Add favorites

Scope:

- allow users to mark wines or entries as favorites

Acceptance criteria:

- favorite behavior has a clear domain home
- implementation does not blur the distinction between wine and wine entry

## Recommended implementation order

1. Milestone 1
2. Milestone 2
3. Milestone 3
4. Milestone 4
5. Milestone 5
6. Milestone 6

## Suggested check-in points

### Check-in A

- user can sign up, log in, and see an authenticated shell

### Check-in B

- user can create a collection and switch between collections

### Check-in C

- user can create and browse wine entries in one collection

### Check-in D

- second user can be invited into a collection

### Check-in E

- user can attach and view photos from mobile
