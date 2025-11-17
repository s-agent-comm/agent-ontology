import glob
from pathlib import Path
from rdflib import Graph

def convert_ttl_to_jsonld():
    """
    Converts all Turtle files in the 'ontologies/' directory to JSON-LD format
    and saves them in the project's root directory.
    """
    ontologies_dir = Path("ontologies")
    output_dir = Path(".")

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
            
            # Serialize to JSON-LD
            g.serialize(destination=output_path, format="json-ld", indent=4)
            print(f"Successfully converted {ttl_file} to {output_path}")

        except Exception as e:
            print(f"Error processing {ttl_file}: {e}")

if __name__ == "__main__":
    convert_ttl_to_jsonld()
