{
  description = "Home Manager configuration of Jane Doe";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      pluginList = import ./plugin-list.nix;
      #myVimPlugins = builtins.listToAttrs (map (plugin: { name = plugin.name; value = { url = plugin.url; flake = false; }; }) pluginList);
      fetchPlugin = plugin: {
        name = plugin.name;
        value = builtins.fetchTarball {
          url = plugin.url;
          sha256 = plugin.sha256;
        };
      };

      myVimPlugins = builtins.listToAttrs (map fetchPlugin pluginList);

    in {
      homeConfigurations.anthony = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [ ./home.nix ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
	# extraSpecialArgs =  builtins.listToAttrs (map (plugin: { name = plugin.name; value = pluginInputs.${plugin.name}; }) pluginList);
    
	extraSpecialArgs = {
	  myVimPlugins = myVimPlugins;
	};
      };
      packages.x86_64-linux.update-plugins = import ./update-plugins.nix { inherit pkgs; };
    } // myVimPlugins;
}
