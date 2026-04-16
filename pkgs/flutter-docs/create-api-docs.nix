{
  git,
  gnutar,
  zip,

  buildDartApplication,
  callPackage,
  flutter,
  lib,
  ...
}:
let
  snippets = callPackage ./snippets.nix {};
in
buildDartApplication rec {
  pname = "flutter-docs";
  inherit (flutter.unwrapped) version src;
  sourceRoot = "${src.name}/dev/tools";

  propagateBuildInputs = [ git gnutar snippets zip ];

  # we use `src` instead of `sourceRoot` because it is workspace-scoped, so the lockfile is at the root
  autoPubspecLock = src + "/pubspec.lock";
  gitHashes = {
    assets_for_android_views = "sha256-GN7nBxBwnlByp3E8uUDabWiuMUoYYHPtIveF+RiEpS8=";
  };

  sdkSourceBuilders = callPackage ./sdk-source-builders.nix {};

  dartEntryPoints = {
    "bin/create_api_docs" = "create_api_docs.dart";
  };

  meta = {
    homepage = "https://github.com/flutter/flutter/tree/main/dev/snippets";
    license = lib.licenses.bsd3;
    platform = flutter.meta.platforms;
    maintainers = with lib.maintainers; [ blokyk ];
    mainProgram = "create_api_docs";
  };
}
