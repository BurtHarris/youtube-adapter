# PSModuleTemplate

[![CI](https://github.com/BurtHarris/youtube-adapter/actions/workflows/ci.yml/badge.svg)](https://github.com/BurtHarris/youtube-adapter/actions/workflows/ci.yml)

A GitHub template repository for authoring high-quality PowerShell modules in VS Code.

## What you get

- **Module layout** — `src/<Module>/` with `Public/` and `Private/` function folders, a dev-mode `.psm1` loader, and a proper manifest
- **Build system** — [Invoke-Build](https://github.com/nightroman/Invoke-Build) script that assembles functions into a single distributable `.psm1` and syncs `FunctionsToExport`
- **Testing** — [Pester v5](https://pester.dev) suite covering the manifest, exports, and function behavior
- **Linting** — [PSScriptAnalyzer](https://github.com/PowerShell/PSScriptAnalyzer) with a checked-in settings file shared by VS Code and CI
- **CI/CD** — GitHub Actions: tests on Windows/Linux/macOS (PowerShell 7) plus Windows PowerShell 5.1; publish to the PowerShell Gallery on release
- **VS Code integration** — tasks (build/test/analyze/docs), debug configs, formatting settings, recommended extensions
- **Docs** — optional [platyPS](https://github.com/PowerShell/platyPS) markdown help generation (`./build.ps1 -Task Docs`)
- **Community files** — issue templates, PR template, Dependabot for actions

## Quick start

1. Click **Use this template** on GitHub and create your repository
2. Clone it, then initialize:

   ```powershell
   ./Initialize-Template.ps1 -ModuleName 'MyModule' -Author 'Your Name' -Description 'What it does.' -GitHubOwner 'yourusername'
   ```

   This renames everything, regenerates the module GUID, and deletes itself.

3. Verify the build:

   ```powershell
   ./build.ps1        # Analyze + Test (installs build dependencies on first run)
   ```

4. Start writing functions in `src/MyModule/Public/` — one file per function, matching the function name.

## Build tasks

| Command | Purpose |
| --- | --- |
| `./build.ps1` | Default: Analyze + Test |
| `./build.ps1 -Task Build` | Assemble the module into `output/` |
| `./build.ps1 -Task Test` | Build, then run Pester tests |
| `./build.ps1 -Task Analyze` | Run PSScriptAnalyzer |
| `./build.ps1 -Task Docs` | Generate markdown help (requires platyPS) |

The same tasks are available in VS Code via **Terminal → Run Task**.

## Terminal test environment

To set up a plain PowerShell terminal for local module testing, dot-source the repo bootstrap script:

```powershell
. ./Enter-DevShell.ps1
```

This script:

- Installs build/test dependencies (`InvokeBuild`, `Pester`, `PSScriptAnalyzer`) if needed
- Builds the module when no built output is available
- Imports the latest built module for the current terminal session
- Sets `YOUTUBE_ADAPTER_TEST_MODULE_PATH` so test runs use the intended module path
- Exposes convenience commands:
   - `Invoke-ProjectBuild`
   - `Invoke-ProjectAnalyze`
   - `Invoke-ProjectTests`
   - `Import-ProjectModule`

`Invoke-ProjectTests` runs tests against an isolated build path, so avoid importing the module before running tests in the same session.

Quick start after bootstrapping:

```powershell
Invoke-ProjectTests
```

To load the configured module path into your terminal session after testing:

```powershell
Import-ProjectModule
```

## Publishing

Create a GitHub release and the `publish` workflow pushes the built module to the [PowerShell Gallery](https://www.powershellgallery.com/). Requires a `PSGALLERY_API_KEY` repository secret.

## Conventions

- One public function per file in `Public/`, filename = function name
- Internal helpers live in `Private/` and are never exported
- Comment-based help on every public function
- `master` is protected by CI; all changes come through PRs

## Acknowledgments

This template was scaffolded with [Claude Code](https://claude.ai/code), powered by the Claude Fable 5 model (`claude-fable-5`).

## License

[MIT](LICENSE)
