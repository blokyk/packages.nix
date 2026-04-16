{
  flutter,

  buildDartApplication,
  callPackage,
  lib,
}:
buildDartApplication rec {
  pname = "snippets";
  inherit (flutter.unwrapped) version src;

  sourceRoot = "${src.name}/dev/snippets";

  # we use `src` instead of `sourceRoot` because it is workspace-scoped, so the lockfile is at the root
  autoPubspecLock = src + "/pubspec.lock";

  gitHashes = {
    assets_for_android_views = "sha256-GN7nBxBwnlByp3E8uUDabWiuMUoYYHPtIveF+RiEpS8=";
  };

  sdkSourceBuilders = callPackage ./sdk-source-builders.nix {};

  meta = {
    description = "A package for parsing and manipulating code samples in Flutter repo dartdoc comments.";
    homepage = "https://github.com/flutter/flutter/tree/main/dev/snippets";
    license = lib.licenses.bsd3;
    platform = flutter.meta.platforms;
    maintainers = with lib.maintainers; [ blokyk ];
    mainProgram = "snippets";
  };
}
