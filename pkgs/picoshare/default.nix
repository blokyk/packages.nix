{ lib, pkgs, ... }: pkgs.buildGoModule rec {
  pname = "picoshare";
  version = "1.5.1";

  src = pkgs.fetchFromGitHub {
    owner = "mtlynch";
    repo = "picoshare";
    tag = "${version}";
    sha256 = "sha256-8mgrwnY0Y1CggAtc7BrAqC32+Wu82FQNhoK0ijM1RKw=";
  };

  vendorHash = "sha256-Wf0qKs/9XKnO2nx2KmTGPdqI0iFih30AGvOi94RPEjw=";

  meta = with lib; {
    description = "A minimalist, easy-to-host service for sharing images and other files";
    home = "https://github.com/mtlynch/picoshare";
    license = licenses.agpl3Only;
    maintainers = [ maintainers.blokyk ];
    mainProgram = "picoshare";
  };
}