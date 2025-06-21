########################################################################
###								     ###
###                  	  	NIX OS				     ###
###								     ###
########################################################################

{ config, pkgs, lib, quickshell, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./cosmic.nix
#      <home-manager/nixos>
    ];



#####################
###    System     ###
#####################

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  networking.hostName = "nixos"; # Define your hostname.

  # Bootloader.
  boot.loader ={
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      gfxmodeEfi = "1920x1080";
      default = "0";
      # extraEntriesBeforeNixOS = true;
      extraEntries = ''
        menuentry "Windows" {
         search --file --no-floppy --set=root /EFI/Microsoft/Boot/bootmgfw.efi
         chainloader (''${root})/EFI/Microsoft/Boot/bootmgfw.efi
        }
        menuentry "Firmware" {
         fwsetup
        }
        menuentry "Shutdown" {
         halt
        }
      '';
      # theme = pkgs.fetchzip {
      # https://github.com/AdisonCavani/distro-grub-themes
      #   url = "https://raw.githubusercontent.com/AdisonCavani/distro-grub-themes/master/themes/freeBSD.tar";
      #   hash = "sha256-oTrh+5g73y/AXSR+MPz6a25KyCKCPLL8mZCDup/ENZc=";
      #   stripRoot=false;
      # };
    };
  };

  # Nvidia Drivers
  hardware.nvidia = {
    package = pkgs.linuxPackages.nvidiaPackages.stable;
    modesetting.enable = true;
    open = false;
#   persistenced = true;
#   opengl.enable = true;
  };
  
  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };



#####################
###    Desktop    ###
#####################

  # Also see cosmic flake
  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = false;

  #KDE Plasma
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  xdg.portal.enable = true;  
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  xdg.portal.config.common.default = [ "gtk" ];
 
  # Hyprland
  programs.hyprland.enable = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  services.xserver={
   enable = true;
   #displayManager.gdm.enable = true;
   #desktopManager.gnome.enable = true;
   videoDrivers = ["nvidia"];
  };   

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "euro";
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;



##################
###    User    ###
##################

  # Define a user account
  users.users.rawden = {
    isNormalUser = true;
    description = "rawden";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
    packages = with pkgs; [
       zsh
    ];
  };


#  home-manager.users.rawden = { pkgs, ... }: {
#  home.packages = [  ];
#  };


#################################
###    Conectivity & sound    ###
#################################

  # Enable networking
  networking.networkmanager.enable = true;
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

    
  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;



#####################
###   Packages    ###
#####################

  # Ollama AI framework
  services.ollama = {
    enable = true;
    # Optional: preload models, see https://ollama.com/library
    loadModels = [ "llama3.2:3b" "dolphin-mistral:7b" ];
  };

  # Open web ui for ollama
  services.open-webui.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;
  
  # Enable flatpak for apps
  services.flatpak.enable = true;

  # Install firefox
  programs.firefox.enable = true;

  # Install KDE connect
  programs.kdeconnect.enable = true;

  # Gnome themeing
  programs.dconf.enable = true;

  # Thunar file manager and its needed preference manager
  programs.thunar.enable = true;
  programs.xfconf.enable = true;

  # Dunst Hyprland notifications
#  dunst = {
#    enable = true;
#  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Allow runing of exectutables
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [

#    gobject
#    fuse

  ];
  
  # QEMU & VM support
  virtualisation.libvirtd = {
  enable = true;
  qemu = {
    package = pkgs.qemu_kvm;
    runAsRoot = true;
    swtpm.enable = true;
    ovmf = {
      enable = true;
      packages = [(pkgs.OVMF.override {
        secureBoot = true;
        tpmSupport = true;
      }).fd];
    };
  };
};


  environment.systemPackages = with pkgs; [

  # CLI 
  vim
  neovim
  wget
  fastfetch
  neofetch
  git
  btop
  appimage-run
  (appimage-run.override {
      extraPkgs = pkgs: [ pkgs.xorg.libxshmfence pkgs.xorg.libXau pkgs.xorg.libXmu];
  })
  libimobiledevice
  ifuse
  cava
  cmatrix
  android-studio-tools
  python3
  rustc
  cargo
  cmake
  ninja
  android-tools
  unzip
  ranger
  smartmontools
  jdk
  qemu
  
  # System
  home-manager
  waybar
  wlogout
  hyprpaper
  wofi
  alacritty
  dunst
  quickshell.packages.x86_64-linux.default
  #Zsh
  oh-my-zsh
  zsh
  zsh-completions
  zsh-powerlevel10k
  zsh-syntax-highlighting
  zsh-history-substring-search
  #Plasma
  kdePackages.discover
  kdePackages.kcalc
  kdePackages.kcharselect
  kdePackages.kcolorchooser
  kdePackages.ksystemlog
  kdePackages.sddm-kcm
  kdiff3
  kdePackages.isoimagewriter
  kdePackages.partitionmanager
  hardinfo2
  haruna
  wayland-utils
  wl-clipboard
 
  # GUI
  discord-ptb
  electron
  spotify
  android-studio
  gnome-tweaks
  chromium
  linssid  

  curl
  jq
  fd
  fish
  ddcutil
  brightnessctl
  imagemagick
  spicy
  qt6Packages.qtwayland
  qt5.full
  qt6.full
  pkgs.qt6.qt5compat
#  qt6Packages.qtapplicationmanager
  #qt6Packages.qt6-wayland-layer-shell
  
  ];
  
  # Remove KDE bloat
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    #plasma-browser-integration # Comment out this line if you use KDE Connect
    kdepim-runtime # Unneeded if you use Thunderbird, etc.
    konsole # Comment out this line if you use KDE's default terminal app
    oxygen
  ];
  
  # Fonts
  fonts.packages = with pkgs; [
   noto-fonts
   noto-fonts-cjk-sans
   noto-fonts-emoji
   liberation_ttf
   nerd-fonts.fira-code
   fira-code
   fira-code-symbols
   mplus-outline-fonts.githubRelease
   dina-font
   proggyfonts
#   fonts-ibm-plex 
 ];

#  fontconfig = {
#    enable = true;
#  };



#############################
###    Version & other    ###
#############################

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  
  system.stateVersion = "24.11"; # WIP

}
