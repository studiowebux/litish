# pkgs/odin.nix
# Builds the Odin compiler from source on macOS.
# See https://odin-lang.org/docs/install/#macos
{
  lib,
  stdenv,
  fetchFromGitHub,
  llvmPackages_18,
  makeBinaryWrapper,
  which,
}:

let
  llvm = llvmPackages_18;
in
stdenv.mkDerivation rec {
  pname   = "odin";
  version = "dev-2026-06";

  src = fetchFromGitHub {
    owner  = "odin-lang";
    repo   = "Odin";
    rev    = version;
    hash   = "sha256-Z2497J80j5OLiyhTumrsofNANnNrnDE6Z3UB1b/TVGg=";
  };

  nativeBuildInputs = [
    makeBinaryWrapper
    which
  ];

  buildInputs = [
    llvm.llvm
    llvm.clang
    llvm.bintools
    llvm.lld
  ];

  # Without a .git dir, build_odin.sh stamps the version from the build
  # machine's clock (`date +%Y-%m`), making it non-reproducible. Pin it to
  # the tag's date instead.
  postPatch = ''
    substituteInPlace build_odin.sh \
      --replace-fail 'GIT_DATE=$(date +"%Y-%m")' 'GIT_DATE="${lib.removePrefix "dev-" version}"'

    # Nix's cc-wrapper expects the *-apple-darwin triple, not *-apple-macosx,
    # otherwise every compile prints a spurious target-mismatch warning.
    substituteInPlace src/build_settings.cpp \
      --replace-fail '"arm64-apple-macosx"' '"arm64-apple-darwin"'
  '';

  dontConfigure = true;

  # The Makefile shells out to llvm-config; point it at the Nix LLVM.
  env.LLVM_CONFIG = "${llvm.llvm.dev}/bin/llvm-config";

  buildFlags = [ "release" ];

  # The compiler resolves base/core/vendor relative to its own location
  # unless ODIN_ROOT is set, so install the runtime into $out/share and
  # wrap the binary to point at it (and at the LLVM toolchain it invokes).
  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share
    cp odin $out/bin/odin
    cp -r base core vendor shared $out/share/

    wrapProgram $out/bin/odin \
      --set ODIN_ROOT $out/share \
      --prefix PATH : ${llvm.bintools}/bin:${llvm.llvm}/bin:${llvm.clang}/bin:${llvm.lld}/bin

    runHook postInstall
  '';

  meta = {
    description = "Odin programming language compiler (built from source)";
    homepage    = "https://odin-lang.org";
    platforms   = [ "aarch64-darwin" ];
  };
}
