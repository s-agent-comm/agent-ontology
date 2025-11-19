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
              pkgs.git
              pkgs.coreutils
            ];

            buildPhase = ''
              set -e
              export JAVA_HOME=${pkgs.openjdk17}
              export PATH=$JAVA_HOME/bin:$PATH

              echo "🌐 Generating ontology.ttl ..."
              mkdir -p gh-pages/docs
              cp -r ontologies gh-pages/
              riot --output=TURTLE ontologies/ontology.ttl > gh-pages/ontology.ttl

              echo "🐍 Creating virtualenv and installing Ontospy ..."
              python -m venv .venv
              source .venv/bin/activate
              pip install --quiet ontospy

              echo "🧩 Generating HTML documentation ..."
              .venv/bin/ontospy gendocs ontologies/ontology.ttl -o gh-pages/docs --type 2 --nobrowser

              echo "📄 Creating index.html ..."
              cat > gh-pages/index.html <<EOF
              <!DOCTYPE html>
              <html lang="en">
              <head><meta charset="UTF-8"><title>Agent Ontology</title></head>
              <body style="font-family:sans-serif;margin:2em;">
                <h1>Agent Ontology</h1>
                <ul>
                  <li><a href="./ontology.ttl">ontology.ttl (Combined)</a></li>
                  <li><a href="./docs/index.html">HTML Documentation (Ontospy)</a></li>
                  <li><a href="./version.json">version.json</a></li>
                </ul>
                <h2>Individual Ontology Modules</h2>
                <ul>
EOF
              for f in ontologies/*.ttl; do
                filename=$(basename "$f")
                echo "                  <li><a href=\"./ontologies/$filename\">$filename</a></li>" >> gh-pages/index.html
              done
              cat >> gh-pages/index.html <<EOF
                </ul>
              </body>
              </html>
              EOF

              echo "🧾 Writing build metadata ..."
              COMMIT_HASH=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
              BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
              cat > gh-pages/version.json <<JSON
              {
                "name": "agent-ontology",
                "commit": "''${COMMIT_HASH}",
                "build_date": "''${BUILD_DATE}",
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