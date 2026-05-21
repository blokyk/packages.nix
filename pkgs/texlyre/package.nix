{
  buildNpmPackage,
  # callPackage,
  fetchFromGitHub,
  lib,
  makeWrapper,

  # texlyreConfig ? callPackage ./config.nix {}
  baseUrl ? "/",
}:

# although texlyre is packaged using npm, it is actually just
# a static website; therefore, we have to fight against
# `buildNpmPackage` a little bit, since it is designed for,
# well, packages. its main purpose here is to fetch dependencies
# and setup npm for us.
#
# texlyre is also a little annoying for us, since it runs its
# "build" action actually does basically everything (config, build,
# pack, etc). since i love suffering, i've chosen to break it down
# into the distinct phases it *should* be.
#
# since the end product is a static website and not a `/node_modules`
# folder, the only thing we have to do here is copy the final
# static files (index.html, etc.) to $out

buildNpmPackage (finalAttrs: {
  pname = "texlyre";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "TeXlyre";
    repo = "texlyre";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-rXnjuI+2FYE3i98Ul/MOfG8rcn5tSiCUGBta0hPElNo=";
  };

  # did you know that `npmConfigHook` runs during the *patch* phase? DID YOU???
  configurePhase = ''
    runHook preConfigure

    # make sure the version in package.json is the deriv's version
    sed -i 's/"version": ".*"/"version": "${finalAttrs.version}"/' package.json

    # todo: write separate derivation that generates the config
    # patch texlyre.config.ts (e.g. baseUrl)
    substituteInPlace texlyre.config.ts \
      --replace-fail "baseUrl: '/texlyre/'" "baseUrl: 'baseUrl'"

    npm run generate-configs

    # writes to languages.config.json (itself used by)
    npm run i18n:coverage
    # writes version from package.json to sw.js (the service worker script)
    node scripts/pm.cjs tsx scripts/update-sw-version.js

    runHook postConfigure
  '';

  nativeBuildInputs = [ makeWrapper ];

  npmDepsHash = "sha256-KvU58TTga1Zb/S8I+g5EZVoG+gdOJtefVqxUa4wXSoU=";

  buildPhase = ''
    runHook preBuild

    # builds the plugins from extras/ and puts the js into src/plugins/
    npm run generate-plugins
    # write list of supported fonts in public/assets/fonts/fonts.json
    npm run generate-fonts

    # type-check the typescript (kinda? i think? it doesn't catch everything it seems, and it doesn't build anything)
    node scripts/pm.cjs tsc

    # build and package everything into dist/
    node scripts/pm.cjs vite build

    runHook postBuild
  '';

  checkPhase = ''
    runHook preCheck
    node scripts/pm.cjs jest
    runHook postCheck
  '';

  # just copy the static website to out/ and nothing else
  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r dist/. $out

    runHook postInstall
  '';

  meta = {
    description = "A local-first LaTeX & Typst web editor with real-time collaboration & offline support";
    homepage = "https://github.com/TeXlyre/texlyre";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "texlyre";
    maintainers = with lib.maintainers; [ blokyk ];
  };
})
