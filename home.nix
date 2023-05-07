{ config, pkgs, lib, myVimPlugins, ... }:
let 
  buildVimPlugin = {name, src}: pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = name;
    version = "unstable";
    inherit src;
  };
in {
  home = {
    username = "anthony";
    homeDirectory = "/home/anthony";
    stateVersion = "22.11";
  };
  programs = {
    git = {
      enable = true;
      userName = "anthonymarkreynolds";
      userEmail = "anthonymarkreynolds@outlook.com";
    };
    neovim = {
      enable = true;
      defaultEditor = true;
      plugins = with pkgs.vimPlugins; [
        { 
	  plugin = nvim-treesitter.withAllGrammars;
	  type = "lua";
	  config = builtins.readFile ./lua/treesitter.lua; 
        }
       ] ++ (lib.attrsets.mapAttrsToList (name: value: { plugin = buildVimPlugin { inherit name; src = value; }; type = "lua"; config = builtins.readFile ./lua/${name}.lua; }) myVimPlugins);
          # (map (plugin: { plugin = buildPlugin plugin; type = "lua"; config = builtins.readFile ./lua/${plugin.name}.lua; }) myVimPlugins);
    };
    alacritty = {
      enable = true;
      settings = {
        colors = {
	  primary = {
	    background = "#17101d";
	  };
	};
        window = {
          padding.x = 8;
          padding.y = 8;
          dynamic_padding = true;
        };
      };
    };
  };
}
