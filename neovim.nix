{ pkgs, ... }:
{
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

    diagnostic = {
      # enable = true;
      settings = {
	virtual_text = {
	  severity.min = "warn";
	  source = "if_many";
	};
	virtual_lines = {
	  current_line = true;
	};
      };
    };

    extraConfigLuaPost=''
      local strudel = require("strudel")
      strudel.setup()  
    '';

    colorschemes.base16 = {
      enable = true;
      colorscheme = "atelier-dune";
    };

    plugins = {
      # all the following with basic options
      avante.enable = true;

      conjure.enable = true; # for lisp
      paredit.enable = true; # for lisp
      
      flash.enable = true;
      bufferline.enable = true;
      fugitive.enable = true;
      gitsigns.enable = true;
      lualine.enable = true;
      luasnip.enable = true;
      markdown-preview.enable = true;
      neogit.enable = true;
      nix.enable = true;
      sleuth.enable = true;
      web-devicons.enable = true;
      treesitter= {
	enable = true;
	nixvimInjections = true;
      };
      treesitter-context.enable = true;
      image.enable=true;

      ollama = {
	enable = false;
	settings = {
	  model = "hf.co/unsloth/DeepSeek-R1-Distill-Llama-8B-GGUF:Q8_0";
	};
      };

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
      	enable = false;
	settings.load = {
	  # modules using default settings
	  "core.defaults" = { __empty = null;};
	  "core.concealer" = { __empty = null;};
	  "core.integrations.image" = { __empty = null;};
	  "core.latex.renderer" = { __empty = null;};
	  "core.esupports.metagen" = { 
	    type = "auto";
	  };

	  "core.dirman" = {
	    config = {
	      workspaces = {
		notes = "~/notes";
	      };
	      # index = "~/notes/index.norg";
	      default_workspace = "notes";
	    };
	  };
	};
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
	    "<Tab>" = ''
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
	    "<Down>" = ''
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
	    "<Up>" = ''
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

	  inlayHints = true;

	  keymaps = {
	    diagnostic = {
	      "<leader>j" = "goto_next";
	      "<leader>k" = "goto_prev";
	    };

	    lspBuf = {
	      gd = "definition";
	      gD = "references";
	      gT = "type_definition";
	      gi = "implementation";
	      K = "hover";
	      "<F2>" = "rename";
	    };
	  };

	  servers = {
	    bashls.enable = true;
	    clangd.enable = true;
	    gopls = {
	      enable = true;
	      settings = {
		hints = {
		  enable = true;
		  functionTypeParameters = true;
		  parameterNames = true;
		  rangeVariableTypes = true;
		};
	      };
	    };
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
	    pyright.enable = true;
	    ruff.enable = true;
	    dockerls.enable = true;
	  };
	};
      dap = {
	enable=true;
      };
      dap-go.enable = true;
      dap-python.enable = true;
      dap-lldb.enable = true;

      };
      keymaps = [
	# Telescope
	  {
	    mode = "n";
	    key = "<leader>ff";
	    action = "<cmd>Telescope find_files<cr>";
	    options.desc = "Find files";
	    }
	    {
	    mode = "n";
	    key = "<leader>fg";
	    action = "<cmd>Telescope live_grep<cr>";
	    options.desc = "Live grep";
	    }

      # Conjure — eval current form
      {
	mode = "n";
	key = "<localleader>ee";
	action = "<cmd>ConjureEval<cr>";
	options.desc = "Eval form";
	}

      # Conjure — eval whole buffer
      {
	mode = "n";
	key = "<localleader>eb";
	action = "<cmd>ConjureEvalBuf<cr>";
	options.desc = "Eval buffer";
	}
      ];
      extraPlugins = [
	(pkgs.vimUtils.buildVimPlugin {
	  name = "strudel.nvim";
	  src = pkgs.fetchFromGitHub {
	    owner = "gruvw";
	    repo = "strudel.nvim";
	    rev = "a6b9752b0084a20c37786b54eef2095bb31daff7";
	    hash = "sha256-LhS41aKsYJpKqoF2S3ZzeDLYGBKA4iMN2o34k8YOWHs=";
	  };
        })
      ];
    };
}
