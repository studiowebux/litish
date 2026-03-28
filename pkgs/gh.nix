{ stdenv, fetchurl, unzip }:

stdenv.mkDerivation rec {
  pname = "gh";
  version = "2.88.1";

  src = fetchurl {
    url = "https://github.com/cli/cli/releases/download/v${version}/gh_2.88.1_macOS_arm64.zip";
    hash = "sha256-vb7tSCHUUO8NFIIdhWwFswirRJ+/YFJ/KY2W+/XSRHs=";
  };

  dontBuild = true;
  sourceRoot = "gh_2.88.1_macOS_arm64";

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    mkdir -p $out/bin
    cp bin/gh /$out/bin
    chmod +x $out/bin/gh
  '';
}
