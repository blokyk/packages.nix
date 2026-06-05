{ lib, _check, multiKeybindings }:
let
  inherit (lib) genList concatStringsSep types;

  xf86keys = [
    "XF86AddFavorite"
    "XF86ApplicationLeft"
    "XF86ApplicationRight"
    "XF86AudioMedia"
    "XF86AudioMute"
    "XF86AudioNext"
    "XF86AudioPause"
    "XF86AudioPlay"
    "XF86AudioPrev"
    "XF86AudioLowerVolume"
    "XF86AudioRaiseVolume"
    "XF86AudioRecord"
    "XF86AudioRewind"
    "XF86AudioStop"
    "XF86Away"
    "XF86Back"
    "XF86Book"
    "XF86BrightnessAdjust"
    "XF86CD"
    "XF86Calculator"
    "XF86Calendar"
    "XF86Clear"
    "XF86ClearGrab"
    "XF86Close"
    "XF86Community"
    "XF86ContrastAdjust"
    "XF86Copy"
    "XF86Cut"
    "XF86DOS"
    "XF86Display"
    "XF86Documents"
    "XF86Eject"
    "XF86Excel"
    "XF86Explorer"
    "XF86Favorites"
    "XF86Finance"
    "XF86Forward"
    "XF86Game"
    "XF86Go"
    "XF86History"
    "XF86HomePage"
    "XF86HotLinks"
    "XF86Launch0"
    "XF86Launch1"
    "XF86Launch2"
    "XF86Launch3"
    "XF86Launch4"
    "XF86Launch5"
    "XF86Launch6"
    "XF86Launch7"
    "XF86Launch8"
    "XF86Launch9"
    "XF86LaunchA"
    "XF86LaunchB"
    "XF86LaunchC"
    "XF86LaunchD"
    "XF86LaunchE"
    "XF86LaunchF"
    "XF86LightBulb"
    "XF86LogOff"
    "XF86Mail"
    "XF86MailForward"
    "XF86Market"
    "XF86Meeting"
    "XF86Memo"
    "XF86MenuKB"
    "XF86MenuPB"
    "XF86Messenger"
    "XF86Music"
    "XF86MyComputer"
    "XF86MySites"
    "XF86New"
    "XF86News"
    "XF86Next_VMode"
    "XF86Prev_VMode"
    "XF86OfficeHome"
    "XF86Open"
    "XF86OpenURL"
    "XF86Option"
    "XF86Paste"
    "XF86Phone"
    "XF86Pictures"
    "XF86PowerDown"
    "XF86PowerOff"
    "XF86Next_VMode"
    "XF86Prev_VMode"
    "XF86Q"
    "XF86Refresh"
    "XF86Reload"
    "XF86Reply"
    "XF86RockerDown"
    "XF86RockerEnter"
    "XF86RockerUp"
    "XF86RotateWindows"
    "XF86RotationKB"
    "XF86RotationPB"
    "XF86Save"
    "XF86ScreenSaver"
    "XF86ScrollClick"
    "XF86ScrollDown"
    "XF86ScrollUp"
    "XF86Search"
    "XF86Send"
    "XF86Shop"
    "XF86Sleep"
    "XF86Spell"
    "XF86SplitScreen"
    "XF86Standby"
    "XF86Start"
    "XF86Stop"
    "XF86Support"
    "XF86Switch_VT_1"
    "XF86Switch_VT_10"
    "XF86Switch_VT_11"
    "XF86Switch_VT_12"
    "XF86Switch_VT_2"
    "XF86Switch_VT_3"
    "XF86Switch_VT_4"
    "XF86Switch_VT_5"
    "XF86Switch_VT_6"
    "XF86Switch_VT_7"
    "XF86Switch_VT_8"
    "XF86Switch_VT_9"
    "XF86TaskPane"
    "XF86Terminal"
    "XF86ToDoList"
    "XF86Tools"
    "XF86Travel"
    "XF86Ungrab"
    "XF86User1KB"
    "XF86User2KB"
    "XF86UserPB"
    "XF86VendorHome"
    "XF86Video"
    "XF86WWW"
    "XF86WakeUp"
    "XF86WebCam"
    "XF86WheelButton"
    "XF86Word"
    "XF86XF86BackForward"
    "XF86Xfer"
    "XF86ZoomIn"
    "XF86ZoomOut"
    "XF86iTouch"
  ];

  modifiers = [
    "<Primary>" "<Control>" "<Ctrl>" "<Ctl>"
    "<Shift>" "<Shft>"
    "<Alt>"
    "<Meta>"
    "<Super>" "<Hyper>"
  ];

  specialKeys = [
    "Up" "Down" "Left" "Right" "End"
    "space" "Space" "Above_Tab"
    "Home" "Print" "Escape"
  ];

  nonAlphaChars =
       [ "é" "è" "ç" "à" "ù" ]
    ++ [ "1" "2" "3" "4" "5" "6" "7" "8" "9" ]
    ++ [ "²" "&" "\"" "'" "(" "-" "_" ")" "=" "^" "$" "*" "," ";" ":" "!" ]
    ++ [ "~" "#" "{" "[" "|" "`" "\\" "^" "@" "]" "}" ];

  keys =
       modifiers
    ++ lib.lowerChars
    ++ lib.upperChars
    ++ nonAlphaChars
    ++ (genList (n: "F${toString (n+1)}") 24) # F1-F24
    ++ xf86keys
    ++ specialKeys
  ;

  keysType = types.enum keys // {
    description =
      "a lowercase or uppercase latin letter, " +
      "a modifier (one of ${concatStringsSep ", " modifiers}), " +
      "a special keys (one of ${concatStringsSep ", " specialKeys}), " +
      "an F key (frm F1 to F24), " +
      "or one of the XF86 keys"
      ;
  };

  # we don't want the module system to merge two declarations
  # of a single keybinding, because then
  #   foo = [ "<Super>" "A" ];
  #   foo = [ "<Ctrl>"  "Z" ];
  # would get merged into a single keybinding
  #   foo = [ "<Super>" "A" "<Ctrl>" "Z" ];
  # and good luck typing that regularly :p
  nonMergeableList = t: (types.nonEmptyListOf t) // {
    merge = lib.options.mergeEqualOption;
  };

  # either a flat list like ["<Ctrl>" "C"], or a nested list of
  # different possible keybindings [ ["<Ctrl>" "C"] ["<Super>" "C"] ]
  keybindingsType = with types;
    let singleKeybind = if _check then nonMergeableList keysType else str; in
    if multiKeybindings then
      # in case we support multiple keybindings, we need to transform
      # single keybinds into a singleton list, so that we support
      # merging multiple declarations correctly
      coercedTo
        singleKeybind
        (val: [val])
        # this list *is* mergeable because it's fine if
        # there's multiple definitions for a single action,
        # since this supports multiple keybindings
        (nonEmptyListOf singleKeybind)
    else
      singleKeybind;
in keybindingsType
