# auth feature

This feature handles user authentication flows.

## What it contains

- login and guest continuation flows
- state related to the current user session
- UI screens and providers for sign-in experience

## Logic

The auth feature coordinates the user interaction layer with the domain use cases. When a user signs in or continues as guest, the feature calls the relevant use case and updates the app state accordingly.
