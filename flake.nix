{
  description = "Agent Ontology Flake with Ontospy Documentation";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-darwin" "x86_64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
    in
    {
      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            name = "agent-ontology-dev";
            packages = with pkgs; [
              python3
              python3Packages.pip
              apache-jena
              openjdk17
              git
            ];
            shellHook = ''
              echo "🐍 Installing Python dependencies (ontospy, rdflib, pyshacl)..."
              pip install --quiet --upgrade ontospy rdflib pyshacl
              export JAVA_HOME=${pkgs.openjdk17}
              export PATH=$JAVA_HOME/bin:$PATH
              echo "✅ Environment ready. Run: nix build .#gh-pages"
            '';
          };
        }
      );

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
              pkgs.python3Packages.ontospy
            ];

            buildPhase = ''
              export JAVA_HOME=${pkgs.openjdk17}
              export PATH=$JAVA_HOME/bin:$PATH
              mkdir -p gh-pages/docs

              echo "🌐 Generating ontology.ttl ..."
              riot --output=TURTLE ontologies/core.ttl > gh-pages/ontology.ttl

              echo "🧩 Generating HTML documentation with Ontospy ..."
              ontospy gendocs ontologies/core.ttl -o gh-pages/docs

              echo "📄 Creating index.html ..."
              cat > gh-pages/index.html <<EOF
              <!DOCTYPE html>
              <html lang="en">
              <head>
                <meta charset="UTF-8">
                <title>Agent Ontology</title>
                <style>
                  body { font-family: sans-serif; margin: 2em; }
                  a { color: #0366d6; text-decoration: none; }
                </style>
              </head>
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