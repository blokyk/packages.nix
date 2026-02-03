rec {
  blokyk = {
    name = "blokyk";
    github = "blokyk";
    githubId = 32983140;
  };

  overlay = final: prev: {
    lib = prev.lib // {
      maintainers = prev.lib.maintainers // {
        blokyk = blokyk;
      };
    };
  };
}
