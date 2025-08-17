# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2025-01-16

### Added
- Initial release of AutoFormFaker gem
- Support for `auto_faker: true` option on form fields
- Context-aware field detection for intelligent fake data generation
- Custom faker class support with `auto_faker_class` option
- Association ID handling (specific IDs, random selection, lambdas)
- Environment safety (only works in development/staging by default)
- Configurable field mappings
- Support for all major Rails form helpers (text_field, email_field, phone_field, etc.)
- Support for select and collection_select fields
- Comprehensive test suite
- Full documentation and examples