{
  lib,
  stdenv,
  fetchFromGitHub,
  replaceVars,
  gitstatus,
  bash,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "powerlevel10k";
  version = "1.20.15";

  src = fetchFromGitHub {
    owner = "romkatv";
    repo = "zsh4humans";
    rev = "cd6c4770c802c3a17b4c43e5587adabb9a370a75";
    hash = "sha256-OMpcDS8S6OTVe7sC4iQ3LMpwNx2tcCBGBnORwL3ix6w=";
  };

  strictDeps = true;

  buildInputs = [ bash ];

  patches = [
    ./z4h-cache.patch
    ./z4h-tmp.patch
  ];

  installPhase = ''
    runHook preInstall

    rm .gitignore .gitattributes z4h.zsh install version changelog.md README.md tips.md .zshrc .zshrc.mac

    mkdir -p "$out/share/zsh4humans"
    cp -R . "$out/share/zsh4humans"

    runHook postInstall
  '';

  meta = {
    changelog = "https://github.com/romkatv/zsh4humans/tree/v5/changelog.md";
    description = "A turnkey configuration for Zsh";
    homepage = "https://github.com/romkatv/zsh4humans";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ blokyk ];
  };
})
