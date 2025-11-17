#!/usr/bin/env bash
set -e

echo "Running SHACL validation..."

pyshacl -s ontologies/agent.ttl -sh tests/agent.shacl.ttl
pyshacl -s ontologies/accountability.ttl -sh tests/accountability.shacl.ttl
pyshacl -s ontologies/agent-profile.ttl -sh tests/agent-profile.shacl.ttl
pyshacl -s ontologies/capability.ttl -sh tests/capability.shacl.ttl
pyshacl -s ontologies/delegation.ttl -sh tests/delegation.shacl.ttl
pyshacl -s ontologies/execution-context.ttl -sh tests/execution-context.shacl.ttl
pyshacl -s ontologies/intent.ttl -sh tests/intent.shacl.ttl
pyshacl -s ontologies/ledger.ttl -sh tests/ledger.shacl.ttl
pyshacl -s ontologies/payment.ttl -sh tests/payment.shacl.ttl
pyshacl -s ontologies/security-binding.ttl -sh tests/security-binding.shacl.ttl

echo "SHACL validation successful."
