# Commit Standards

This project uses [Conventional Commits](https://www.conventionalcommits.org/) with [Semantic Versioning](https://semver.org/).

## Commit Message Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Type

Must be one of:
- `feat` - New feature (minor version bump)
- `fix` - Bug fix (patch version bump)
- `docs` - Documentation only
- `style` - Code style (formatting, missing semicolons, etc.)
- `refactor` - Code change that neither fixes a bug nor adds a feature
- `perf` - Performance improvement
- `test` - Adding or updating tests
- `chore` - Maintenance tasks (dependencies, tooling, releases)
- `build` - Build system or external dependencies
- `ci` - CI configuration files and scripts

### Scope

Optional. Examples:
- `feat(logging)` - New logging feature
- `fix(design-system)` - Design system bug fix
- `docs(readme)` - README update
- `chore(release)` - Release preparation

### Breaking Changes

Use `!` after type/scope to indicate breaking changes:

```
feat!: remove deprecated AppLogger.shared

BREAKING CHANGE: AppLogger.shared removed, use AppLogger.logger(for:) instead
```

## Version Alignment

**CRITICAL:** iOS app marketing version MUST match git tag version.

When creating a release:

1. **Update version in Xcode:**
   ```bash
   sed -i '' 's/MARKETING_VERSION = X.Y.Z;/MARKETING_VERSION = A.B.C;/g' MyApp.xcodeproj/project.pbxproj
   ```

2. **Commit version change:**
   ```bash
   git add MyApp.xcodeproj/project.pbxproj
   git commit -m "chore(release): set marketing version to A.B.C"
   ```

3. **Tag the release:**
   ```bash
   git tag -a vA.B.C -m "chore(release): vA.B.C - Release summary"
   ```

4. **Push with tags:**
   ```bash
   git push && git push --tags
   ```

## Semantic Versioning

Version format: `MAJOR.MINOR.PATCH`

### MAJOR (X.0.0)
Breaking changes, incompatible API changes

Examples:
- Removing public APIs
- Changing method signatures
- Restructuring project (incompatible)

### MINOR (0.X.0)
New features, backwards-compatible

Examples:
- `feat:` commits
- New components, utilities, extensions
- New documentation sections

### PATCH (0.0.X)
Bug fixes, backwards-compatible

Examples:
- `fix:` commits
- Documentation fixes
- Build script fixes

### Pre-1.0 Versions (0.X.Y)
Initial development, API not yet stable. Breaking changes may occur in minor versions.

## Examples

### Feature Addition
```
feat(design-system): add button styles to DesignConstants

Add primary, secondary, and destructive button styles with consistent
sizing and appearance tokens.
```

### Bug Fix
```
fix(scripts): correct simulator detection in build.sh

Use jq filter to properly parse available simulators, fixing issue
where script would fail with no devices found.
```

### Breaking Change
```
feat(logging)!: replace AppLogger.shared with factory method

BREAKING CHANGE: AppLogger.shared removed. Use AppLogger.logger(for: category)
instead for type-safe logging with categories.

Migration:
- Before: AppLogger.shared.log("message")
- After: AppLogger.logger(for: .general).log("message")
```

### Documentation
```
docs(customization): add CI/CD section to guide

Document GitHub Actions workflow setup for automated builds and tests.
```

### Release
```
chore(release): v0.2.0 - Add networking layer

New Features:
- APIClient with async/await
- Request/Response types
- Error handling

Bug Fixes:
- Fixed simulator detection in scripts
```

## Version History

- `v0.1.0` (2026-01-04) - Initial iOS template release
  - Feature-based architecture
  - Swift 6 strict concurrency
  - Design system & extensions
  - Build automation scripts
  - Comprehensive documentation

## Automation

### Version Bump Helper Script

TODO: Create `scripts/version-bump.sh` to automate version updates:

```bash
#!/bin/bash
# Usage: ./scripts/version-bump.sh [major|minor|patch]
# Automatically updates Xcode project and creates git tag
```

## Validation

Before committing:
1. ✅ Commit message follows conventional format
2. ✅ Type is valid (feat, fix, docs, etc.)
3. ✅ Description is concise (< 72 chars)
4. ✅ Breaking changes marked with `!` and footer
5. ✅ For releases: version synced between Xcode and git tag

## Tools

Consider installing:
- [Commitizen](https://github.com/commitizen/cz-cli) - Interactive commit prompts
- [commitlint](https://commitlint.js.org/) - Lint commit messages
- [standard-version](https://github.com/conventional-changelog/standard-version) - Automated versioning and CHANGELOG

## References

- [Conventional Commits](https://www.conventionalcommits.org/)
- [Semantic Versioning](https://semver.org/)
- [Keep a Changelog](https://keepachangelog.com/)
