{
  links = {
    "cv".file = /home/rub/docs/cv.pdf;
    "gh".url = "https://github.com/ghost";
    "brr" = {
      file = /boot/vmlinuz;
      content-type = "audio/wav";
    };
  };

  hosts = {
    "status".port = 4512;

    "share" = {
      port = 2345;
      maxUpload = "1000M";
      timeout = 600;
    };
  };
}
