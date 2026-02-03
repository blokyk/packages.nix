{
  fetchFromGitHub,
  gradle_9,
  jdk,
  jre,
  kotlin,
  makeWrapper,
  stdenv,

  enableSystemTray ? false,

  lib,
}@args:
let
  gradle = gradle_9;
  jdk = args.jdk.override { headless = !enableSystemTray; };
  jre = args.jre.override { headless = !enableSystemTray; };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "suwayomi-server";
  version = "2.1.2061";
  rev = "a58dcc6f19cf0f1ea27c0042f6e229d7bb3ff8af";

  src = fetchFromGitHub {
    owner = "Suwayomi";
    repo = "Suwayomi-Server";
    rev = finalAttrs.rev;
    hash = "sha256-7ckf4TVOfgZQyivNkzi6aWNU/r9DTbGsVaPwmtJr5Vg=";
  };

  patchPhase = ''
    runHook prePatch

    # set the version correctly
    substituteInPlace buildSrc/src/main/kotlin/Constants.kt \
      --replace-fail 'v2.1.''${getCommitCount()}' '${finalAttrs.version}'

    # fix the build date to the unix epoch
    substituteInPlace server/build.gradle.kts \
      --replace-fail 'Instant.now().epochSecond.toString()' '0'

    runHook postPatch
  '';

  # this is required for using mitm-cache on Darwin
  __darwinAllowLocalNetworking = true;
  mitmCache = gradle.fetchDeps {
    pkg = finalAttrs.finalPackage;
    data = ./deps.json;
    useBwrap = false;
  };

  # it seems we have to do a full build of the whole app to
  # get *all* the dependencies (e.g. the AndroidCompat onces)
  gradleUpdateTask = ":server:shadowJar";
  # let
  #   versionOptionals = ver: vals: lib.optionals (lib.versionAtLeast finalAttrs.version ver) vals;
  #   projects = [
  #     "buildSrc"
  #     "AndroidCompat" "AndroidCompat:Config"
  #     "server"
  #   ]
  #   ++ versionOptionals "2.1.1867" [ "server:i18n" ]
  #   ++ versionOptionals "2.1.1909"
  #       [ "server:server-config" "server:server-config-generate" ];
  # in
  #   [":nixDownloadDeps"] ++ map (project: ":${project}:nixDownloadDeps") projects;

  enableParallelBuilding = true;

  nativeBuildInputs = [
    gradle
    jdk
    kotlin
    makeWrapper
    # stripJavaArchivesHook # build's fixup becomes *extremely* slow (couldn't finish on my laptop)
  ];

  buildInputs = [
    jre
  ];

  gradleFlags = [
    # the kotlin build can fail if there's not enough memory
    "-Dkotlin.daemon.jvmargs=-Xmx2G"
  ];

  env = {
    "ProductBuildType" = "Stable";
  };

  gradleBuildTask = ":server:shadowJar";

  gradleCheckTask = ":server:test";

  installPhase = ''
    runHook preInstall

    install -Dm644 ./server/build/Suwayomi-Server-*.jar $out/share/java/tachidesk-server.jar

    makeWrapper ${lib.getExe jre} $out/bin/tachidesk-server \
      --add-flags "-jar $out/share/java/tachidesk-server.jar"

    runHook postInstall
  '';

  meta = {
    description = "Free and open source manga reader server that runs extensions built for Mihon (Tachiyomi)";
    longDescription = ''
      Suwayomi is an independent Mihon (Tachiyomi) compatible software and is not a Fork of Mihon (Tachiyomi).

      Suwayomi-Server is as multi-platform as you can get. Any platform that runs java and/or has a modern browser can run it. This includes Windows, Linux, macOS, chrome OS, etc.
    '';
    homepage = "https://github.com/Suwayomi/Suwayomi-Server";
    downloadPage = "https://github.com/Suwayomi/Suwayomi-Server/releases";
    changelog = "https://github.com/Suwayomi/Suwayomi-Server/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mpl20;
    platforms = jdk.meta.platforms;
    sourceProvenance = [
      lib.sourceTypes.fromSource
      lib.sourceTypes.binaryBytecode
    ];
    maintainers = with lib.maintainers; [ blokyk ];
    mainProgram = "tachidesk-server";
  };
})
