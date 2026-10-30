# pkgs/kubectl.nix
{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname   = "kubectl";
  version = "1.37.2";

  src = fetchurl {
    url  = "https://dl.k8s.io/release/v${version}/bin/darwin/arm64/kubectl";
    hash = "sha256-VXAa8NUYFe4zXyQOSKzwlZw8IwF+0/qBbogMSpK65YE=";
  };

  dontUnpack = true;
  dontBuild  = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/kubectl
    chmod +x $out/bin/kubectl
  '';
}
