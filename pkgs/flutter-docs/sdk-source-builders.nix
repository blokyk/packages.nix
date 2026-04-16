{ flutter, runCommand }: {
  # https://github.com/dart-lang/pub/blob/68dc2f547d0a264955c1fa551fa0a0e158046494/lib/src/sdk/flutter.dart#L81
  "flutter" =
    name:
    runCommand "flutter-sdk-${name}" { passthru.packageRoot = "."; } ''
      for path in '${flutter}/packages/${name}' '${flutter}/bin/cache/pkg/${name}'; do
        if [ -d "$path" ]; then
          ln -s "$path" "$out"
          break
        fi
      done

      if [ ! -e "$out" ]; then
        echo 1>&2 'The Flutter SDK does not contain the requested package: ${name}!'
        exit 1
      fi
    '';
  # https://github.com/dart-lang/pub/blob/e1fbda73d1ac597474b82882ee0bf6ecea5df108/lib/src/sdk/dart.dart#L80
  "dart" =
    name:
    runCommand "dart-sdk-${name}" { passthru.packageRoot = "."; } ''
      for path in '${flutter.dart}/pkg/${name}'; do
        if [ -d "$path" ]; then
          ln -s "$path" "$out"
          break
        fi
      done

      if [ ! -e "$out" ]; then
        echo 1>&2 'The Dart SDK does not contain the requested package: ${name}!'
        exit 1
      fi
    '';
}
