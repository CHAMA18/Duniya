---
title: Developer Guide
description: Technical documentation for developers contributing to Duniya or integrating with the platform.
---

# Developer Guide

This section is for developers who want to understand how Duniya works
under the hood, contribute to the codebase, or integrate with the
platform programmatically.

## Pages

| Page | Description |
|---|---|
| **[Architecture](architecture.md)** | The high-level tech stack — Flutter web, Firebase, Firestore, and external integrations. |
| **[Data Model](data-model.md)** | Complete reference for every Firestore collection and subcollection, with field types and relationships. |
| **[Build & Deploy](build-deploy.md)** | How to build the Flutter web app from source and deploy it to production. |

## Who this section is for

- **Contributors** — developers adding features or fixing bugs in the
  Duniya codebase.
- **Integrators** — developers building external systems that need to
  read or write Duniya data via Firestore.
- **Auditors** — security and compliance reviewers who need to understand
  the data flow.

## Tech stack at a glance

| Layer | Technology |
|---|---|
| Client | Flutter Web (Material 2) |
| Routing | go_router 12.1.3 |
| Backend | Firebase (Auth, Firestore, Storage) |
| Search | Algolia |
| Payments | DPO (Zambia), Stripe (international) |
| Subscriptions | RevenueCat |
| AI | OpenAI ChatGPT (preview) |
| Hosting | Static web (Docker + nginx, or any static host) |

## Getting started

1. Read the [Architecture](architecture.md) page to understand the
   high-level design.
2. Skim the [Data Model](data-model.md) to familiarise yourself with the
   Firestore schema.
3. Follow the [Build & Deploy](build-deploy.md) guide to run the app
   locally.

## Conventions

- **Purple is the source of truth.** The primary color `#9900FF` must be
  preserved across all rebuilds. See the warning in
  [Architecture → Theme tokens](architecture.md#theme-tokens).
- **FlutterFlow models.** Each page has a corresponding model class in
  `<page>_model.dart`. See
  [Architecture → State management](architecture.md#state-management).
- **Parent reference pattern.** Subcollections are scoped under the
  Owner's user document. See
  [Architecture → Parent reference pattern](architecture.md#parent-reference-pattern).
