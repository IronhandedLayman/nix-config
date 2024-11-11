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
      mapleader = " ";
      maplocalleader = " ";
      signcolumn = "yes";
      fileencoding="utf-8";
    };

    opts = {
      number = true;
      tabstop = 4;
      shiftwidth = 4;
      softtabstop = 0;
      expandtab = true;
      smarttab = true;
      termguicolors = true;
      ignorecase = true;
      smartcase = true;
      foldlevel = 99;
    };

    colorschemes.base16 = {
      enable = true;
      colorscheme = "atelier-dune";
    };

    plugins = {
      bufferline.enable = true;
      sleuth.enable = true;
      web-devicons.enable = true;
      fugitive.enable = true;
      neogit.enable = true;
      lualine.enable = true;
      gitsigns.enable = true;

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
      nix.enable = true;
      treesitter = {
        enable = true;
      };
      cmp = {
        enable = true;
	autoEnableSources = true;
	settings = {
	  sources = [
	    { name = "nvim_lsp";}
	    { name = "path";}
	    { name = "buffer";}
	    { name = "luasnip";}
	    { name = "cmp-emoji";}
	  ];
	# mapping settings taken liberally from https://github.com/MikaelFangel/nixvim-config/blob/mian/config/cmp.nix
	  mapping = {
	    "<C-j>" = "cmp.mapping.select_next_item()";
	    "<C-k>" = "cmp.mapping.select_prev_item()";
	    "<C-d>" = "cmp.mapping.scroll_docs(4)";
	    "<C-f>" = "cmp.mapping.scroll_docs(-4)";
	    "<C-Space>" = "cmp.mapping.complete()";
	    "<S-Tab>" = "cmp.mapping.close()";
	    "<Tab>" = 
	      # lua
	      ''
		function(fallback)
		  local line = vim.api.nvim_get_current_line()
		  if line:match("^%s*$") then
		    fallback()
		  elseif cmp.visible() then
		    cmp.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true })
		  else
		    fallback()
		  end
		end
	      '';
	    "<Down>" = 
	      # lua
	      ''
		function(fallback)
		  if cmp.visible() then
		    cmp.select_next_item()
		  elseif require("luasnip").expand_or_jumpable() then
		    vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-expand-or-jump", true, true, true), "") 
		  else
		    fallback()
		  end
		end
	      '';
	    "<Up>" = 
	      # lua
	      ''
		function(fallback)
		  if cmp.visible() then
		    cmp.select_next_item()
		  elseif require("luasnip").jumpable(-1) then
		    vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-expand-or-jump", true, true, true), "") 
		  else
		    fallback()
		  end
		end
	      '';
	    };
	  };
	};
	lsp = {
	  enable = true;

	  keymaps = {
	    silent = true;
	    diagnostic = {
	      "<leader>k" = "goto_prev";
	      "<leader>j" = "goto_next";
	    };

	    lspBuf = {
	      gd = "definitions";
	      gD = "references";
	      gT = "type_definition";
	      gi = "implementation";
	      K = "hover";
	      "<F2>" = "rename";
	    };
	  };

	  servers = {
	    gopls.enable = true;
	    nixd.enable = true;
	    lua_ls.enable = true;
	    texlab.enable = true;
	    pylsp = {
	      enable = true;
	      settings.plugins = {
	        pylint.enabled = true;
		pylsp_mypy.enable = true;
	      };
	    };
	    ruff.enable = true;
	    dockerls.enable = true;
	  };
	};

	none-ls = {
	  enable = true;
	  sources = {
	    diagnostics = {
	      statix.enable = true;
	      deadnix.enable = true;
	      pylint.enable = true;
	    };
	    formatting = {
	      alejandra.enable = true;
	      black.enable = true;
	      stylua.enable = true;
              nixpkgs_fmt.enable = true;
	    };
	    completion = {
	      luasnip.enable = true;
	      spell.enable = true;
	    };
	  };
	};
      };
      extraLuaPackages = pkgs: with pkgs.luaPackages; [
#       busted
        luarocks
        lua-utils-nvim
        nvim-nio
        pathlib-nvim
      ];
    };
}
