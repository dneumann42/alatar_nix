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
    cmdheight = 0;
    completeopt = [
      "menu"
      "menuone"
      "noselect"
      "popup"
    ];
    expandtab = true;
    showmode = false;
    shiftwidth = 4;
    tabstop = 4;
    smartindent = true;
    termguicolors = true;
    signcolumn = "yes:2";
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

    gitsigns = {
      signs = {
        add = { text = "▎"; };
        change = { text = "▎"; };
        delete = { text = ""; };
        topdelete = { text = ""; };
        changedelete = { text = "▎"; };
      };
      signs_staged = {
        add = { text = "▎"; };
        change = { text = "▎"; };
        delete = { text = ""; };
        topdelete = { text = ""; };
        changedelete = { text = "▎"; };
      };
    };
    mini-files = { };

    lualine = {
      options = {
        globalstatus = true;
        theme = "catppuccin";
      };
    };

    noice = {
      cmdline = {
        enabled = true;
        view = "cmdline";
      };
      messages = {
        enabled = true;
        view = "mini";
        view_error = "mini";
        view_warn = "mini";
      };
      popupmenu.enabled = false;
      presets = {
        bottom_search = true;
        command_palette = false;
        long_message_to_split = true;
      };
    };

    which-key = { };
    telescope = { };
    blink-cmp = {
      keymap = {
        preset = "enter";
        "<C-space>" = [
          "show"
          "show_documentation"
          "hide_documentation"
        ];
        "<CR>" = [ "accept" "fallback" ];
        "<Tab>" = [ "select_next" "snippet_forward" "fallback" ];
        "<S-Tab>" = [ "select_prev" "snippet_backward" "fallback" ];
      };
      appearance.nerd_font_variant = "mono";
      completion = {
        documentation = {
          auto_show = true;
          auto_show_delay_ms = 200;
          window.border = "rounded";
        };
        menu = {
          border = "rounded";
          draw.treesitter = [ "lsp" ];
        };
        list.selection = {
          auto_insert = false;
          preselect = false;
        };
        ghost_text.enabled = false;
      };
      signature = {
        enabled = true;
        window.border = "rounded";
      };
      sources.default = [ "lsp" "path" "snippets" "buffer" ];
      fuzzy.implementation = "prefer_rust_with_warning";
    };

    treesitter = { };
  };

  lspServers = {
    bashls = {
      cmd = [
        "env"
        "-u"
        "LD_LIBRARY_PATH"
        "-u"
        "NODE_OPTIONS"
        "${pkgs.bash-language-server}/bin/bash-language-server"
        "start"
      ];
      filetypes = [ "bash" "sh" "zsh" ];
      root_markers = [ ".git" ];
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
    clangd = {
      cmd = [ "clangd" ];
      filetypes = [ "c" "cpp" "objc" "objcpp" "cuda" ];
      root_markers = [ ".git" "CMakeLists.txt" "compile_commands.json" ];
      settings = {
        clangd = {
        };
      };
      capabilities = {
        textDocument = {
          semanticTokens = {
            fullSupport = true;
          };
        };
        inlayHint = {
          resolveProvider = true;
        };
      };
    };
    nim_langserver = {
      cmd = [ "nimlangserver" ];
      filetypes = [ "nim" ];
      root_markers = [ ".git" ];
    };
    ts_ls = {
      cmd = [
        "env"
        "-u"
        "LD_LIBRARY_PATH"
        "-u"
        "NODE_OPTIONS"
        "${pkgs.typescript-language-server}/bin/typescript-language-server"
        "--stdio"
      ];
      filetypes = [
        "javascript"
        "javascriptreact"
        "typescript"
        "typescriptreact"
        "svelte"
      ];
      root_dir = lib.generators.mkLuaInline ''
        function(bufnr, on_dir)
          local path = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
          local root = vim.fs.find({ "package.json", "tsconfig.json", "jsconfig.json" }, { path = path, upward = true })[1]
          if not root then
            root = vim.fs.find(".git", { path = path, upward = true })[1]
          end
          on_dir(root and vim.fs.dirname(root) or vim.uv.cwd())
        end
      '';
    };
    sveltel = {
      cmd = [
        "env"
        "-u"
        "LD_LIBRARY_PATH"
        "-u"
        "NODE_OPTIONS"
        "PATH=${pkgs.nodejs_22}/bin:${pkgs.coreutils}/bin:${pkgs.bash}/bin"
        "${pkgs.svelte-language-server}/bin/svelteserver"
        "--stdio"
      ];
      filetypes = [ "svelte" ];
      root_dir = lib.generators.mkLuaInline ''
        function(bufnr, on_dir)
          local path = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
          local root = vim.fs.find({ "svelte.config.js", "svelte.config.ts", "vite.config.ts", "vite.config.js", "package.json" }, { path = path, upward = true })[1]
          if not root then
            root = vim.fs.find(".git", { path = path, upward = true })[1]
          end
          on_dir(root and vim.fs.dirname(root) or vim.uv.cwd())
        end
      '';
      settings = {
        svelte = {
          plugin = {
            svelte = {
              completions = {
                enable = true;
              };
              diagnostics = {
                enable = true;
              };
            };
          };
        };
      };
    };
  };

  sushiFtdetect = ''
    augroup sushi_ftdetect
      autocmd!
      autocmd BufRead,BufNewFile *.sushi setfiletype sushi
    augroup END
  '';

  sushiFtplugin = ''
    setlocal commentstring=#\ %s
    setlocal comments=:#
    setlocal iskeyword+=-
    setlocal expandtab
    setlocal shiftwidth=4
    setlocal tabstop=4
  '';

  sushiSyntax = ''
    if exists("b:current_syntax")
      finish
    endif

    syntax case match

    syntax keyword sushiConditional if else
    syntax keyword sushiRepeat for while
    syntax keyword sushiFlow return break continue
    syntax keyword sushiKeyword class fun field do end new self var const null let set eval
    syntax keyword sushiBoolean true false T F

    syntax keyword sushiTodo TODO FIXME NOTE XXX contained
    syntax match sushiComment /#.*/ contains=sushiTodo

    syntax region sushiString start=/"/ skip=/\\./ end=/"/ contains=sushiEscape
    syntax region sushiString start=/'/ skip=/\\./ end=/'/ contains=sushiEscape
    syntax match sushiEscape /\\./ contained

    syntax match sushiNumber /\v<\d+(\.\d+)?>/
    syntax match sushiIdentifier /\v<[A-Za-z_][A-Za-z0-9_]*(\-[A-Za-z0-9_]+)*(\.[A-Za-z_][A-Za-z0-9_]*(\-[A-Za-z0-9_]+)*)*>/
    syntax match sushiOperator /[+*\/%=<>!&|^~:.]\|\%(^\|[^A-Za-z0-9_]\)\zs-\|-\ze\%($\|[^A-Za-z0-9_]\)/
    syntax match sushiDelimiter /[][(){}]/
    syntax match sushiFunction /\v^\s*[A-Za-z_][A-Za-z0-9_]*(\-[A-Za-z0-9_]+)*(\.[A-Za-z_][A-Za-z0-9_]*(\-[A-Za-z0-9_]+)*)*/

    highlight default link sushiConditional Conditional
    highlight default link sushiRepeat Repeat
    highlight default link sushiFlow Repeat
    highlight default link sushiKeyword Keyword
    highlight default link sushiBoolean Boolean
    highlight default link sushiTodo Todo
    highlight default link sushiComment Comment
    highlight default link sushiString String
    highlight default link sushiEscape SpecialChar
    highlight default link sushiNumber Number
    highlight default link sushiIdentifier Identifier
    highlight default link sushiOperator Operator
    highlight default link sushiDelimiter Delimiter
    highlight default link sushiFunction Function

    let b:current_syntax = "sushi"
  '';
in

{
  xdg.configFile = {
    "nvim/ftdetect/sushi.vim".text = sushiFtdetect;
    "nvim/ftplugin/sushi.vim".text = sushiFtplugin;
    "nvim/syntax/sushi.vim".text = sushiSyntax;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    withPython3 = true;
    withRuby = true;

    plugins = with pkgs.vimPlugins; [
      blink-cmp
      nvim-surround
      catppuccin-nvim
      nvim-web-devicons
      nui-nvim
      noice-nvim
      plenary-nvim
      telescope-nvim
      nvim-dap
      nvim-dap-ui
      nvim-nio
      nvim-treesitter.withAllGrammars
      lualine-nvim
      gitsigns-nvim
      mini-nvim
      which-key-nvim
      (pkgs.vimUtils.buildVimPlugin {
        name = "multicursor-nvim";
        src = pkgs.fetchFromGitHub {
          owner = "jake-stewart";
          repo = "multicursor.nvim";
          rev = "1.0";
          sha256 = "sha256-JHl8Z7ESrWus2I6Pe+6gmdgCAZOzAKX7kimy71sAoe4=";
        };
      })
    ];

    extraPackages = with pkgs; [
      cabal-install
      ghc
      haskell-language-server
      hlint
      lua-language-server
      nil
      bash-language-server
      clang-tools
      typescript-language-server
      svelte-language-server
      nodejs_22
      nimlangserver
      ormolu
      ripgrep
    ];

    initLua = ''
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
      require("nvim-web-devicons").setup({})
      vim.cmd.colorscheme("catppuccin")

      require("noice").setup(plugin_settings.noice)

      local noice = require("noice")
      plugin_settings.lualine.sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { "filename" },
        lualine_x = {
          {
            noice.api.status.message.get_hl,
            cond = noice.api.status.message.has,
          },
          {
            noice.api.status.command.get,
            cond = noice.api.status.command.has,
            color = { fg = "#ff9e64" },
          },
          {
            noice.api.status.mode.get,
            cond = noice.api.status.mode.has,
            color = { fg = "#ff9e64" },
          },
          {
            noice.api.status.search.get,
            cond = noice.api.status.search.has,
            color = { fg = "#89b4fa" },
          },
          "encoding",
          "fileformat",
          "filetype",
        },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      }

      require("gitsigns").setup(plugin_settings.gitsigns)
      require("mini.files").setup(plugin_settings["mini-files"])
      require("nvim-surround").setup({})
      require("lualine").setup(plugin_settings.lualine)
      require("which-key").setup(plugin_settings["which-key"])
      require("telescope").setup(plugin_settings.telescope)
      require("blink.cmp").setup(plugin_settings["blink-cmp"])

      do
        local mc = require("multicursor-nvim")
        mc.setup()

        local set = vim.keymap.set

        set({ "n", "x" }, "<up>", function()
          mc.lineAddCursor(-1)
        end)
        set({ "n", "x" }, "<down>", function()
          mc.lineAddCursor(1)
        end)
        set({ "n", "x" }, "<leader><up>", function()
          mc.lineSkipCursor(-1)
        end)
        set({ "n", "x" }, "<leader><down>", function()
          mc.lineSkipCursor(1)
        end)

        set({ "n", "x" }, "<leader>n", function()
          mc.matchAddCursor(1)
        end)
        set({ "n", "x" }, "<leader>s", function()
          mc.matchSkipCursor(1)
        end)
        set({ "n", "x" }, "<leader>N", function()
          mc.matchAddCursor(-1)
        end)
        set({ "n", "x" }, "<leader>S", function()
          mc.matchSkipCursor(-1)
        end)

        set("n", "<c-leftmouse>", mc.handleMouse)
        set("n", "<c-leftdrag>", mc.handleMouseDrag)
        set("n", "<c-leftrelease>", mc.handleMouseRelease)

        set({ "n", "x" }, "<c-q>", mc.toggleCursor)

        mc.addKeymapLayer(function(layerSet)
          layerSet({ "n", "x" }, "<left>", mc.prevCursor)
          layerSet({ "n", "x" }, "<right>", mc.nextCursor)

          layerSet({ "n", "x" }, "<leader>x", mc.deleteCursor)

          layerSet("n", "<esc>", function()
            if not mc.cursorsEnabled() then
              mc.enableCursors()
            else
              mc.clearCursors()
            end
          end)
        end)

        local hl = vim.api.nvim_set_hl
        hl(0, "MultiCursorCursor", { reverse = true })
        hl(0, "MultiCursorVisual", { link = "Visual" })
        hl(0, "MultiCursorSign", { link = "SignColumn" })
        hl(0, "MultiCursorMatchPreview", { link = "Search" })
        hl(0, "MultiCursorDisabledCursor", { reverse = true })
        hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
        hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
      end

      local telescope_builtin = require("telescope.builtin")

      local function telescope_project_root()
        local current = vim.api.nvim_buf_get_name(0)
        if current == "" then
          current = vim.fn.getcwd()
        end

        return vim.fs.root(current, { ".git" }) or vim.fn.getcwd()
      end

      local function telescope_search_dirs(root)
        local dirs = { "." }
        if vim.fn.isdirectory(root .. "/vendor") == 1 then
          table.insert(dirs, "vendor")
        end
        return dirs
      end

      local function telescope_find_files_with_vendor()
        local root = telescope_project_root()
        local find_command = { "rg", "--files", "--" }
        for _, dir in ipairs(telescope_search_dirs(root)) do
          table.insert(find_command, dir)
        end
        telescope_builtin.find_files({ cwd = root, find_command = find_command })
      end

      local function telescope_live_grep_with_vendor()
        local root = telescope_project_root()
        telescope_builtin.live_grep({ cwd = root, search_dirs = telescope_search_dirs(root) })
      end

      vim.keymap.set("n", "<leader>f", telescope_find_files_with_vendor, { desc = "Find files" })
      vim.keymap.set("n", "<leader>g", telescope_live_grep_with_vendor, { desc = "Live grep" })
      require("nvim-treesitter").setup(plugin_settings.treesitter)

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("nixos-neovim-treesitter", { clear = true }),
        callback = function(args)
          if pcall(vim.treesitter.start, args.buf) then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })

      local transparent_groups = {
        "Normal",
        "NormalNC",
        "SignColumn",
        "LineNr",
        "CursorLineNr",
        "EndOfBuffer",
        "StatusLine",
        "StatusLineNC",
        "WinSeparator",
        "VertSplit",
      }

      local float_highlights = {
        NormalFloat = { bg = "#000000" },
        FloatBorder = { bg = "#000000", fg = "#cdd6f4" },
        Pmenu = { bg = "#000000" },
        PmenuSel = { bg = "#111111" },
        PmenuSbar = { bg = "#000000" },
        PmenuThumb = { bg = "#222222" },
      }

      local function apply_highlight_overrides()
        for _, group in ipairs(transparent_groups) do
          vim.api.nvim_set_hl(0, group, { bg = "none" })
        end

        for group, value in pairs(float_highlights) do
          vim.api.nvim_set_hl(0, group, value)
        end
      end

      apply_highlight_overrides()
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("nixos-neovim-transparency", { clear = true }),
        callback = apply_highlight_overrides,
      })

      local function define_sign(name, text, texthl)
        vim.fn.sign_define(name, {
          text = text,
          texthl = texthl,
          numhl = "",
        })
      end

      define_sign("DiagnosticSignError", "", "DiagnosticSignError")
      define_sign("DiagnosticSignWarn", "", "DiagnosticSignWarn")
      define_sign("DiagnosticSignInfo", "", "DiagnosticSignInfo")
      define_sign("DiagnosticSignHint", "󰌵", "DiagnosticSignHint")

      vim.lsp.handlers["textDocument/hover"] = function(_, result, ctx, config)
        config = config or {}
        config.border = "rounded"
        return vim.lsp.handlers.hover(_, result, ctx, config)
      end
      vim.lsp.handlers["textDocument/signatureHelp"] = function(_, result, ctx, config)
        config = config or {}
        config.border = "rounded"
        return vim.lsp.handlers.signature_help(_, result, ctx, config)
      end

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
      local blink = require("blink.cmp")

      for server, settings in pairs(servers) do
        local capabilities = blink.get_lsp_capabilities(settings.capabilities)
        settings.capabilities = capabilities
        vim.lsp.config(server, settings)
        vim.lsp.enable(server)
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("nixos-neovim-lsp", { clear = true }),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, {
              buffer = args.buf,
              desc = desc,
            })
          end

          map("n", "K", vim.lsp.buf.hover, "LSP hover")
          map("n", "gd", vim.lsp.buf.definition, "LSP definition")
          map("n", "gr", vim.lsp.buf.references, "LSP references")
          map("n", "gi", vim.lsp.buf.implementation, "LSP implementation")
          map("n", "<leader>rn", vim.lsp.buf.rename, "LSP rename")
          map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "LSP code action")
          map({ "n", "v" }, "<M-CR>", vim.lsp.buf.code_action, "LSP code action")
          map("n", "[d", vim.diagnostic.goto_prev, "Previous diagnostic")
          map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
        end,
      })
    '';
  };
}
