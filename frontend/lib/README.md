# lib folder

This folder contains the application’s core source code and is organized using a layered Clean Architecture style.

## Structure overview

- core: shared infrastructure, design system, routing, storage, and reusable UI
- data: data access and repository implementations
- domain: business rules, entities, repositories, and use cases
- features: feature-specific screens, providers, and UI logic
- error: central error handling helpers

## How the app flows

1. The UI in the features layer requests data through providers or screens.
2. The domain layer defines the business rules and use cases.
3. The data layer implements repositories and communicates with APIs or local storage.
4. Core utilities provide shared services such as networking, routing, and theming.

## Design intent

The folder is organized so that UI changes do not tightly couple business logic to presentation. This makes the app easier to scale, test, and maintain.
