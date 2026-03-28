{ stdenv, fetchurl, makeWrapper }:

stdenv.mkDerivation rec {
  pname = "helix";
  version = "25.07.1";

  src = fetchurl {
    url = "https://github.com/helix-editor/helix/releases/download/${version}/helix-${version}-aarch64-macos.tar.xz";
    hash = "sha256-ALFlG0/bvgoq6YHI52uFi9JqfDP1s1g/O2u5E31U8f8=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;

  # the tar creates helix-25.01.1-aarch64-macos/
  sourceRoot = "helix-${version}-aarch64-macos";

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/lib/helix

    cp hx /$out/bin
    chmod +x $out/bin/hx

    cp -r runtime $out/lib/helix/runtime
    cp -r contrib $out/lib/helix/contrib

    wrapProgram $out/bin/hx \
      --set HELIX_RUNTIME $out/lib/helix/runtime
  '';
}
