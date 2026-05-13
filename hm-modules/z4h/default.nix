{ config, lib, options, pkgs, ... }:
let
  inherit (lib.types)
    attrsOf
    bool
    coercedTo
    either
    enum
    int
    listOf
    nonEmptyListOf
    nonEmptyStr
    nullOr
    oneOf
    package
    path
    str
    submodule;

  inherit (lib.options) mkEnableOption mkOption literalExpression literalMD;

  # fixme: we should probably patch it so that it never tries to write
  # stuff to $Z4H/**/*, since that will be read-only
  # (e.g. it sometimes writes to $Z4H/cache or $Z4H/tmp)
  # fixme: also we need to patch any attempt to read stuff from PATH
  defaultPkg = pkgs.fetchFromGitHub {
    owner = "romkatv";
    repo = "zsh4humans";
    rev = "cd6c4770c802c3a17b4c43e5587adabb9a370a75";
    hash = "sha256-OMpcDS8S6OTVe7sC4iQ3LMpwNx2tcCBGBnORwL3ix6w=";
  };

  cmdType = nonEmptyListOf str;
  flagsType = nonEmptyListOf str;

  # allows either
  #   { a = "foo"; }
  # or
  #   { a.b.c.d = "foo"; }
  optionType =
    let
      leafType = oneOf [
        str
        int
        bool
      ];
    in
      attrsOf (either leafType optionType);

  cfg = config.programs.zsh.zsh4humans;
in {
  options = {
    programs.zsh.zsh4humans = {
      enable = mkEnableOption "zsh4humans, a turnkey configuration for zsh";
      package = mkOption {
        type = package;
        default = defaultPkg;
        description = ''
          The package to use as the zsh4humans files.
        '';
      };

      settings = {
        # (this is actually :z4h:bindkey keyboard)
        keyboard = {
          type = mkOption {
            type = enum [ "pc" "mac" ];
            # default = if targets.genericLinux.enable then "pc" else undefined
            description = ''
              Whether your keyboard is a standard PC keyboard or a Mac keyboard.
              This will affect the default keybinding.
            '';
          };

          macos-option-as-alt = mkOption {
            type = bool;
            default = true;
            description = ''
              Whether the mac keyboard's Option key should be equivalent to Alt when using 'z4h bindkey'.
            '';
          };
        };

        check-orphan-rc-zwc = mkOption {
          type = bool;
          default = true;
          description = ''
            Whether to check ZDOTDIR for compiled `.zwc` files that do not have a corresponding source file.
          '';
        };

        docker = {
          term = mkOption {
            type = nullOr nonEmptyStr;
            default = null;
            defaultText = "The value of the '$TERM' environment variable at runtime";
            description = ''
              The terminal to use when launching a 'docker' command.
            '';
          };
        };

        ssh = mkOption {
          description = ''
            Settings related to SSH teleportation, which automatically sets up z4h on any remote machine you ssh into.
            Options can be configured on a per host basis, and universal options are configured with the "*" host.
          '';
          example = {
            "*" = {
              enable = true;
              send-extra-files = [ "~/.nanorc" ];
            };
            builder.enable = false;
          };
          type = attrsOf (submodule {
            options = {
              enable = mkEnableOption ''
                SSH teleportation, which automatically sets up z4h on any remote machine you ssh into.
                Note that this might not work properly if .zshrc references files in the Nix store, unless you add them (and any of their dependencies) to {option}`programs.zsh.z4h.ssh.<name>.send-extra-files`.
              '';

              send-extra-files = mkOption {
                type = listOf nonEmptyStr;
                default = [];
                description = ''
                  Extra files to send over when teleporting.
                '';
              };

              retrieve-extra-files = mkOption {
                type = listOf nonEmptyStr;
                default = [];
                description = ''
                  Remote files to retrieve after teleportation.
                  Note that you cannot copy entire directories like this; you have to only specify files.
                '';
              };

              retrieve-history = mkOption {
                type = coercedTo nonEmptyStr (s: [s]) (listOf nonEmptyStr);
                default = [];
              };

              ssh-command = mkOption {
                type = nullOr cmdType;
                # we don't actually set the default because z4h adds some special
                # arguments to ssh when :z4h:ssh:*:ssh-command is not set
                default = null;
                defaultText = "[ \"command\" \"ssh\" ]";
                example = [ "ssh" "-C" ];
                description = ''
                  The actual command to use when running 'ssh' or 'z4h ssh'.
                '';
              };

              term = mkOption {
                type = nullOr nonEmptyStr;
                default = null;
                defaultText = "The value of the '$TERM' environment variable at runtime";
                description = ''
                  The terminal to use when running 'ssh' or 'z4h ssh'.
                '';
              };
            };
          });
        };

        sudo = {
          term = mkOption {
            type = nullOr nonEmptyStr;
            default = null;
            defaultText = "The value of the '$TERM' environment variable at runtime";
            description = ''
              The terminal to use when launching a 'sudo' command.
            '';
          };
        };

        command-not-found = {
          to-file = mkOption {
            type = nullOr path;
            default = null;
          };
        };

        completion = mkOption {
          description = ''
            Settings related to completion widgets, such as 'fzf-complete'.
            You can also affect all widgets by using '*' as the widget name.
          '';
          example = {
            "*".recurse-dirs = false;
            fzf-complete = {
              fzf-bindings = "tab:repeat";
            };
          };
          type = attrsOf (submodule {
            options = {
              recurse-dirs = mkOption {
                type = bool;
                default = false;
                description = ''
                  Whether to recurse into sub-folders when completing a path/filename
                '';
              };

              find-command = mkOption {
                type = nullOr cmdType;
                default = null;
                defaultText = "bfs if it's in PATH, otherwise find";
                example = literalExpression "\${lib.getExe pkgs.bfs}";
              };

              find-flags = mkOption {
                type = listOf str;
                # defaults from the z4h script `-z4h-find` when find-flags isn't defined
                default = ["-name" "'.*'" "-prune" "-print" "-o" "-print"];
                description = ''
                  The flags to pass to the {option}`programs.zsh.z4h.settings.completion.<name>.find-command` command.
                '';
              };
            };
          });
        };

        # note: we should also do `alias clear=z4h-clear-screen-soft-bottom` as recommended by the docs (tips.md)
        prompt-at-bottom = mkOption {
          type = bool;
          default = false;
          description = ''
            This forces the prompt to always be at the bottom of the screen when zsh starts (or after pressing Ctrl+L to clear the screen).
            Having prompt always in the same location allows you to find it quicker and to position your terminal window so that looking at prompt is most comfortable.
          '';
        };

        compinit = {
          dump-path = mkOption {
            type = nullOr path;
            default = null;
            defaultText = "$Z4H/cache/zcompdump-$EUID-$ZSH_VERSION";
          };
        };

        direnv = {
          enable = mkEnableOption "direnv to automatically source .envrc files";

          #package = ... # it auto-downloads a direnv into $Z4H/cache and/or uses one from PATH :(

          success.notify = mkOption {
            type = bool;
            default = true;
            description = ''
              Show 'loading' and 'unloading' notifications from direnv.
            '';
          };
          error.notify = mkOption {
            type = bool;
            default = true;
            description = ''
              Show 'loading' and 'unloading' notifications from direnv.
            '';
          };
        };

        fzf =
          let
            mod = {
              fzf-command = mkOption {
                type = nullOr cmdType;
                default = lib.getExe pkgs.fzf;
                defaultText = "lib.getExe pkgs.fzf";
                description = ''
                  The executable or command to use when running fzf-based widgets.
                '';
              };

              fzf-flags = mkOption {
                type = listOf str;
                default = [];
                description = ''
                  The default flags to invoke fzf with when running fzf-based widgets.
                '';
              };

              fzf-bindings = mkOption {
                type = listOf nonEmptyStr;
                default = [];
                description = ''
                  Additional keybindings to pass to fzf when running fzf-based widgets.
                '';
              };
            };
          in {
            complete = mod;
            history = mod;
            dir-history = mod;
          };

        ssh-agent = {
          enable = mkEnableOption "automatically starting the ssh-agent";
          extra-args = mkOption {
            type = flagsType;
            default = [];
            description = ''
              Additional options to pass to ssh-agent.
            '';
          };
        };

        # options in here are actually `:z4h:term-<optname> foo`
        terminal = {
          # note: this also implies ':z4h: item2-integration'
          shell-integration = mkEnableOption "shell integration with terminal emulators that understand OSC 133 (such as kitty and iTerm2), and, if integrated tmux is enabled, fixes the horrible p10k mess after resizing a window";
          vresize = mkOption {
            type = nullOr enum [ "top" ];
            default = null;
            description = ''
              If vertically resizing the terminal window breaks scrollback, set this option to `top`.
            '';
          };
          title = mkOption {
            description = ''
              Control the terminal title for either 'local' or 'ssh' sessions (or both, with '*').
            '';
            default = {
              local = {
                preexec = "\${1//\\%/%%}";
                precmd  = "%~";
              };
              ssh = {
                preexec = "%n@%m: \${1//\\%/%%}";
                precmd  = "%n@%m: %~";
              };
            };
            type = attrsOf (submodule {
              options = {
                preexec = mkOption {
                  type = str;
                  example = "%* [%n@%M]: \${1//\\%/%%}";
                  description = ''
                    The expression to set the terminal title to while executing a command.
                    The expression undergoes zsh prompt expansion (cf {man}`zshmisc(1)`, section "Expansion of Prompt Sequences).
                    This also means that, if you use variable expansion, extra care should be taken to escape any '%' characters from the resulting value.

                    Note: instead of using '%m' to get the machine/host name, you can use `''${''${''${Z4H_SSH##*:}//\%/%%}:-%m}` to get the hostname as typed on the command line rather than the one reported by the remote machine.

                    Notes about `preexec`:
                      - since this is only executed when the command starts and not updated afterwards, time-related sequences such as `%*` will allow you to see the time the command started.
                      - the executed command is passed to the prompt in three forms:
                        - `$1` contains the command as typed directly, with no expansion performed
                        - `$2` contains almost the full command (including expanded aliases) as a single line, but with things such as inline function bodies elided.
                        - `$3` contains the full text that is being executed, after all expansion has been done.
                  '';
                };

                precmd = mkOption {
                  type = str;
                  example = "%n @ %M";
                  description = ''
                    The expression to set the terminal title to after finishing a command and before showing a prompt.
                    The expression undergoes zsh prompt expansion (cf {man}`zshmisc(1)`, section "Expansion of Prompt Sequences).
                    This also means that, if you use variable expansion, extra care should be taken to escape any '%' characters from the resulting value.

                    Note: instead of using '%m' to get the machine/host name, you can use `''${''${''${Z4H_SSH##*:}//\%/%%}:-%m}` to get the hostname as typed on the command line rather than the one reported by the remote machine.
                  '';
                };
              };
            });
          };
        };

        autosuggestions = {
          forward-char = mkOption {
            type = enum [ "accept" "partial-accept" ];
            default = "accept";
            description = ''
              Whether the right-arrow key should accept either one character (`partial-accept`) from autosuggestions, or the whole thing (`accept`)?
            '';
          };

          end-of-line = mkOption {
            type = enum [ "accept" "partial-accept" ];
            default = "accept";
            description = ''
              Whether the right-arrow key should accept either one character (`partial-accept`) from autosuggestions, or the whole thing (`accept`)?
            '';
          };
        };

        dir-history = {
          cwd = mkOption {
            type = nullOr str;
            default = null;
          };

          max-size = mkOption {
            type = int;
            default = 10000;
            description = ''
              The maximum number of folders to keep in the dirstack before discarding old ones.
            '';
          };
        };

        history = {
          preserve-trailing-whitespace = mkOption {
            type = bool;
            default = false;
          };
        };

        bracketed-paste-magic = {
          # todo: fn/bracketed-paste-magic
        };

        chsh = mkEnableOption "automatically changing the user's default shell to zsh on startup" // {
          default = true;
        };

        start-tmux = mkOption {
          type = either
            (enum [ "integrated" "isolated" "system" false "no" ])
            cmdType;
          default = "integrated";
          description = ''
            How (and whether or not) to start tmux on each new zsh session, to help z4h determine terminal content/size and other stuff for better integration.
          '';
        };

        propagate-cwd = mkOption {
          type = bool;
          default = false;
          description = ''
            If your terminal emulator has a feature that allows opening a new tab/window in the same directory as the current tab, and it doesn't work, turn this on.
          '';
        };

        extraConfig = mkOption {
          type = optionType;
          #default = ...; # default is set in config so it has normal priority and merging
          example = literalMD ''
            As an equivalent to `zstyle :z4h:my-category foo <val>`, use:
            {
              my-category.foo = <val>;
            }
          '';
        };
      };
    };
  };

  config = {
    assertions = [
      {
        assertion = cfg.settings.prompt-at-bottom -> (cfg.settings.start-tmux != "no");
        message = "The z4h option `prompt-at-bottom` has no effect if `start-tmux` is disabled, but it is currently set to true";
      }

      # make sure that `programs.zsh.z4h.terminal.title` only has `local.foo`, `ssh.foo`, or `*.foo`, and nothing else
      (let
        isValid = shellType: builtins.elem shellType ["local" "ssh" "*"];
        shells = builtins.attrNames cfg.settings.terminal.title;

        # collect all definitions that are not valid
        badDefs =
          builtins.filter
            (x: !(isValid x))
            options.programs.zsh.z4h.terminal.title.definitionsWithLocations;
      in {
        assertion = builtins.all isValid shells;
        message =
          "The z4h option `terminal.title` can only be set for either `local` or `ssh` shell types, but some were not: ${
            lib.options.showDefs badDefs
          }";
      })
    ];

    programs.zsh.zsh4humans = {
      settings = {
        # note: we want normal merging and priority for this, so no 'mkDefault' or 'mkOptionDefault' or w/e
        extraConfig = lib.mkMerge [
          # make sure updates are disabled
          { auto-update = false; }

          # make sure z4h doesn't try to auto-download a bunch of stuff
          # fixme: set _z4h_use[pkg]=1 manually (because otherwise those tools are not used when :z4h:pkg:channel=none)
          # note: when installing one of:
          #   - ohmyzsh/ohmyzsh
          #   - MichaelAquilina/zsh-you-should-use
          #   - wfxr/forgit
          #   - changyuheng/fz
          #   - zsh-users/(zsh-syntax-highlighting|zsh-autosuggestions|zsh-history-substring-search)
          # z4h actually has special "postinstall" functions
          # todo: look into what they do and whether we have to (and can) reproduce it
          (
            lib.genAttrs
              ["fzf" "powerlevel10k" "systemd" "zsh-history-substring-search" "zsh-completions" "zsh-autosuggestions" "zsh-syntax-highlighting"]
              (name: { channel = "none"; })
          )
        ];
      };
    };
  };
}
