# Agent Ontology Overview

This project is the **core ontology** of the [Semantic Agent Communication W3C Community Group (SAC-CG)](https://www.w3.org/community/s-agent-comm/).  
It contains all formal definitions of the semantic model for executable AI Agents and is structured to separate the ontology modules, their corresponding JSON-LD contexts, and validation profiles.

## Conceptual Overview: Executable Agent Semantics

Unlike traditional ontologies that merely describe data or domain concepts, the **Agent Ontology** defines the *executable semantics* of AI Agents — entities capable of autonomous reasoning, delegation, and verifiable interaction across systems.  
It provides the formal vocabulary and logical bindings necessary for agents to operate within **trustworthy, identity-bound, and auditable environments**.

This ontology is designed as the semantic foundation for:

- **Identity-Bound Agents** — Each agent instance is linked to a verifiable identifier (DID/VC), allowing persistent identity and cryptographic accountability.  
- **Delegation & Contractual Semantics** — Models how agents delegate authority, form verifiable contracts, and record obligations or outcomes on ledgers.  
- **Verifiable Grammar** — Establishes the syntax-ontology interface enabling agents to reason, communicate, and execute tasks under machine-verifiable grammar constraints.  
- **Interoperable Multi-Agent Frameworks** — Provides a shared vocabulary layer for interoperability among different agent systems (human, AI, or hybrid).

In practice, this ontology functions as both:
1. a **formal specification** (OWL/RDF), and  
2. a **runtime reference model** instantiated by agent frameworks or operating systems implementing verifiable semantics.

```mermaid
graph TD
    subgraph Abstract_Cognitive[Abstract / Cognitive Layer]
        I[Intent (Mental State)]
        P[Proposition / Description]
        K[Knowledge / Meaning]
    end

    subgraph Social_Agentive[Social / Agentive Layer]
        A[Agent (ArtifactSocial)]
        R[Role / Delegation]
        C[Contract / Ledger]
        D[Capability (Disposition)]
        AC[Accountability]
    end

    subgraph Physical_Ontic[Physical / Ontic Layer]
        PR[Process / Event]
        ST[State / Situation]
        FD[FunctionDisposition]
        OB[Object / Artifact]
        LQ[Location / Quantity]
    end

    subgraph Computational_Ontic[Computational Ontic Layer]
        EC[ExecutionContext]
        PB[ProofBinding (Security)]
        AR[AgentRuntime / Instance]
        SS[Semantic Syscall / Action]
        LT[LedgerTrace / Log]
    end

    I -->|depends_on| A
    P -->|context_of| A
    K -->|emerges_from| A

    A -->|realizes| PR
    D -->|realizes| FD
    R -->|involves| A
    C -->|binds| A
    AC -->|requires| PB

    PR -->|occurs_in| EC
    FD -->|compiled_as| SS
    OB -->|recorded_by| LT
    ST -->|verified_by| PB

    A -->|executes| EC
    EC -->|writes| LT
    EC -->|produces| PB
```

## Why This Ontology Matters

This project serves as the semantic core of the **W3C Semantic Agent Communication Community Group (SAC-CG)**.  
Its goal is to standardize how AI agents represent **identity, intent, delegation, and accountability**, ensuring that multi-agent ecosystems remain transparent, auditable, and interoperable across jurisdictions and institutions.

The ontology aligns with emerging frameworks such as the **EU AI Act**, **EUDI Wallet**, and **ISO/IEC 42001**, providing a common basis for regulatory-compliant agent behavior and trustworthy automation.  
By establishing a verifiable semantic layer for agent interoperability, this project contributes to the next generation of **AI governance, semantic infrastructure, and computational law.**

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
