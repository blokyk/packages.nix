{
  jre,
  lib,
  suwayomi-server-unwrapped,
  writeShellApplication,
}:
writeShellApplication {
  name = "tachidesk-server";
  text = ''
    ${lib.getExe jre} -jar ${suwayomi-server-unwrapped} "''${@}"
  '';

  derivationArgs = {
    inherit (suwayomi-server-unwrapped) meta;
  };
}