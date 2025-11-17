#!/usr/bin/env bash
set -e

echo "Running SHACL validation..."

pyshacl -f turtle ontologies/agent.ttl -s tests/agent.shacl.ttl
pyshacl -f turtle ontologies/accountability.ttl -s tests/accountability.shacl.ttl
pyshacl -f turtle ontologies/agent-profile.ttl -s tests/agent-profile.shacl.ttl
pyshacl -f turtle ontologies/capability.ttl -s tests/capability.shacl.ttl
pyshacl -f turtle ontologies/delegation.ttl -s tests/delegation.shacl.ttl
pyshacl -f turtle ontologies/execution-context.ttl -s tests/execution-context.shacl.ttl
pyshacl -f turtle ontologies/intent.ttl -s tests/intent.shacl.ttl
pyshacl -f turtle ontologies/ledger.ttl -s tests/ledger.shacl.ttl
pyshacl -f turtle ontologies/payment.ttl -s tests/payment.shacl.ttl
pyshacl -f turtle ontologies/security-binding.ttl -s tests/security-binding.shacl.ttl

echo "SHACL validation successful."
