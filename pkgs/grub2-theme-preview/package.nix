{
  lib,
  pins,

  python3Packages,

  # grub2,
  grub2_efi,
  mtools,
  OVMF,
  qemu,
  xorriso,

  nix-update-script,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "grub2-theme-preview";
  version = pins.grub2-theme-preview.version;

  __structuredAttrs = true;

  src = pins.grub2-theme-preview;

  pyproject = true;

  build-system = [
    python3Packages.setuptools
  ];

  dependencies = with python3Packages; [
    attrs
    coverage
    exceptiongroup
    importlib-metadata
    iniconfig
    packaging
    parameterized
    pluggy
    pygments
    pyparsing
    pytest
    tomli
    typing-extensions
    zipp
  ];

  postInstall = ''
    wrapProgram $out/bin/grub2-theme-preview \
      --set-default G2TP_OVMF_IMAGE "${OVMF.firmware}" \
      --set-default G2TP_GRUB_LIB "${grub2_efi}/lib/grub" \
      --suffix PATH : ${lib.makeBinPath [
        grub2_efi
        mtools
        qemu
        xorriso
      ]}
  '';

  pythonImportsCheck = [
    "grub2_theme_preview"
  ];

  meta = {
    description = "preview a full GRUB 2.x theme using KVM / QEMU";
    homepage = "https://github.com/hartwork/grub2-theme-preview";
    changelog = "https://github.com/hartwork/grub2-theme-preview/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ blokyk ];
    mainProgram = "grub2-theme-preview";
  };
})
