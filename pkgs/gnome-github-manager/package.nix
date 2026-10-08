{
  lib,
  stdenv,

  fetchYarnDeps,
  glib,
  jq,
  nodejs,
  yarnConfigHook,
  yarnBuildHook,
  yq-go,

  nixosTests,
  gnome-shell,

  pins,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-github-manager";
  version = "1.0.0-unstable-2026-05-13";

  src = pins.gnome-github-manager.outPath;

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = finalAttrs.src + "/yarn.lock";
    hash = "sha256-D6j/sAtZAy0PI+E467uvFtsyFAl5E5Too0Ti2KrdcKw=";
  };

  nativeBuildInputs = [
    nodejs
    yarnConfigHook
    yarnBuildHook

    glib
    jq
    yq-go
    # we should technically also add git but it's not strictly required so /shrug
  ];

  checkPhase = ''
    runHook preCheck

    yarn --offline test

    runHook postInstall
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/gnome-shell/extensions/
    cp -r ./build/dist -T "$out/share/gnome-shell/extensions/${finalAttrs.passthru.extensionUuid}";

    runHook postInstall
  '';

  meta = {
    description = "Integrate GitHub within the GNOME Desktop Environment";
    homepage = "https://github.com/mackdk/gnome-github-manager";
    license = lib.licenses.gpl3Plus;
    platforms = gnome-shell.meta.platforms;
  };

  passthru = {
    extensionPortalSlug = "gnome-github-manager";
    extensionUuid = "github-manager@mackdk-on-github";
    tests = {
      gnome-extensions = nixosTests.gnome-extensions;
    };
  };
})
