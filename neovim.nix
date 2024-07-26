{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    (lua5_1.withPackages(
			 ps: with ps; [
			 busted
			 luafilesystem
			 luarocks
			 lua-utils-nvim
			 pathlib-nvim
			 ]))
  ];

  programs.nixvim = {
    enable=true;

    globals.mapleader="\\";
    colorschemes.base16 = {
      enable = true;
      colorscheme = "atelier-dune";
    };

    plugins = {
      sleuth.enable = true;
      bufferline.enable = true;
      telescope.enable = true;
      fugitive.enable = true;
      lightline.enable = true;
      gitgutter.enable = true;
      neorg = {
      	enable = true;
	modules = {
	  "core.defaults" = { __empty = null;};
	  "core.concealer" = { __empty = null;};
	  "core.dirman" = {
	    config = {
	      workspaces = {
	        notes = "~/notes";
	      };
	      default_workspace = "notes";
	    };
	  };
	};
      };
      treesitter = {
        enable = true;
      };
    };
    extraLuaPackages = pkgs: with pkgs.luaPackages; [
      busted
      luarocks
      lua-utils-nvim
      nvim-nio
      pathlib-nvim
    ];
  };
}
