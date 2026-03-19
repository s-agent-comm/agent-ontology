# Notice

## Provenance Disclaimer

This repository previously included alignment mappings and architectural references derived from external ontology categorization concepts shared as informal discussion context.

These concepts:
- Are **not** part of any open or published standard
- Are **not** licensed for redistribution or reuse
- Were **not** contributed under the repository's CC BY 4.0 license

All such content has been identified and removed as of the commit accompanying this notice.

The remaining ontology definitions (agents, capabilities, intents, delegation, contracts, ledgers, execution contexts, security bindings, etc.) are independently authored by the project contributors and licensed under CC BY 4.0.

## Scope of Removal

The following were removed:
- `ontologies/ontic-alignment.ttl` — external alignment mappings
- `context/ontic-alignment.jsonld` — associated JSON-LD context
- `profiles/ontic-alignment.jsonld` — associated JSON Schema profile
- `tests/ontic-alignment.shacl.ttl` — associated SHACL validation shapes
- README references to external categorization frameworks

## Standard Alignments Retained

Mappings to **open, published standards** remain in the repository:
- `ontologies/schema-org-mapping.ttl` — mappings to [Schema.org](https://schema.org/) (CC0 licensed vocabulary)
- References to W3C standards (RDF, OWL, SHACL, DID) — open W3C specifications

These are independently authored mappings to publicly available specifications and do not incorporate third-party IP.
