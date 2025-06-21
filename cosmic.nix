###############################
###    Cosmic for Nix OS    ###
###############################

{ config, pkgs, ... }:

{
  # Enable Cosmic Desktop
  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = false;

  environment.sessionVariables.COSMIC_DATA_CONTROL_ENABLED = 1;
  services.geoclue2.enable = true;

  # Cosmic System packages
  environment.systemPackages = with pkgs; [
    chronos
    cosmic-applets
    cosmic-edit
    cosmic-ext-calculator
    cosmic-ext-forecast    
    cosmic-ext-tasks
    cosmic-ext-tweaks
    cosmic-reader
    cosmic-screenshot
    quick-webapps
  ];

}
