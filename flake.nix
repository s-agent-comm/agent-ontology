{
  description = "Agent Ontology Flake with Ontospy Docs and Build Metadata";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-darwin" "x86_64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          gh-pages = pkgs.stdenv.mkDerivation {
            name = "agent-ontology-gh-pages";
            src = self;

            buildInputs = [
              pkgs.apache-jena
              pkgs.openjdk17
              pkgs.python311
              pkgs.python311Packages.virtualenv
              pkgs.python311Packages.rdflib
              pkgs.git
              pkgs.coreutils
            ];

            buildPhase = ''
              set -e
              export JAVA_HOME=${pkgs.openjdk17}
              export PATH=$JAVA_HOME/bin:$PATH

              echo "🔎 Extracting ontology version..."
              VERSION=$(grep "owl:versionInfo" ontologies/ontology.ttl | sed -n 's/.*"\(.*\)".*/\1/p')
              if [ -z "$VERSION" ]; then
                echo "Error: Could not extract version from ontology.ttl"
                exit 1
              fi
              echo "✅ Ontology version: $VERSION"

              echo "🚀 Setting up versioned directories..."
              mkdir -p gh-pages/$VERSION
              mkdir -p gh-pages/latest

              echo "🌐 Generating combined ontology.ttl..."
              riot --output=TURTLE ontologies/*.ttl > gh-pages/$VERSION/ontology.ttl

              echo "🐍 Creating virtualenv and installing dependencies..."
              python -m venv .venv
              source .venv/bin/activate
              pip install --quiet ontospy rdflib

              echo "🧩 Generating HTML documentation into a temp directory..."
              .venv/bin/ontospy gendocs gh-pages/$VERSION/ontology.ttl -o gh-pages/docs-temp --type 2 --nobrowser

              echo "📦 Generating individual JSON-LD files..."
              python tools/generate_jsonld.py
              
              echo "📥 Copying files to versioned directory..."
              cp -r ontologies/* gh-pages/$VERSION/
              cp -r dist/* gh-pages/$VERSION/
              cp -r context gh-pages/$VERSION/
              cp -r gh-pages/docs-temp/* gh-pages/$VERSION/docs/

              echo "📦 Generating combined ontology.jsonld..."
              python -c "from rdflib import Graph; g = Graph(); g.parse('gh-pages/$VERSION/ontology.ttl', format='turtle'); g.serialize(destination='gh-pages/$VERSION/ontology.jsonld', format='json-ld', indent=4)"

              echo "📄 Creating versioned specification index.html..."
              cat > gh-pages/$VERSION/index.html <<EOF
              <!DOCTYPE html>
              <html lang="en">
              <head>
                  <meta charset="UTF-8">
                  <meta name="viewport" content="width=device-width, initial-scale=1.0">
                  <title>Agent Ontology v$VERSION - Specification</title>
                  <style>
                      body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; line-height: 1.6; margin: 2em; background-color: #f4f4f4; color: #333; }
                      .container { max-width: 900px; margin: auto; background: #fff; padding: 2em; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
                      h1, h2, h3 { color: #0056b3; }
                      a { color: #007bff; text-decoration: none; }
                      a:hover { text-decoration: underline; }
                      ul { list-style-type: none; padding: 0; }
                      li { margin-bottom: 0.5em; }
                      .section-title { border-bottom: 1px solid #eee; padding-bottom: 0.5em; margin-top: 2em; }
                      .file-list { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 1em; }
                      .file-list li { background-color: #e9f7ff; padding: 0.8em; border-radius: 4px; border: 1px solid #cceeff; }
                  </style>
              </head>
              <body>
                  <div class="container">
                      <h1>Agent Ontology - Version $VERSION</h1>
                      <p>This page serves as a human-readable entry point and simple specification for the Agent Ontology. The Agent Ontology provides a foundational framework for defining and understanding agents, their capabilities, interactions, and lifecycle within various contexts.</p>

                      <h2 class="section-title">Core Ontology Files</h2>
                      <ul>
                          <li><a href="./ontology.ttl"><strong>ontology.ttl</strong></a> (Combined Turtle format) - The complete Agent Ontology in Turtle format.</li>
                          <li><a href="./ontology.jsonld"><strong>ontology.jsonld</strong></a> (Combined JSON-LD format) - The complete Agent Ontology in JSON-LD format.</li>
                          <li><a href="./docs/index.html">HTML Documentation</a> (Generated by Ontospy) - Detailed, browsable documentation of the ontology classes, properties, and relationships.</li>
                      </ul>

                      <h2 class="section-title">Individual Ontology Modules (Turtle)</h2>
                      <ul class="file-list">
EOF
              for f in ontologies/*.ttl; do
                filename=$(basename "$f")
                echo "                        <li><a href=\"./$filename\">$filename</a></li>" >> gh-pages/$VERSION/index.html
              done
              cat >> gh-pages/$VERSION/index.html <<EOF
                      </ul>

                      <h2 class="section-title">Individual Ontology Modules (JSON-LD)</h2>
                      <ul class="file-list">
EOF
              for f in dist/*.jsonld; do
                filename=$(basename "$f")
                echo "                        <li><a href=\"./$filename\">$filename</a></li>" >> gh-pages/$VERSION/index.html
              done
              cat >> gh-pages/$VERSION/index.html <<EOF
                      </ul>
                      
                      <h2 class="section-title">Context Files (JSON-LD)</h2>
                      <ul class="file-list">
EOF
              for f in context/*.jsonld; do
                filename=$(basename "$f")
                echo "                        <li><a href=\"./context/$filename\">$filename</a></li>" >> gh-pages/$VERSION/index.html
              done
              cat >> gh-pages/$VERSION/index.html <<EOF
                      </ul>

                      <h2 class="section-title">How to Use</h2>
                      <p>Agents and frameworks can consume these ontology files directly. For content negotiation and persistent identifiers, please refer to the <a href="https://w3id.org/agent-ontology/">official w3id.org entry point</a> (once configured).</p>
                      <p>For developers, the source code and further details can be found on the <a href="https://github.com/s-agent-comm/agent-ontology">GitHub repository</a>.</p>
                  </div>
              </body>
              </html>
EOF

              echo "🚀 Creating 'latest' release by copying version $VERSION..."
              cp -r gh-pages/$VERSION/* gh-pages/latest/

              echo "📄 Creating root index.html portal..."
              cat > gh-pages/index.html <<EOF
              <!DOCTYPE html>
              <html lang="en">
              <head>
                  <meta charset="UTF-8">
                  <meta http-equiv="refresh" content="0; url=./latest/index.html">
                  <title>Agent Ontology Versions</title>
                  <style>
                      body { font-family: sans-serif; margin: 2em; }
                  </style>
              </head>
              <body>
                  <h1>Agent Ontology Versions</h1>
                  <p>The latest version is <strong>$VERSION</strong>.</p>
                  <p>You should be automatically redirected to the latest version. If not, <a href="./latest/index.html">click here</a>.</p>
                  <h2>Available Versions</h2>
                  <ul>
                      <li><a href="./latest/index.html">Latest ($VERSION)</a></li>
                      <!-- Older versions can be listed here in the future -->
                  </ul>
              </body>
              </html>
EOF

              echo "🧾 Writing build metadata..."
              COMMIT_HASH=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
              BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
              cat > gh-pages/version.json <<JSON
              {
                "name": "agent-ontology",
                "commit": "''${COMMIT_HASH}",
                "build_date": "''${BUILD_DATE}",
                "ontology_version": "''${VERSION}",
                "nix_system": "${system}",
                "nixpkgs": "github:NixOS/nixpkgs/nixos-unstable"
              }
              JSON
            '';

            installPhase = ''
              mkdir -p $out
              cp -r gh-pages/* $out/
            '';
          };
        }
      );
    };
}