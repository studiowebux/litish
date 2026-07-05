{ stdenv, fetchurl, unzip }:

stdenv.mkDerivation rec {
  pname = "gh";
  version = "2.96.0";

  src = fetchurl {
    url = "https://github.com/cli/cli/releases/download/v${version}/gh_${version}_macOS_arm64.zip";
    hash = "sha256-8joMN9ljqsw77XA8y9WbQcXKIhAfq38A6yt8rSOrpGM=";
  };

  dontBuild = true;
  sourceRoot = "gh_${version}_macOS_arm64";

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    mkdir -p $out/bin
    cp bin/gh /$out/bin
    chmod +x $out/bin/gh
  '';
}
