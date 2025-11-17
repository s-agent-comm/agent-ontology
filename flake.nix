{
  description = "A flake for developing the Agent Ontology";

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
          pythonPackages = ps: with ps; [
            pyshacl
            rdflib
          ];
          pythonEnv = pkgs.python3.withPackages pythonPackages;
        in
        {
          default = pkgs.mkShell {
            packages = [
              pythonEnv
              pkgs.apache-jena
            ];
          };
        }
      );

      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.stdenv.mkDerivation {
            name = "agent-ontology";
            src = self;
            buildPhase = ''
              cat ontologies/*.ttl > agent-ontology.ttl
            '';
            installPhase = ''
              mkdir -p $out
              cp agent-ontology.ttl $out/
            '';
          };
        }
      );
    };
}