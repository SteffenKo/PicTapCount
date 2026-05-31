# ARCHITECTURE.md

## Stack

* Flutter
* Dart
* Riverpod
* Hive
* GoRouter
* image_picker

## Architecture Style

Feature-first architecture.

## Data Model

Photo

* id
* title
* imagePath
* createdAt
* countLayers

CountLayer

* id
* name
* color
* points

Point

* x
* y

## MVP Constraint

Only one CountLayer is active.

However the architecture must support multiple layers later.

## State Management

Riverpod only.

No Provider.
No Bloc.

## Persistence

Hive for metadata.

Image files stored locally.

Hive stores:

* title
* image path
* count data
* timestamps

## Localization

Supported languages:

* German
* English

All strings must be localized.

## UI

Material Design 3

Colors:

Background: White

Text: Black

Accent: #B2FFFF

Dark mode not required in MVP.
