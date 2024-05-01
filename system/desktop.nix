{ pkgs, user, ... }: {
  programs = { dconf.enable = true; };

  environment = {
    systemPackages = with pkgs; [
      pulsemixer
      playerctl
      pamixer
      bc
      mediainfo
      mpv
      tgpt
      btop
      yt-dlp
      ytfzf
      calcurse
      gparted
      cinnamon.nemo
      unzip
      fzf
      wget
      ncdu
      ani-cli

      gcc

      dwmblocks
      st
      xsel
      xclip
      xwallpaper
      maim
      xcompmgr
      nsxiv
      xdotool
      haskellPackages.greenclip
    ];
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal ];
    config.common.default = "*";
  };

  hardware.pulseaudio.enable = false;
  services = {
    dbus.packages = [ pkgs.gcr ];
    getty.autologinUser = "${user}";
    gvfs.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    xserver = {
      enable = true;
      dpi = 96;
      displayManager.startx.enable = true;
      videoDrivers = [ "amdgpu" ];
      deviceSection = ''Option "TearFree" "true"'';
    };
  };

  services.xserver.windowManager.dwm.enable = true;
  programs.zsh.loginShellInit = ''
    if [[ "$(tty)" == "/dev/tty1" ]] then
      startx
    fi
  '';
  services.xserver.windowManager.dwm.package = pkgs.dwm.overrideAttrs (old: {
    src = pkgs.fetchFromGitHub {
      owner = "xenoxanite";
      repo = "dwm";
      rev = "6914b4ca50a2b693ce95e1075d67cfc11f663236";
      hash = "sha256-0PyEb1SYMbql/VTtR+pco1dTZ9EbLQEz0DvA/krUeVE=";
    };
    buildInputs = (old.buildInputs or [ ]) ++ [ pkgs.imlib2 ];
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.pkg-config ];
  });

  nixpkgs.overlays = [
    (final: prev: {
      st = prev.st.overrideAttrs (old: {
        src = pkgs.fetchFromGitHub {
          owner = "xenoxanite";
          repo = "st";
          rev = "16667e610c31f35bcfbfa30a9cb4368f85d3cae7";
          hash = "sha256-5XBo4hZBwfiB6vWVn4xPEiWV75K89Azp3g88P0peorY=";
        };
        buildInputs = with pkgs;
          (old.buildInputs or [ ])
          ++ [ pkg-config xorg.libX11 xorg.libXft fontconfig harfbuzz gd glib ];
        nativeBuildInputs = (old.nativeBuildInputs or [ ])
          ++ [ pkgs.pkg-config ];
      });
      dwmblocks = prev.dwmblocks.overrideAttrs (old: {
        src = pkgs.fetchFromGitHub {
          owner = "xenoxanite";
          repo = "dwmblocks";
          rev = "aafc100aa447387aea6aef1776b878d7e6246344";
          hash = "sha256-wcSh1vKHViAU3Ve0yTLRCcTwO85N6Po4G83K+eSR3iY=";
        };
        buildInputs = old.buildInputs or [ ];
        nativeBuildInputs = (old.nativeBuildInputs or [ ])
          ++ [ pkgs.pkg-config ];
      });
    })
  ];

  security.rtkit.enable = true;

  i18n.inputMethod = {
    enabled = "ibus";
    ibus.engines = with pkgs.ibus-engines; [ openbangla-keyboard ];
  };

  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart =
          "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };

}
