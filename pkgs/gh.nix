{ stdenv, fetchurl, unzip }:

stdenv.mkDerivation rec {
  pname = "gh";
  version = "2.103.3";

  src = fetchurl {
    url = "https://github.com/cli/cli/releases/download/v${version}/gh_${version}_macOS_arm64.zip";
    hash = "sha256-1wAgfq6a6Y/iuJU1wsCHwHgj1GKMVjZGlaWgfvMRwGI=";
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
