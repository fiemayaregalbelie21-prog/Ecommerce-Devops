# data

The data layer is responsible for fetching, transforming, and storing app data. It sits between the domain layer and the outside world.

## What belongs here

- datasources: API clients and local data access points
- models: data transfer objects used to parse or structure incoming data
- repositories: concrete implementations of repository contracts from the domain layer

## Typical logic flow

1. A repository implementation receives a request from the domain layer.
2. It uses a datasource to fetch or save the data.
3. The raw data is converted into models.
4. The repository returns data in a form that the domain layer can use.

## Purpose

This layer isolates the rest of the app from network details, storage details, and API-specific structures. It keeps the business logic clean and makes the app easier to change if the backend or storage solution changes.
