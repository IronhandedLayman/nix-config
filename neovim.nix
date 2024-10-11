{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    (lua5_1.withPackages(
			 ps: with ps; [
#			 busted
			 luafilesystem
			 luarocks
			 lua-utils-nvim
			 pathlib-nvim
			 ]))
  ];
  
  programs.nixvim = {
    enable=true;

    globals = {
      mapleader = "\ ";
      maplocalleader = "\ ";
    };

    globalOpts = {
      number = true;
      tabstop = 4;
      shiftwidth = 4;
      softtabstop = 0;
    };
    colorschemes.base16 = {
      enable = true;
      colorscheme = "atelier-dune";
    };

    plugins = {
      web-devicons.enable = true;
      sleuth.enable = true;
      bufferline.enable = true;
      telescope = {
        enable = true;
	keymaps = {
	  "<leader>fg" = "live_grep";
	  "<C-p>" = {
	    action = "git-files";
	    options = {
	      desc = "Telescope git_files";
	    };
	  };
	  "<leader>fb" = "buffers";
	  "<leader>fh" = "help_tags";
	};
	extensions = {
	  fzf-native.enable = true;
	};
      };
      fugitive.enable = true;
      neogit.enable = true;
      lualine.enable = true;
      gitsigns.enable = true;
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
#      busted
      luarocks
      lua-utils-nvim
      nvim-nio
      pathlib-nvim
    ];
  };
}
