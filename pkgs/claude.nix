{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname   = "claude-code";
  version = "2.1.319";

  src = fetchurl {
    url  = "https://downloads.claude.ai/claude-code-releases/${version}/darwin-arm64/claude";
    hash = "sha256-H1NYfpLe6OCJ+jSRiKTNpk+jSs5uewyi7ieN2qPMLr0=";
  };

  dontUnpack = true;
  dontBuild  = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/claude
    chmod +x $out/bin/claude
  '';

  meta = {
    description = "Claude Code CLI";
    homepage    = "https://claude.ai/code";
    platforms   = [ "aarch64-darwin" ];
  };
}
