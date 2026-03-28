# pkgs/timeago.nix
{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname   = "timeago";
  version = "1.0.2";

  src = fetchurl {
    url  = "https://github.com/studiowebux/timeago/releases/download/${version}/timeago-macos-latest";
    hash = "sha256-2bCA1Dhe6kSqKVAmokJiALRa9aCmNtPfVBKIc05n1QE=";
  };

  dontUnpack = true;
  dontBuild  = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/timeago
    chmod +x $out/bin/timeago
  '';
}
