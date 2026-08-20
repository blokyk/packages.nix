{
  lib,
  rustPlatform,

  pins,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "zsh-patina";
  version = pins.zsh-patina.version;

  src = pins.zsh-patina;

  cargoHash = "sha256-4Meb4BDV/Um8/YMA5DkeNDcgCMS5cA8olKhOIq9coIU=";

  meta = {
    description = "A blazingly fast Zsh syntax highlighter";
    homepage = "https://github.com/michel-kraemer/zsh-patina";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "zsh-patina";
    maintainers = with lib.maintainers; [ blokyk ];
  };
})
