# pkgs/sshtui.nix
{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname   = "sshtui";
  version = "0.0.3";

  src = fetchurl {
    url  = "https://github.com/studiowebux/sshtui/releases/download/${version}/sshtui-macos-latest";
    hash = "sha256-HE+QKqMd4pYmV+qWpVAIT6pd8cx9M60y6mzk6w3ctkE=";
  };

  dontUnpack = true;
  dontBuild  = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/sshtui
    chmod +x $out/bin/sshtui
  '';
}
