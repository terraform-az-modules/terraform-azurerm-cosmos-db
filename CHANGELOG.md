# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v2.0.0] - 2026-04-13
### :bug: Bug Fixes
- [`caefead`](https://github.com/terraform-az-modules/terraform-azurerm-cosmos-db/commit/caefead93e403ece506301dbfc0821b2c62806a7) - Added major changes for cosmosdb module and apis for it *(commit by [@maharshi-cd](https://github.com/maharshi-cd))*
- [`0e02d42`](https://github.com/terraform-az-modules/terraform-azurerm-cosmos-db/commit/0e02d428da9f7074b7c95fcee3a349cf2a31d7e1) - Pull from master *(commit by [@maharshi-cd](https://github.com/maharshi-cd))*
- [`ec5c2e6`](https://github.com/terraform-az-modules/terraform-azurerm-cosmos-db/commit/ec5c2e63488551b1462b0dd9c1a507b39f24e30f) - Added Gemini suggested changes *(commit by [@maharshi-cd](https://github.com/maharshi-cd))*
- [`1849326`](https://github.com/terraform-az-modules/terraform-azurerm-cosmos-db/commit/184932663fe59978b4b6c30ac1131a09d046ef95) - Added changes for cmk *(commit by [@maharshi-cd](https://github.com/maharshi-cd))*
- [`ccfd2a2`](https://github.com/terraform-az-modules/terraform-azurerm-cosmos-db/commit/ccfd2a208dab5e365337d041564e5a64cb371015) - Added changes to tackle checkov issues and gemini comments *(commit by [@maharshi-cd](https://github.com/maharshi-cd))*
- [`e8d1c57`](https://github.com/terraform-az-modules/terraform-azurerm-cosmos-db/commit/e8d1c57c0173c262a5031e9e2a30f445facafba2) - remove spaces in checkov skip_check list to fix CI parse error *(commit by [@anmolnagpal](https://github.com/anmolnagpal))*
- [`d2abd83`](https://github.com/terraform-az-modules/terraform-azurerm-cosmos-db/commit/d2abd8313c80ce202134c39c7a675c16819313cc) - consolidate versions.tf, remove provider_meta, upgrade to azurerm >= 4.0 *(commit by [@anmolnagpal](https://github.com/anmolnagpal))*
- [`7b25abc`](https://github.com/terraform-az-modules/terraform-azurerm-cosmos-db/commit/7b25abca36bc40fe80aa9c93d89ec838d6329c6d) - replace version placeholder in example versions.tf with >= 4.0 *(commit by [@anmolnagpal](https://github.com/anmolnagpal))*
- [`fcc5ea1`](https://github.com/terraform-az-modules/terraform-azurerm-cosmos-db/commit/fcc5ea188b6aac559c5a773f2d934789f6779e0c) - fixed the conflicts *(commit by [@dverma-cd](https://github.com/dverma-cd))*
- [`b1cedc8`](https://github.com/terraform-az-modules/terraform-azurerm-cosmos-db/commit/b1cedc809b8cd0792e8e873aa76025815aff5a21) - fixed the conflicts *(commit by [@dverma-cd](https://github.com/dverma-cd))*

### :wrench: Chores
- [`167e89a`](https://github.com/terraform-az-modules/terraform-azurerm-cosmos-db/commit/167e89a5523f7c636af98c3685ca0cc470081ba4) - **deps**: bump terraform-linters/setup-tflint from 4 to 6 *(commit by [@dependabot[bot]](https://github.com/apps/dependabot))*
- [`b23b87d`](https://github.com/terraform-az-modules/terraform-azurerm-cosmos-db/commit/b23b87da54f14c1de8739813eeeb4a987fd85acf) - **deps**: bump hashicorp/setup-terraform from 3 to 4 *(commit by [@dependabot[bot]](https://github.com/apps/dependabot))*
- [`376b3a8`](https://github.com/terraform-az-modules/terraform-azurerm-cosmos-db/commit/376b3a8f1504a68a011026ed19f50be1ae679ba5) - **deps**: bump actions/checkout from 4 to 6 *(commit by [@dependabot[bot]](https://github.com/apps/dependabot))*
- [`3a6c238`](https://github.com/terraform-az-modules/terraform-azurerm-cosmos-db/commit/3a6c23887c0b2d2b3847a58248db02e093f0f813) - add provider_meta for API usage tracking *(PR [#10](https://github.com/terraform-az-modules/terraform-azurerm-cosmos-db/pull/10) by [@clouddrove-ci](https://github.com/clouddrove-ci))*
- [`d33518f`](https://github.com/terraform-az-modules/terraform-azurerm-cosmos-db/commit/d33518f510d3490d1a0693af258e23141d4a26c7) - polish module with basic example, changelog, and version fixes *(PR [#11](https://github.com/terraform-az-modules/terraform-azurerm-cosmos-db/pull/11) by [@clouddrove-ci](https://github.com/clouddrove-ci))*


## [1.0.0] - 2026-03-20

### Changes
- Add provider_meta for API usage tracking
- Add terraform tests and pre-commit CI workflow
- Add SECURITY.md, CONTRIBUTING.md, .releaserc.json
- Standardize pre-commit to antonbabenko v1.105.0
- Set provider: none in tf-checks for validate-only CI
- Bump required_version to >= 1.10.0
[v2.0.0]: https://github.com/terraform-az-modules/terraform-azurerm-cosmos-db/compare/v1.0.0...v2.0.0
