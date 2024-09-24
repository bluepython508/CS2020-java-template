# Running and Testing
With Nix, `nix develop` makes the tools available, `nix build` builds a JAR under `result/`, and `nix flake check` runs tests.
Alternatively, `nix develop` makes `just` available, with `just run` and `just test`.
`nix develop` is also invoked by direnv.

Without Nix, `./gradlew build`, `./gradlew run`, and `./gradlew test` build, run, and test respectively.

# Initialization from template
`nix develop` or use direnv, to get `just`; `just init`, provide a project name and a package name.

# Development
If adding dependencies, run `just lock` to add dependencies to `gradle.lock` to re-enable `nix build`.
