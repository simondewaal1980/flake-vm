# Edit tjhis configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
   nix.settings = {
experimental-features = [ "nix-command" "flakes" ];
};
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.cudaSupport = true;
#Disable powermanagment
systemd.sleep.extraConfig = ''
  AllowSuspend=no
  AllowHibernation=no
  AllowHybridSleep=no
  AllowSuspendThenHibernate=no
'';
#Fstab
fileSystems = {
"/".options = [ "compress=zstd" ];
  "/home".options = [ "compress=zstd" ];
  "/nix".options = [ "compress=zstd" "noatime" ];
};
#Zram swap
zramSwap.enable = true;


#Clean
nix.gc = {
       automatic = true;
     dates = "daily";
     options = "--delete-older-than 2d";
   };
#autoupdate
system.autoUpgrade = {
  enable = true;
  flake = "/home/simon/flake"; 
  flags = [
    "--update-input"
    "nixpkgs"
    "-L" # print build logs
  ];
  dates = "14:00";
  randomizedDelaySec = "45min";
};
#auto optimise Nix store
nix.settings.auto-optimise-store = true;
#aliassen
environment.shellAliases ={
ls = "ls -la";
flakeupd ="nix flake update /home/simon/flake"; 
 sysupgr = "sudo nixos-rebuild --flake home/simon/flake boot";
 sysswitch = "sudo nixos-rebuild --flake home/simon/flake switch";  
  
sysconfig = "sudo nano $HOME/flake/configuration.nix";
 sysclean  = "sudo nix-collect-garbage -d";
 listgen = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";

};
#CUDA cache 
nix.settings.substituters = [ "https://cuda-maintainers.cachix.org" ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

   networking.hostName = "nixos"; # Define your hostname.
networking.interfaces.enp4s0.wakeOnLan.enable = true;
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
   networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
   time.timeZone = "Europe/Amsterdam";
#via
  services.udev.packages = [ pkgs.via ];
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
   i18n.defaultLocale = "nl_NL.UTF-8";
   console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
     useXkbConfig = true; # use xkb.options in tty.
   };

  # Enable the X11 windowing system.
  services.xserver.videoDrivers = [ "nvidia" ];  
  hardware.graphics.enable = true;
  hardware.nvidia-container-toolkit.enable = true;
  hardware.nvidia.open = true;
  hardware.nvidia.modesetting.enable = true;
  hardware.graphics.extraPackages = with pkgs; [nvidia-vaapi-driver];
services.xserver.enable = true;
programs.appimage.enable = true;
programs.appimage.binfmt = true;
 services.flatpak.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
programs.steam.enable = true;

  # Configure keymap in X11
   services.xserver.xkb.layout = "us";
   services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
   services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
   services.pipewire = {
     enable = true;
     pulse.enable = true;
   };

   hardware.bluetooth.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
   users.users.simon = {
     isNormalUser = true;
     extraGroups = [ "wheel" "docker" "podman" "libvirtd"  ]; # Enable ‘sudo’ for the user.
     packages = with pkgs; [
       tree
       spotify  
   ];
   };
#cuda
  environment.variables = {
    CUDA_HOME = pkgs.cudatoolkit;
  };
#Distrobox
virtualisation.podman = {
  enable = true;
 # dockerCompat = true;
};
virtualisation.docker = {
enable = true;
};
   programs.firefox.enable = true;

#virtmanager
virtualisation.libvirtd.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
   environment.systemPackages = with pkgs; [
     vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
     wget
     google-chrome
     jre8
     git 
     libreoffice-fresh
    distrobox       
    linuxPackages.nvidia_x11
cudaPackages.cudatoolkit
    nvidia-container-toolkit
    nvidia-docker
    docker    
    fuse
    appimage-run
    SDL
    SDL2
    sdl3
    dotnetCorePackages.sdk_9_0_1xx-bin   
   python312Full
   via
   vlc
  virt-manager
  fastfetch
 edk2 
 dotnet-runtime
 icu
  dotnet-aspnetcore
  vscode-fhs
  github-desktop 
 ];

fonts.packages = with pkgs; [
 noto-fonts
 noto-fonts-cjk-sans
 noto-fonts-emoji
 liberation_ttf
 fira-code
 fira-code-symbols
 mplus-outline-fonts.githubRelease
 dina-font
 proggyfonts
 corefonts
# nerdfonts
 vistafonts
];
#Bashrc
programs.bash.interactiveShellInit ="fastfetch" ;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  programs.ssh.forwardX11 = true;
  services.openssh.settings.X11Forwarding = true;

  #system.autoUpgrade.enable = true;

  # Open ports in the firewall.
  networking.firewall.enable = false; 
 # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?

}

