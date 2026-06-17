{
  fetchFromGitHub,
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "zsh-patina";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "michel-kraemer";
    repo = "zsh-patina";
    rev = finalAttrs.version;
    hash = "sha256-M14IeK+Nsst+6RK6ayhq37YSoFPVptNqE9blVHDI1YM=";
  };

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
