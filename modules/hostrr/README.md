# `hostrr`

`hostrr` is a small module I made to centralize the different bits of
configuration each of my hosted services require (e.g. setting up reverse
proxying, adding a dns subdomain, monitoring their status, etc). It also
supports adding shortlinks that can serve static files or redirect to URLs.

For now, it only supports NGINX. Also all that DNS stuff isn't done yet (gotta
write my long-awaited dns module first...), sorry.

todo: add `hostrr` docs. in the meantime you can look at my uses of it for
[flink-shortening](https://github.com/blokyk/naqi.nix/blob/555d57b/site/links.nix)
and [reverse-proxying](https://github.com/blokyk/naqi.nix/blob/555d57b/site/hosts.nix).
