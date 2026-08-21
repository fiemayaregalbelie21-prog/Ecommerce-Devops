# search feature

This feature powers the app’s search experience.

## What it contains

- search screen UI
- recent searches and suggestion logic
- providers that connect the search input to product results

## Logic

The user types into the search field, the query is stored in state, and the app uses that input to fetch matching products. Recent searches are also stored so the user can quickly revisit previous terms. The screen switches between suggestion views and result views depending on whether the search box is empty.
