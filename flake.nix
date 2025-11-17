{
  description = "Agent Ontology Flake with Ontospy Documentation (safe pip install)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-darwin" "x86_64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
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
              pkgs.python3
              pkgs.python3Packages.virtualenv
            ];

            buildPhase = ''
              export JAVA_HOME=${pkgs.openjdk17}
              export PATH=$JAVA_HOME/bin:$PATH
              mkdir -p gh-pages/docs

              echo "🌐 Generating ontology.ttl ..."
              riot --output=TURTLE ontologies/core.ttl > gh-pages/ontology.ttl

              echo "🐍 Creating virtualenv and installing Ontospy ..."
              python -m venv .venv
              source .venv/bin/activate
              pip install --quiet ontospy

              echo "🧩 Generating HTML documentation ..."
              .venv/bin/ontospy gendocs ontologies/core.ttl -o gh-pages/docs

              echo "📄 Creating index.html ..."
              cat > gh-pages/index.html <<EOF
              <!DOCTYPE html>
              <html lang="en">
              <head><meta charset="UTF-8"><title>Agent Ontology</title></head>
              <body>
                <h1>Agent Ontology</h1>
                <ul>
                  <li><a href="./ontology.ttl">ontology.ttl</a></li>
                  <li><a href="./docs/index.html">HTML Documentation (Ontospy)</a></li>
                </ul>
              </body>
              </html>
              EOF
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