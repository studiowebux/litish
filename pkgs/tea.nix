{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "tea";
  version = "0.14.1";

  src = fetchurl {
    url = "https://gitea.com/gitea/tea/releases/download/v${version}/tea-${version}-darwin-arm64";
    hash = "sha256-UsSCuWTeY5d7WoNrSXbwsJih395khsp7jQpu4ptPeUU=";
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/tea
    chmod +x $out/bin/tea
  '';
}
