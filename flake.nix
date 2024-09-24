{
  inputs.gradle2nix = {
    url = "github:tadfisher/gradle2nix/v2";
  };

  outputs = {
    self,
    nixpkgs,
    gradle2nix,
    systems,
  }: let
    inherit (nixpkgs) lib;
    eachSystem = f:
      lib.genAttrs (import systems) (system:
        f rec {
          inherit system self;
          pkgs = nixpkgs.legacyPackages.${system};
          jdk = pkgs.jdk11;
          ownPkgs = self.packages.${system};
        });
  in {
    packages = eachSystem ({
      system,
      pkgs,
      jdk,
      ...
    }: {
      default = gradle2nix.builders.${system}.buildGradlePackage {
        pname = "CS2020-java-template";
        version = "1.0-SNAPSHOT";
        src = ./.;

        lockFile = ./gradle.lock;

        # Yes, this is necessary When building with gradle = pkgs.gradle. ...,
        # gradle crashes complaining about having multiple --console arguments
        # It is not apparent that there are, in fact, multiple passed, nor even
        # one
        gradle = pkgs.writeShellScriptBin "gradle" ''
          exec ${pkgs.gradle.override {java = jdk;}}/bin/gradle "$@"
        '';

        buildJdk = jdk;

        gradleBuildFlags = [":build"];
        gradleInstallFlags = [":installDist"];
        postInstall = ''
          mkdir $out
          cp -r build/install/*/* $out/
        '';
      };
    });
    devShells = eachSystem ({
      system,
      pkgs,
      ownPkgs,
      jdk,
      ...
    }: {
      default = pkgs.mkShell {
        inputsFrom = [ownPkgs.default];
        packages = let
          gradle = pkgs.gradle.override {java = jdk;};
        in [jdk pkgs.jdt-language-server gradle gradle2nix.packages.${system}.default pkgs.just];
      };
    });
    checks = eachSystem ({ ownPkgs, ... }: {
      build = ownPkgs.default.overrideAttrs {
        gradleCheckFlags = [":test"];
      };
    });
  };
}
