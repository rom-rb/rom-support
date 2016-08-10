## v2.0.1 2016-08-11

### Changed

* `AutoCurry` skips protected methods too (solnic)

[Compare v2.0.0...v2.0.1](https://github.com/rom-rb/rom-support/compare/v2.0.0...v2.0.1)

## v2.0.0 2016-07-27

### Added

* `AutoCurry.auto_curried_methods` returning a list of methods that were auto-curried (solnic)
* `ROM::Cache` extension providing `#fetch_or_store` and `.fetch_or_store` (solnic)
* `ROM::Deprecations.set_logger!` which allows setting a custom logger (solnic)

### Changed

* Refactored `AutoCurry` to use module prepend (solnic)
* `AutoCurry` skips private methods and methods with 0 arity (solnic)

[Compare v1.0.0...v2.0.0](https://github.com/rom-rb/rom-support/compare/v1.0.0...v2.0.0)

## v1.0.0 2016-01-06

### Added

* Support for `:coercer` option key (nepalez)
* `AutoCurry#auto_curry_guard` interface (solnic)

### Fixed

* Default value for `:parent` option in `ClassBuilder` is set correctly (michaelherold)

[Compare v0.1.0...v1.0.0](https://github.com/rom-rb/rom-support/compare/v0.1.0...v1.0.0)

## v0.1.0 2015-08-10

First public release. The code was ported from rom 0.8.1
