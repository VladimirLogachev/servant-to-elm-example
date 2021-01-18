# servant-to-elm-example

<img src="screenshot.png" alt="servant-to-elm-example" width="500"/>

This example is a full-stack web application, built in a typesafe functional way.

What's cool here is that [servant-to-elm] does the job of generating types and decoders/encoders from Haskell types and [Servant] definition to Elm, which not only catches regressions in the compile-time but also provides ready (and highly configurable) Elm functions to fetch necessary data from the server.

## Install

- Install [Stack] and [Elm]
- Run code generation
  ```sh
  cd backend && stack run codegen
  ```
- Install frontend dependencies (it's only `elm-live`)
  ```sh
  cd frontend && npm i
  ```

## Run

- Start the server on port 8080:
  ```sh
  cd backend && stack run server
  ```
- Run frontend web app in dev mode, and [localhost:8000](http://localhost:8000) opens in browser automatically:
  ```sh
  cd frontend && npm start
  ```

## Domain model: Library

- A book can have exactly 1 author
- An author can have zero to many books
- Book title must be unique per author
- Author's name must be unique

### Other choices

- New entries that are in relation are submitted together and inserted transactionally.
- Search is case-insensitive

## Technical notes

- If you are using VSCode and you want to open both frontend and backend as a single workspace, use `File > Open Workspace` and choose `servant-to-elm-example.code-workspace`. In this scenario VSCode will work correct with for both languages simultaneously. Also the editor may recommend you extensions, and installing them is a wise choice.
- This app was not tested on Windows systems yet. While is not a showcase of a cross-platform compatibility, you can still open an issue or PR if something does not work as expected.

### Adding new types

- in `DomainModel.hs`:
  - Define the type
  - Derive necessary instances, also specify Elm module name and Elm type (it's better to keep type name the same, but it's convenient to use one module for several coupled types - see `Book`, `NewBook`, and `NewBookAuthor` types and corresponding generated Elm module)
  - Add the type to `typeDefinitions` list - `jsonDefinitions @YourNewType`
- Use your type in `Server.hs` or wherever it's intended to
- Run code-generation again

### Design choices and alternatives

- Old Elm files will not be deleted automatically when generating code, please be aware of that and delete them manually (automatic deletion may be implemented later).
- One of the alternatives to this approach is GraphQL, and there is a [Haskell/Elm full-stack GraphQL example app](https://github.com/higherkindness/mu-graphql-example-elm). This example app was shamelessly inspired by that example.

[stack]: https://docs.haskellstack.org/en/stable/README/#how-to-install
[elm]: https://guide.elm-lang.org/install/elm.html
[servant]: https://www.servant.dev/
[servant-to-elm]: https://github.com/folq/servant-to-elm
