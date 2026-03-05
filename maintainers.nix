rec {
  blokyk = {
    name = "blokyk";
    github = "blokyk";
    githubId = 32983140;
  };

  overlay = final: prev: prev // {
    lib = prev.lib // {
      maintainers = prev.lib.maintainers // {
        blokyk = blokyk;
      };
    };
  };
}
