{ pkgs, lib, ... }:

let
  globals = {
    mapleader = ",";
    maplocalleader = ",";
  };

  options = {
    number = true;
    relativenumber = true;
    mouse = "a";
    clipboard = "unnamedplus";
    completeopt = [
      "menu"
      "menuone"
      "popup"
      "fuzzy"
    ];
    expandtab = true;
    shiftwidth = 4;
    tabstop = 4;
    smartindent = true;
    termguicolors = true;
    signcolumn = "yes";
    updatetime = 250;
    timeoutlen = 300;
  };

  diagnostics = {
    severity_sort = true;
    underline = true;
    update_in_insert = false;
    virtual_text = {
      spacing = 2;
      source = "if_many";
    };
    float.border = "rounded";
  };

  keymaps = [
    {
      mode = "i";
      lhs = "<C-Space>";
      rhs = lib.generators.mkLuaInline "vim.lsp.completion.get";
      opts.desc = "LSP completion";
    }
    {
      mode = "n";
      lhs = "<leader>f";
      rhs = "<cmd>Telescope find_files<cr>";
      opts.desc = "Find files";
    }
    {
      mode = "n";
      lhs = "<leader>g";
      rhs = "<cmd>Telescope live_grep<cr>";
      opts.desc = "Live grep";
    }
    {
      mode = "n";
      lhs = "<leader>b";
      rhs = "<cmd>Telescope buffers<cr>";
      opts.desc = "Find buffers";
    }
    {
      mode = "n";
      lhs = "<leader>h";
      rhs = "<cmd>Telescope help_tags<cr>";
      opts.desc = "Help tags";
    }
  ];

  pluginSettings = {
    catppuccin = {
      flavour = "mocha";
      transparent_background = true;
    };

    gitsigns = { };
    mini-files = { };

    lualine = {
      options = {
        globalstatus = true;
        theme = "catppuccin";
      };
    };

    which-key = { };
    telescope = { };

    treesitter = {
      auto_install = false;
      highlight.enable = true;
      indent.enable = true;
    };
  };

  lspServers = {
    bashls = {
      cmd = [ "bash-language-server" "start" ];
      filetypes = [ "bash" "sh" "zsh" ];
      root_markers = [ ".git" ];
    };
    csharp_ls = {
      cmd = [
        "env"
        "DOTNET_ROOT=${pkgs.dotnet-sdk_9}/share/dotnet"
        "PATH=${pkgs.dotnet-sdk_9}/bin:${pkgs.lib.makeBinPath [ pkgs.coreutils pkgs.which ]}"
        "${pkgs.csharp-ls}/bin/csharp-ls"
      ];
      filetypes = [ "cs" ];
      root_dir = lib.generators.mkLuaInline ''
        function(bufnr, on_dir)
          local bufname = vim.api.nvim_buf_get_name(bufnr)
          local path = vim.fs.dirname(bufname)
          local root = vim.fs.find(
            function(name)
              return name:match("%.sln$") ~= nil or name:match("%.csproj$") ~= nil
            end,
            { path = path, upward = true }
          )[1]

          if not root then
            root = vim.fs.find(".git", { path = path, upward = true })[1]
          end

          if root then
            on_dir(vim.fs.dirname(root))
          end
        end
      '';
    };
    lua_ls = {
      cmd = [ "lua-language-server" ];
      filetypes = [ "lua" ];
      root_markers = [
        [ ".luarc.json" ".luarc.jsonc" ]
        ".git"
      ];
      settings = {
        Lua = {
          diagnostics.globals = [ "vim" ];
          completion.callSnippet = "Replace";
          telemetry.enable = false;
          workspace.checkThirdParty = false;
        };
      };
    };
    nil_ls = {
      cmd = [ "nil" ];
      filetypes = [ "nix" ];
      root_markers = [ "flake.nix" "default.nix" ".git" ];
    };
    hls = {
      cmd = [ "haskell-language-server-wrapper" "--lsp" ];
      filetypes = [ "haskell" "lhaskell" "cabal" ];
      root_dir = lib.generators.mkLuaInline ''
        function(bufnr, on_dir)
          local bufname = vim.api.nvim_buf_get_name(bufnr)
          local path = vim.fs.dirname(bufname)
          local root = vim.fs.find(
            { "hie.yaml", "cabal.project", "stack.yaml" },
            { path = path, upward = true }
          )[1]

          if not root then
            local cabal = vim.fs.find(
              function(name)
                return name:match("%.cabal$") ~= nil
              end,
              { path = path, upward = true }
            )[1]
            root = cabal
          end

          if not root then
            root = vim.fs.find(".git", { path = path, upward = true })[1]
          end

          if root then
            on_dir(vim.fs.dirname(root))
          end
        end
      '';
    };
    nim_langserver = {
      cmd = [ "nimlangserver" ];
      filetypes = [ "nim" ];
      root_markers = [ ".git" ];
    };
    ts_ls = {
      cmd = [ "typescript-language-server" "--stdio" ];
      filetypes = [
        "javascript"
        "javascriptreact"
        "typescript"
        "typescriptreact"
      ];
      root_markers = [ "package.json" "tsconfig.json" "jsconfig.json" ".git" ];
    };
  };
in

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    withPython3 = true;

    plugins = with pkgs.vimPlugins; [
      catppuccin-nvim
      plenary-nvim
      telescope-nvim
      nvim-treesitter.withAllGrammars
      lualine-nvim
      gitsigns-nvim
      mini-nvim
      which-key-nvim
    ];

    extraPackages = with pkgs; [
      cabal-install
      csharp-ls
      dotnet-sdk_9
      ghc
      haskell-language-server
      hlint
      lua-language-server
      nil
      nodePackages.bash-language-server
      nodePackages.typescript-language-server
      nimlangserver
      ormolu
      ripgrep
    ];

    extraLuaConfig = ''
      local globals = ${lib.generators.toLua { } globals}
      for name, value in pairs(globals) do
        vim.g[name] = value
      end

      local options = ${lib.generators.toLua { } options}
      for name, value in pairs(options) do
        vim.opt[name] = value
      end

      vim.diagnostic.config(${lib.generators.toLua { } diagnostics})

      local keymaps = ${lib.generators.toLua { } keymaps}
      for _, mapping in ipairs(keymaps) do
        vim.keymap.set(mapping.mode, mapping.lhs, mapping.rhs, mapping.opts)
      end

      local plugin_settings = ${lib.generators.toLua { } pluginSettings}
      require("catppuccin").setup(plugin_settings.catppuccin)
      vim.cmd.colorscheme("catppuccin")

      require("gitsigns").setup(plugin_settings.gitsigns)
      require("mini.files").setup(plugin_settings["mini-files"])
      require("lualine").setup(plugin_settings.lualine)
      require("which-key").setup(plugin_settings["which-key"])
      require("telescope").setup(plugin_settings.telescope)
      require("nvim-treesitter.configs").setup(plugin_settings.treesitter)

      local transparent_groups = {
        "Normal",
        "NormalNC",
        "NormalFloat",
        "FloatBorder",
        "Pmenu",
        "PmenuSel",
        "PmenuSbar",
        "PmenuThumb",
        "SignColumn",
        "LineNr",
        "CursorLineNr",
        "EndOfBuffer",
        "StatusLine",
        "StatusLineNC",
        "WinSeparator",
        "VertSplit",
      }

      local function apply_transparency()
        for _, group in ipairs(transparent_groups) do
          vim.api.nvim_set_hl(0, group, { bg = "none" })
        end
      end

      apply_transparency()
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("nixos-neovim-transparency", { clear = true }),
        callback = apply_transparency,
      })

      vim.keymap.set("n", "<M-0>", function()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.bo[buf].filetype == "minifiles" then
            require("mini.files").close()
            return
          end
        end

        local path = vim.api.nvim_buf_get_name(0)
        if path == "" then
          path = vim.loop.cwd()
        elseif vim.fn.filereadable(path) == 1 then
          path = vim.fn.fnamemodify(path, ":h")
        end

        require("mini.files").open(path, true)
      end, { desc = "Toggle mini.files" })

      local servers = ${lib.generators.toLua { } lspServers}

      for server, settings in pairs(servers) do
        vim.lsp.config(server, settings)
        vim.lsp.enable(server)
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("nixos-neovim-lsp", { clear = true }),
        callback = function(args)
          local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
          if client:supports_method("textDocument/completion") then
            vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
          end
        end,
      })
    '';
  };
}
