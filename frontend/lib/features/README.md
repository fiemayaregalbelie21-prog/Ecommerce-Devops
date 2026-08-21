# features

This folder contains the UI and feature-specific logic for each user-facing module of the app.

## Structure

Each feature is organized around its own screen or feature area, usually with a presentation folder that contains widgets, screens, and providers.

## Logic and purpose

The features layer is where the app becomes user-facing. It coordinates the UI, listens to state, and requests data from the domain layer. Each feature is designed to be mostly self-contained so it can be developed and tested independently.

## Typical feature flow

1. The screen is rendered.
2. The provider or controller watches user input and app state.
3. The feature requests data through use cases or repositories.
4. The UI renders loading, success, error, or empty states depending on the response.
