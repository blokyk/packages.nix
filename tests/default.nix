with import <nixpkgs> { };
{
  hostrr = callPackage ./hostrr { };
  syncyomi = callPackage ./syncyomi { };
}
