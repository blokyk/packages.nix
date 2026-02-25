{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "voltorb";
  version = "2022-05-17";

  src = fetchFromGitHub {
    owner = "mcy";
    repo = "voltorb";
    rev = "9b05d113e00d6a43d21a09bc6151eb40ed2f343e";
    hash = "sha256-pgJK/K22+COSsLE14NOAX94rWna7nxCCKHShivP2L2Y=";
  };

  # we have to vendor a Cargo.lock because the original repo doesn't have one
  cargoLock.lockFile = ./Cargo.lock;
  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  meta = {
    description = "Voltorb Flip in your terminal";
    homepage = "https://github.com/mcy/voltorb";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ blokyk ];
    mainProgram = "voltorb";
  };
})
