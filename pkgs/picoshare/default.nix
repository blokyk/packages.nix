{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  litestream,
  litestreamSupport ? false,
  ...
}:
let
  pname = "picoshare";
  version = "1.5.1";
in
buildGoModule {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "mtlynch";
    repo = "picoshare";
    tag = version;
    sha256 = "sha256-8mgrwnY0Y1CggAtc7BrAqC32+Wu82FQNhoK0ijM1RKw=";
  };

  vendorHash = "sha256-Wf0qKs/9XKnO2nx2KmTGPdqI0iFih30AGvOi94RPEjw=";

  buildInputs = if litestreamSupport then [ litestream ] else [ ];

  doInstallCheck = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Minimalist, easy-to-host service for sharing images and other files";
    homepage = "https://github.com/mtlynch/picoshare";
    license = lib.licenses.agpl3Only;
    mainProgram = "picoshare";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    maintainers = with lib.maintainers; [
      blokyk
    ];
  };
}
