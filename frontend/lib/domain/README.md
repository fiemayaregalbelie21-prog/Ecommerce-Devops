# domain

The domain layer contains the business logic of the application. It defines what the app should do, independent of UI and infrastructure details.

## What belongs here

- entities: core business objects such as users and products
- repositories: abstract contracts that describe data access expectations
- usecases: single-purpose business actions such as login, logout, or fetching products

## Logic and purpose

Use cases represent the main actions the app can perform. They keep the business rules in one place and prevent screens from directly knowing about API or storage implementation details.

## Example flow

A screen may call a use case such as login. The use case delegates to a repository interface, and the concrete implementation is resolved in the data layer. This keeps the feature code focused on user interaction while the domain layer governs the rules.
