# core

This folder contains the shared foundation of the app. It is not feature-specific and should be reused by every part of the application.

## What belongs here

- constants: hard-coded app values, category labels, and app-wide mappings
- di: dependency injection and Riverpod provider wiring
- network: HTTP client setup such as Dio configuration
- router: navigation setup and route definitions
- storage: local persistence, such as Hive access
- theme: colors, typography, and theme definitions
- utils: small helper functions for formatting and responsiveness
- widgets: reusable UI building blocks used across multiple screens

## Logic and purpose

The core layer is the infrastructure layer. It provides the app with consistent styling, shared services, and common utilities so that features can stay focused on user behavior rather than reimplementing basic systems.
