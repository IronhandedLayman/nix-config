{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    (lua5_1.withPackages (
      ps: with ps; [
        busted
        luafilesystem
        luarocks
        lua-utils-nvim
        pathlib-nvim
      ]
    ))
  ];

  programs.nixvim = {
    enable = true;
    globals = {
      mapleader = " ";
      maplocalleader = " ";
      signcolumn = "yes";
      fileencoding = "utf-8";
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

    colorschemes.base16 = {
      enable = true;
      colorscheme = "atelier-dune";
    };

    plugins = {
      # all the following with basic options
      flash.enable = true;
      gitsigns.enable = true;
      lualine.enable = true;
      luasnip.enable = true;
      neogit.enable = true;
      nix.enable = true;
      sleuth.enable = true;
      bufferline.enable = true;
      telescope.enable = true;
      fugitive.enable = true;
      lightline.enable = true;
      #      gitgutter.enable = true;
      neorg = {
        enable = true;
        settings.load = {
          # modules using default settings
          "core.defaults" = { __empty = null; };
          "core.concealer" = { __empty = null; };
          "core.integrations.image" = { __empty = null; };
          "core.latex.renderer" = { __empty = null; };
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
          ruff.enable = true;
          dockerls.enable = true;
        };
      };
      dap = {
        enable = true;
      };
      dap-go.enable = true;
      dap-python.enable = true;
      dap-lldb.enable = true;

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
