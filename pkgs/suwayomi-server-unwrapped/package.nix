{
  fetchFromGitHub,
  gradle_9,
  jdk,
  kotlin,
  stdenv,

  enableSystemTray ? false,

  lib,
}@args:
let
  gradle = gradle_9;
  jdk = args.jdk.override { headless = !enableSystemTray; };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "suwayomi-server";
  version = "2.2.2100";

  src = fetchFromGitHub {
    owner = "Suwayomi";
    repo = "Suwayomi-Server";
    rev = "v${finalAttrs.version}";
    hash = "sha256-RPVz2BDBtFXmXzc3DlSIzkwsjfd+WNGV3O0llJF4P1A=";
  };

  outputHashAlgo = "sha256";
  outputHashMode = "flat";
  outputHash = "sha256-G8pa7mbq1Qv7pptBFREY2zqXcmMZPKpK7UUxZB1euvE=";

  postPatch = ''
    # set the version correctly
    substituteInPlace buildSrc/src/main/kotlin/Constants.kt \
      --replace-fail 'v${lib.versions.majorMinor finalAttrs.version}.''${getCommitCount()}' '${finalAttrs.version}'

    # fix the build date to the unix epoch
    substituteInPlace server/build.gradle.kts \
      --replace-fail 'Instant.now().epochSecond.toString()' '0'

    echo -e '\nkotlin.daemon.jvmargs=-Xmx4G' >> gradle.properties
  '';

  enableParallelBuilding = true;

  nativeBuildInputs = [
    jdk
    kotlin
    gradle.unwrapped # use unwrapped so it doesn't inject the setup hook
    # stripJavaArchivesHook # build's fixup becomes *extremely* slow (couldn't finish on my laptop)
  ];

  env = {
    "ProductBuildType" = "Stable";
  };

  buildPhase = ''
    runHook preBuild

    gradle --parallel --console plain --no-daemon \
      :server:shadowJar

    runHook postBuild
  '';

  checkPhase = ''
    runHook preCheck

    gradle --parallel --console plain --no-daemon \
      :server:check

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 ./server/build/Suwayomi-Server-*.jar $out

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