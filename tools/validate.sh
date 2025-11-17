#!/usr/bin/env bash
set -e

echo "Running SHACL validation..."

pyshacl -f ontologies/agent.ttl -s tests/agent.shacl.ttl
pyshacl -f ontologies/accountability.ttl -s tests/accountability.shacl.ttl
pyshacl -f ontologies/agent-profile.ttl -s tests/agent-profile.shacl.ttl
pyshacl -f ontologies/capability.ttl -s tests/capability.shacl.ttl
pyshacl -f ontologies/delegation.ttl -s tests/delegation.shacl.ttl
pyshacl -f ontologies/execution-context.ttl -s tests/execution-context.shacl.ttl
pyshacl -f ontologies/intent.ttl -s tests/intent.shacl.ttl
pyshacl -f ontologies/ledger.ttl -s tests/ledger.shacl.ttl
pyshacl -f ontologies/payment.ttl -s tests/payment.shacl.ttl
pyshacl -f ontologies/security-binding.ttl -s tests/security-binding.shacl.ttl

echo "SHACL validation successful."
