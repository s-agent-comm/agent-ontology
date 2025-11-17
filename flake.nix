{
  description = "A flake for building the Agent Ontology";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.stdenv.mkDerivation {
            name = "agent-ontology";
            src = self;
            buildPhase = ''
              cat *.ttl > agent-ontology.ttl
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