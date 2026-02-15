#!/usr/bin/env bash
set -euo pipefail

echo "Running SHACL validation..."

ontologies_list=$(ls ontologies/*.ttl | sed 's#.*/##;s/\.ttl$//' | sort)
shacl_list=$(ls tests/*.shacl.ttl | sed 's#.*/##;s/\.shacl\.ttl$//' | sort)

missing_shacl=$(comm -23 <(printf "%s\n" "${ontologies_list}") <(printf "%s\n" "${shacl_list}"))
if [ -n "${missing_shacl}" ]; then
  echo "Missing SHACL files for:"
  echo "${missing_shacl}"
  exit 1
fi

missing_ontology=$(comm -13 <(printf "%s\n" "${ontologies_list}") <(printf "%s\n" "${shacl_list}"))
if [ -n "${missing_ontology}" ]; then
  echo "SHACL files without matching ontology:"
  echo "${missing_ontology}"
  exit 1
fi

while read -r name; do
  [ -z "${name}" ] && continue
  ontology="ontologies/${name}.ttl"
  shacl="tests/${name}.shacl.ttl"
  echo "Validating ${ontology} against ${shacl}..."
  pyshacl -f turtle "${ontology}" -s "${shacl}"
done <<< "${shacl_list}"

echo "SHACL validation successful."
