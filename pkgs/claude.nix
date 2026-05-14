{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname   = "claude-code";
  version = "2.1.141";

  src = fetchurl {
    url  = "https://downloads.claude.ai/claude-code-releases/${version}/darwin-arm64/claude";
    hash = "sha256-MayVuxmjOx0M3dPz/1lL+L/SvlBRzSr3hnEJZByrcF4=";
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
