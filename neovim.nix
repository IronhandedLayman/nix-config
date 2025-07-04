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

    globals.mapleader = "\\";
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
      #      gitgutter.enable = true;
      neorg = {
        enable = true;
        modules = {
          "core.defaults" = { __empty = null; };
          "core.concealer" = { __empty = null; };
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
        autoEnableSources = true;
        settings = {
          sources = [
            { name = "nvim_lsp"; }
            { name = "path"; }
            { name = "buffer"; }
            { name = "luasnip"; }
            { name = "cmp-emoji"; }
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
