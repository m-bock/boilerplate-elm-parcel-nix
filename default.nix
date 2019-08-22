{ pkgs ? import <nixpkgs> {}
}:

let
  yarnPkg = pkgs.yarn2nix.mkYarnPackage {
    name = "myproject-node-packages";
    packageJSON = ./package.json;
    unpackPhase = ":";
    src = null;
    yarnLock = ./yarn.lock;
    publishBinsFor = ["parcel-bundler"];
  };
in pkgs.stdenv.mkDerivation {
  name = "myproject-frontend";
  src = pkgs.lib.cleanSource ./.;

  buildInputs = with pkgs.elmPackages; [
    elm
    elm-format
    yarnPkg
    pkgs.yarn
  ];

  patchPhase = ''
    rm -rf elm-stuff
    ln -sf ${yarnPkg}/node_modules .
  '';

  shellHook = ''
    ln -fs ${yarnPkg}/node_modules .
  '';

  configurePhase = pkgs.elmPackages.fetchElmDeps {
    elmPackages = import ./elm-srcs.nix;
    versionsDat = ./versions.dat;
  };

  installPhase = ''
    mkdir -p $out
    parcel build -d $out index.html
  '';
}
