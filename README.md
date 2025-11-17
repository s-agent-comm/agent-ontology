# Agent Ontology Overview

This directory is the core of the Agent CG Ontology project, containing all formal definitions of the semantic model for AI Agents. It is structured to provide a clear separation between the core ontology modules, their corresponding JSON-LD contexts, and validation profiles.

## Directory Structure

*   **`ontologies/`**: Contains the primary ontology modules, defined using the [Turtle (Terse RDF Triple Language)](https://www.w3.org/TR/turtle/) syntax. Each `.ttl` file defines a specific aspect of the agent ontology (e.g., `core.ttl`, `agent.ttl`, `economic.ttl`). The main entry point for the complete ontology is `ontology.ttl`, which imports all other modules.

*   **`context/`**: This subdirectory contains [JSON-LD Context](https://www.w3.org/TR/json-ld11/#the-context) files that correspond to the ontology modules. These files are crucial for mapping JSON data structures to the semantic terms defined in the `.ttl` ontologies, allowing JSON documents to be interpreted as Linked Data.

*   **`profiles/`**: This subdirectory contains [JSON Schema](https://json-schema.org/) validation profiles. These schemas define the expected structure and data types for JSON documents that conform to specific parts of the ontology and are used for data validation.

*   **`tests/`**: This subdirectory contains [SHACL (Shapes Constraint Language)](https://www.w3.org/TR/shacl/) files for validating the ontology data models, ensuring that RDF data conforms to the expected graph patterns.

## How to Use

*   **For Semantic Web Tools:** Load the `ontologies/ontology.ttl` file into any RDF/OWL compatible tool to explore the full semantic model.
*   **For JSON-LD Processing:** Use the context files in `context/` to expand or compact JSON-LD documents. The main `context/agent.jsonld` context imports the other modular contexts, providing a single entry point for most use cases.
*   **For Data Validation:** Use the JSON Schema files in `profiles/` with a JSON Schema validator to ensure your JSON data conforms to the expected structure. For RDF data validation, use the SHACL files in `tests/` with a SHACL validator.

## Development

This project uses [Nix Flakes](https://nixos.wiki/wiki/Flakes) to provide a reproducible development environment.

### Entering the Environment

To activate the development environment, run the following command at the root of the project:

```bash
nix develop
```

This will provide you with a shell that has all the necessary tools, including `pyshacl`, `rdflib`, and `riot` (from Apache Jena).

### Validation

To run all SHACL validations locally, execute the validation script:

```bash
./tools/validate.sh
```

### Generating JSON-LD

To automatically generate JSON-LD files from the Turtle (`.ttl`) files in the `ontologies/` directory, run the generation script:

```bash
python3 tools/generate_jsonld.py
```

This will create a corresponding `.jsonld` file for each `.ttl` file in the project's root directory.
