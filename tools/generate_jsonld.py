import glob
from pathlib import Path
import os
from rdflib import Graph

def convert_ttl_to_jsonld():
    """
    Converts all Turtle files in the 'ontologies/' directory to JSON-LD format
    and saves them in the 'dist/' directory.
    """
    ontologies_dir = Path("ontologies")
    output_dir = Path("dist")

    # Ensure the output directory exists
    os.makedirs(output_dir, exist_ok=True)

    ttl_files = list(ontologies_dir.glob("*.ttl"))

    if not ttl_files:
        print("No .ttl files found in the 'ontologies/' directory.")
        return

    print(f"Found {len(ttl_files)} .ttl files to convert...")

    for ttl_file in ttl_files:
        g = Graph()
        try:
            g.parse(ttl_file, format="turtle")
            
            # Determine output filename
            jsonld_filename = ttl_file.with_suffix(".jsonld").name
            output_path = output_dir / jsonld_filename
            
            # Define a custom context for JSON-LD to use prefixes
            context = {
                "rdfs": "http://www.w3.org/2000/01/rdf-schema#",
                "owl": "http://www.w3.org/2002/07/owl#",
                "dcterms": "http://purl.org/dc/terms/",
                "xsd": "http://www.w3.org/2001/XMLSchema#",
                "agent": "https://w3id.org/agent-ontology/agent#",
                "core": "https://w3id.org/agent-ontology/core#",
                "identity": "https://w3id.org/agent-ontology/identity#",
                "economic": "https://w3id.org/agent-ontology/economic#",
                "lifecycle": "https://w3id.org/agent-ontology/lifecycle#",
                "contract": "https://w3id.org/agent-ontology/contract#",
                "agent-profile": "https://w3id.org/agent-ontology/agent-profile#",
                "capability": "https://w3id.org/agent-ontology/capability#",
                "delegation": "https://w3id.org/agent-ontology/delegation#",
                "execution-context": "https://w3id.org/agent-ontology/execution-context#",
                "intent": "https://w3id.org/agent-ontology/intent#",
                "ledger": "https://w3id.org/agent-ontology/ledger#",
                "payment": "https://w3id.org/agent-ontology/payment#",
                "security-binding": "https://w3id.org/agent-ontology/security-binding#",
                "threat-model": "https://w3id.org/agent-ontology/threat-model#",
                "accountability": "https://w3id.org/agent-ontology/accountability#",
                "ontology": "https://w3id.org/agent-ontology/ontology#"
            }
            # Serialize to JSON-LD with the custom context
            g.serialize(destination=output_path, format="json-ld", indent=4, context=context)
            print(f"Successfully converted {ttl_file} to {output_path}")

        except Exception as e:
            print(f"Error processing {ttl_file}: {e}")

if __name__ == "__main__":
    convert_ttl_to_jsonld()
