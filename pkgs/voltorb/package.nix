{
  lib,
  pins,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "voltorb";
  version = "2022-05-17";

  src = pins.voltorb;

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
