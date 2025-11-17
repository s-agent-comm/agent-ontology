{
  description = "A flake for developing and publishing the Agent Ontology";

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
          pythonEnv = pkgs.python3;
        in
        {
          default = pkgs.mkShell {
            packages = [
              pythonEnv
              pkgs.apache-jena
              pkgs.openjdk17       # ← 加這個
              pkgs.git
              pkgs.makeWrapper
            ];

            shellHook = ''
              export JAVA_HOME=${pkgs.openjdk17}
              export PATH=$JAVA_HOME/bin:$PATH
              export PYTHONPATH="$(pwd):$PYTHONPATH"

              echo "🔧 Setting up local Python venv..."
              if [ ! -d .venv ]; then
                ${pythonEnv.interpreter} -m venv .venv
              fi
              source .venv/bin/activate

              echo "📦 Installing Python packages..."
              pip install --upgrade pip
              pip install pyshacl rdflib

              echo "✅ Environment ready."
              echo "Use: riot --validate ontologies/core.ttl"
            '';
          };
        }
      );

      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        rec {
          default = pkgs.stdenv.mkDerivation {
            name = "agent-ontology";
            src = self;

            buildInputs = [ pkgs.apache-jena pkgs.openjdk17 ];  # ← 加這個

            buildPhase = ''
              mkdir -p $out
              export JAVA_HOME=${pkgs.openjdk17}
              export PATH=$JAVA_HOME/bin:$PATH
              riot --output=TURTLE ontologies/core.ttl > $out/agent-ontology.ttl
            '';

            installPhase = ''
              echo "✅ Ontology built at $out/agent-ontology.ttl"
            '';
          };

          gh-pages = pkgs.stdenv.mkDerivation {
            name = "agent-ontology-gh-pages";
            src = self;
            buildInputs = [ pkgs.apache-jena pkgs.openjdk17 pkgs.coreutils pkgs.findutils ];  # ← 同樣加

            buildPhase = ''
              export JAVA_HOME=${pkgs.openjdk17}
              export PATH=$JAVA_HOME/bin:$PATH
              mkdir -p gh-pages

              echo "📂 Copying ontology and contexts..."
              cp -r ontologies gh-pages/
              cp -r context gh-pages/
              cp -r profiles gh-pages/
              cp -r tests gh-pages/shacl || true

              echo "🌐 Generating ontology.ttl entry..."
              riot --output=TURTLE ontologies/core.ttl > gh-pages/ontology.ttl

              echo "🧭 Creating index.html..."
              cat > gh-pages/index.html <<EOF
              <!DOCTYPE html>
              <html lang="en">
              <head><meta charset="UTF-8"><title>Agent Ontology</title></head>
              <body>
                <h1>Agent Ontology</h1>
                <p><a href="./ontology.ttl">Download ontology.ttl</a></p>
              </body>
              </html>
              EOF
            '';

            installPhase = ''
              mkdir -p $out
              cp -r gh-pages/* $out/
              echo "✅ gh-pages folder ready at: $out"
            '';
          };
        }
      );
    };
}