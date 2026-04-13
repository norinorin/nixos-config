{
  description = "NixOS config";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixcord.url = "github:kaylorben/nixcord";
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    split-monitor-workspaces = {
      url = "github:Duckonaut/split-monitor-workspaces";
      inputs.hyprland.follows = "hyprland";
    };
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    anime_rpc.url = "github:norinorin/anime_rpc";
    niri.url = "github:sodiboo/niri-flake";
    niri-blur = {
      url = "github:YaLTeR/niri/8cc8756bea3987c6bf13a3693a5c4acbfa896c34";
      flake = false;
    };
    niri.inputs.niri-unstable.follows = "niri-blur";
    silentSDDM = {
      url = "github:uiriansan/SilentSDDM";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wayland-pipewire-idle-inhibit.url = "github:rafaelrc7/wayland-pipewire-idle-inhibit";
    nix-gaming.url = "github:fufexan/nix-gaming";
    helix-discord-rpc = {
      url = "github:norinorin/helix-discord-rpc";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs @ {
    self,
    nixpkgs,
    ...
  }: {
    nixosConfigurations = {
      toaster = let
        username = "nori";
        displayManager = "ly";
        specialArgs = {inherit inputs username displayManager;};
      in
        nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = [./nixos];
        };
    };
  };
}
