{
  rustPlatform,
  maven,
  pkg-config,
  openssl,

  lib,
  pins,

  nix-update-script,

  backends ? [ "jar" "server" ],
  variants ? [ "cli" "lsp" ],
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "typst-languagetool";
  version = "0-unstable-2026-06-28";
  __structuredAttrs = true;

  src = pins.typst-languagetool;

  cargoHash = "sha256-ZtK77V3bmz+OkJYWm6eX9YPgaYEoLHRT2IoEpyUe1uc=";

  nativeBuildInputs = [
    pkg-config
  ] ++ (lib.optionals (lib.intersectLists ["bundle" "jar"] backends != []) [
    maven
  ]);

  buildInputs = [ openssl ];

  cargoBuildFlags = lib.concatMap (variant: ["-p" variant]) variants;
  buildFeatures = backends;

  passthru.updateScript = nix-update-script { };

  meta = {
    broken = lib.elem "bundle" backends;
    description = "LanguageTool Integration for Typst for spell and grammar check";
    homepage = "https://github.com/antonWetzel/typst-languagetool";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ blokyk ];
    mainProgram = "typst-languagetool";
  };
})
