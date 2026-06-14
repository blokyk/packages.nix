{
  fetchFromGitHub,
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "zsh-patina";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "michel-kraemer";
    repo = "zsh-patina";
    rev = finalAttrs.version;
    hash = "sha256-sPlIT3UHtq+5+bpfrSPPfVXTdmqjEq+6k9tPShhG7h0=";
  };

  cargoHash = "sha256-j2MwEwQhSCUCwANAxr0aZjJ9iS0cGzRRttfK8LONEpg=";

  meta = {
    description = "A blazingly fast Zsh syntax highlighter";
    homepage = "https://github.com/michel-kraemer/zsh-patina";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "zsh-patina";
    maintainers = with lib.maintainers; [ blokyk ];
  };
})
