{
  boost,
  capnproto,
  fetchFromGitHub,
  lib,
  rustPlatform,
  pkg-config,
  protobuf,

  buildRustPackage ? rustPlatform.buildRustPackage,

  nix,

  bear,
  rust-cbindgen,
}:
buildRustPackage (finalAttrs: {
  pname = "nix-otel";
  version = "2023-08-06";

  src = fetchFromGitHub {
    owner = "blokyk";
    repo = "nix-otel";
    rev = "849e776a8074797e81846e60901ad44faecf907d";
    sha256 = "sha256-309qtll7z94fTzTSlhyl2EkrQldp681MpRrpd+qhupo=";
  };

  cargoHash = "sha256-ePOzfob5FjpbThudEBDI10FVP3HMoP52nzuglZhk0wo=";

  nativeBuildInputs = [
    pkg-config
    protobuf
    nix

    bear
    rust-cbindgen
  ];

  buildInputs = [
    boost
    nix
    capnproto
  ];

  dontStrip = true;

  meta = {
    description = "Fork of lf-'s 'nix-otel', a Nix OpenTelemetry sender plugin.";
    homepage = "https://github.com/blokyk/nix-otel";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ blokyk ];
  };
})
