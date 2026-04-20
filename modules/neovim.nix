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
    csharp_ls = {
      cmd = [
        "env"
        "DOTNET_ROOT=${pkgs.dotnet-sdk_9}/share/dotnet"
        "PATH=${pkgs.dotnet-sdk_9}/bin:${pkgs.lib.makeBinPath [ pkgs.coreutils pkgs.which ]}"
        "${pkgs.csharp-ls}/bin/csharp-ls"
      ];
      filetypes = [ "cs" ];
      capabilities = {
        experimental = {
          csharp = {
            metadataUris = true;
          };
        };
      };
      handlers = {
        "textDocument/definition" = lib.generators.mkLuaInline ''
          require("csharpls_extended").handler
        '';
      };
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
    fsautocomplete = {
      cmd = [ "fsautocomplete" "--adaptive-lsp-server-enabled" ];
      filetypes = [ "fsharp" ];
      root_dir = lib.generators.mkLuaInline ''
        function(bufnr, on_dir)
          local bufname = vim.api.nvim_buf_get_name(bufnr)
          local path = vim.fs.dirname(bufname)
          local root = vim.fs.find(
            function(name)
              return name:match("%.sln$") ~= nil or name:match("%.fsproj$") ~= nil
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
      settings = {
        FSharp = {
          AutomaticWorkspaceInit = true;
        };
      };
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
      csharpls-extended-lsp-nvim
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
      csharp-ls
      dotnet-sdk_9
      fsautocomplete
      ghc
      haskell-language-server
      hlint
      lua-language-server
      netcoredbg
      nil
      bash-language-server
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

      local uv = vim.uv or vim.loop

      local dotnet = {
        terminal_buf = nil,
        terminal_job = nil,
      }

      local function dotnet_notify(message, level)
        vim.notify(message, level or vim.log.levels.INFO, { title = ".NET" })
      end

      local function path_dirname(path)
        return vim.fs.dirname(vim.fs.normalize(path))
      end

      local function path_basename(path)
        return vim.fs.basename(vim.fs.normalize(path))
      end

      local function search_path(path)
        local normalized = vim.fs.normalize(path)
        if vim.fn.isdirectory(normalized) == 1 then
          return normalized
        end

        return path_dirname(normalized)
      end

      local function read_file(path)
        local ok, lines = pcall(vim.fn.readfile, path)
        if not ok then
          return ""
        end

        return table.concat(lines, "\n")
      end

      local function find_solution(start_path)
        local root = search_path(start_path ~= "" and start_path or uv.cwd())
        local solution = vim.fs.find(function(name)
          return name:match("%.sln$") ~= nil
        end, {
          path = root,
          upward = true,
        })[1]

        return solution
      end

      local function find_repo_root(start_path)
        local root = search_path(start_path ~= "" and start_path or uv.cwd())
        local marker = vim.fs.find(".git", { path = root, upward = true })[1]
        if marker then
          return path_dirname(marker)
        end

        return root
      end

      local function current_buffer_path()
        local path = vim.api.nvim_buf_get_name(0)
        if path == "" then
          return uv.cwd()
        end

        return path
      end

      local function current_project()
        local path = current_buffer_path()
        local project = vim.fs.find(function(name)
          return name:match("%.csproj$") ~= nil or name:match("%.fsproj$") ~= nil
        end, {
          path = search_path(path),
          upward = true,
        })[1]

        return project
      end

      local function get_workspace_root()
        local buffer_path = current_buffer_path()
        local solution = find_solution(buffer_path)
        if solution then
          return path_dirname(solution)
        end

        return find_repo_root(buffer_path)
      end

      local function list_projects(opts)
        opts = opts or {}
        local root = vim.fs.normalize(opts.root or get_workspace_root())
        local patterns = {
          root .. "/**/*.csproj",
          root .. "/**/*.fsproj",
        }
        local seen = {}
        local projects = {}

        for _, pattern in ipairs(patterns) do
          for _, path in ipairs(vim.fn.glob(pattern, false, true)) do
            local normalized = vim.fs.normalize(path)
            if not seen[normalized] then
              local contents = read_file(normalized)
              local name = path_basename(normalized):gsub("%.[cf]sproj$", "")
              local relative = vim.fs.relpath(root, normalized) or normalized
              local is_runnable =
                contents:match("<OutputType>%s*Exe%s*</OutputType>") ~= nil
                or contents:match("<OutputType>%s*WinExe%s*</OutputType>") ~= nil
              local is_test = contents:match("<IsTestProject>%s*true%s*</IsTestProject>") ~= nil
                or normalized:match("%.Tests?%.[cf]sproj$")
                or name:match("Tests?$") ~= nil
              local framework = contents:match("<TargetFramework>(.-)</TargetFramework>")
                or contents:match("<TargetFrameworks>(.-)</TargetFrameworks>")

              table.insert(projects, {
                path = normalized,
                dir = path_dirname(normalized),
                name = name,
                relative = relative,
                framework = framework and vim.split(framework, ";")[1] or "net9.0",
                runnable = is_runnable,
                test = is_test,
              })
              seen[normalized] = true
            end
          end
        end

        table.sort(projects, function(a, b)
          return a.relative < b.relative
        end)

        return projects
      end

      local function project_label(project)
        local tags = {}
        if project.runnable then
          table.insert(tags, "run")
        end
        if project.test then
          table.insert(tags, "test")
        end

        if #tags == 0 then
          return project.relative
        end

        return string.format("%s [%s]", project.relative, table.concat(tags, ", "))
      end

      local function pick_project(projects, title, callback)
        if #projects == 0 then
          dotnet_notify("No .NET projects found in this workspace", vim.log.levels.WARN)
          return
        end

        local ok, pickers = pcall(require, "telescope.pickers")
        local finders = ok and require("telescope.finders") or nil
        local conf = ok and require("telescope.config").values or nil
        local actions = ok and require("telescope.actions") or nil
        local action_state = ok and require("telescope.actions.state") or nil

        if ok then
          pickers.new({}, {
            prompt_title = title,
            finder = finders.new_table({
              results = projects,
              entry_maker = function(project)
                return {
                  value = project,
                  display = project_label(project),
                  ordinal = project.relative,
                }
              end,
            }),
            sorter = conf.generic_sorter({}),
            attach_mappings = function(prompt_bufnr)
              actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                callback(selection.value)
              end)
              return true
            end,
          }):find()
          return
        end

        callback(projects[1])
      end

      local msbuild_efm = table.concat({
        "%f(%l\\,%c): %t%*[^:]: %m",
        "%f(%l): %t%*[^:]: %m",
        "%f:%l:%c: %t%*[^:]: %m",
        "%f:%l: %t%*[^:]: %m",
      }, ",")

      local function open_quickfix(title, lines)
        vim.fn.setqflist({}, " ", {
          title = title,
          lines = lines,
          efm = msbuild_efm,
        })
        vim.cmd("copen")
      end

      local function run_quickfix_command(title, args, opts)
        opts = opts or {}
        vim.notify(string.format("Running %s", table.concat(args, " ")), vim.log.levels.INFO, {
          title = title,
        })

        vim.system(args, {
          cwd = opts.cwd or get_workspace_root(),
          text = true,
          env = opts.env,
        }, function(result)
          vim.schedule(function()
            local output = ((result.stdout or "") .. "\n" .. (result.stderr or "")):gsub("\r", "")
            local lines = vim.split(output, "\n", { trimempty = true })
            open_quickfix(title, lines)

            if result.code == 0 then
              dotnet_notify(title .. " succeeded")
            else
              dotnet_notify(title .. " failed", vim.log.levels.ERROR)
            end
          end)
        end)
      end

      local function ensure_terminal(title)
        if dotnet.terminal_buf and vim.api.nvim_buf_is_valid(dotnet.terminal_buf) then
          local win = vim.fn.bufwinid(dotnet.terminal_buf)
          if win ~= -1 then
            vim.api.nvim_set_current_win(win)
            return dotnet.terminal_buf
          end
        end

        vim.cmd("botright split")
        vim.cmd("resize 14")
        vim.cmd("enew")
        dotnet.terminal_buf = vim.api.nvim_get_current_buf()
        vim.bo[dotnet.terminal_buf].bufhidden = "wipe"
        vim.bo[dotnet.terminal_buf].swapfile = false
        vim.api.nvim_buf_set_name(dotnet.terminal_buf, title)
        return dotnet.terminal_buf
      end

      local function run_terminal_command(title, args, opts)
        opts = opts or {}
        local buf = ensure_terminal(title)
        local win = vim.fn.bufwinid(buf)
        if win ~= -1 then
          vim.api.nvim_set_current_win(win)
        end

        if dotnet.terminal_job and vim.fn.jobwait({ dotnet.terminal_job }, 0)[1] == -1 then
          vim.fn.jobstop(dotnet.terminal_job)
        end

        vim.api.nvim_buf_call(buf, function()
          vim.cmd("silent %delete _")
          dotnet.terminal_job = vim.fn.termopen(args, {
            cwd = opts.cwd or get_workspace_root(),
            env = opts.env,
          })
          vim.cmd("startinsert")
        end)
      end

      local function build_solution()
        local solution = find_solution(current_buffer_path())
        if solution then
          run_quickfix_command("dotnet build", {
            "dotnet",
            "build",
            solution,
          }, {
            cwd = path_dirname(solution),
          })
          return
        end

        local project = current_project()
        if project then
          run_quickfix_command("dotnet build", {
            "dotnet",
            "build",
            project,
          }, {
            cwd = path_dirname(project),
          })
          return
        end

        dotnet_notify("No solution or project found", vim.log.levels.WARN)
      end

      local function build_project()
        pick_project(list_projects(), "Build project", function(project)
          run_quickfix_command("dotnet build " .. project.name, {
            "dotnet",
            "build",
            project.path,
          }, {
            cwd = project.dir,
          })
        end)
      end

      local function run_project()
        local runnable = vim.tbl_filter(function(project)
          return project.runnable
        end, list_projects())

        pick_project(runnable, "Run project", function(project)
          run_terminal_command("dotnet-run://" .. project.name, {
            "dotnet",
            "run",
            "--project",
            project.path,
          }, {
            cwd = project.dir,
          })
        end)
      end

      local function watch_project()
        local runnable = vim.tbl_filter(function(project)
          return project.runnable
        end, list_projects())

        pick_project(runnable, "Watch project", function(project)
          run_terminal_command("dotnet-watch://" .. project.name, {
            "dotnet",
            "watch",
            "run",
            "--project",
            project.path,
          }, {
            cwd = project.dir,
            env = vim.tbl_extend("force", vim.fn.environ(), {
              DOTNET_WATCH_RESTART_ON_RUDE_EDIT = "true",
              SDL_VIDEODRIVER = "wayland,x11",
            }),
          })
        end)
      end

      local function test_solution()
        local solution = find_solution(current_buffer_path())
        if solution then
          run_quickfix_command("dotnet test", {
            "dotnet",
            "test",
            solution,
          }, {
            cwd = path_dirname(solution),
          })
          return
        end

        local project = current_project()
        if project then
          run_quickfix_command("dotnet test", {
            "dotnet",
            "test",
            project,
          }, {
            cwd = path_dirname(project),
          })
          return
        end

        dotnet_notify("No solution or project found", vim.log.levels.WARN)
      end

      local function test_project()
        local test_projects = vim.tbl_filter(function(project)
          return project.test
        end, list_projects())

        pick_project(test_projects, "Test project", function(project)
          run_quickfix_command("dotnet test " .. project.name, {
            "dotnet",
            "test",
            project.path,
          }, {
            cwd = project.dir,
          })
        end)
      end

      local function build_debug_program(project)
        local result = vim.system({
          "dotnet",
          "build",
          project.path,
        }, {
          cwd = project.dir,
          text = true,
        }):wait()

        local output = ((result.stdout or "") .. "\n" .. (result.stderr or "")):gsub("\r", "")
        if output ~= "" then
          open_quickfix("dotnet build " .. project.name, vim.split(output, "\n", { trimempty = true }))
        end

        if result.code ~= 0 then
          dotnet_notify("Build failed for " .. project.name, vim.log.levels.ERROR)
          return nil
        end

        local dll = string.format("%s/bin/Debug/%s/%s.dll", project.dir, project.framework, project.name)
        if vim.fn.filereadable(dll) == 1 then
          return dll
        end

        dotnet_notify("Built successfully but could not find " .. dll, vim.log.levels.WARN)
        return vim.fn.input("DLL path: ", dll, "file")
      end

      local dap = require("dap")
      local dapui = require("dapui")

      dap.defaults.fallback.switchbuf = "usevisible,useopen,uselast"

      define_sign("DapBreakpoint", "", "DiagnosticSignError")
      define_sign("DapBreakpointCondition", "", "DiagnosticSignWarn")
      define_sign("DapLogPoint", "󰃤", "DiagnosticSignInfo")
      define_sign("DapStopped", "󰁕", "DiagnosticSignHint")

      dapui.setup({
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.40 },
              { id = "watches", size = 0.20 },
              { id = "breakpoints", size = 0.20 },
              { id = "stacks", size = 0.20 },
            },
            position = "left",
            size = 48,
          },
          {
            elements = {
              { id = "repl", size = 0.5 },
              { id = "console", size = 0.5 },
            },
            position = "bottom",
            size = 12,
          },
        },
      })

      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      dap.adapters.coreclr = {
        type = "executable",
        command = "netcoredbg",
        args = { "--interpreter=vscode" },
      }

      local function debug_project()
        local runnable = vim.tbl_filter(function(project)
          return project.runnable
        end, list_projects())

        pick_project(runnable, "Debug project", function(project)
          local program = build_debug_program(project)
          if not program or program == "" then
            return
          end

          dap.run({
            type = "coreclr",
            name = "Debug " .. project.name,
            request = "launch",
            program = program,
            cwd = project.dir,
            stopAtEntry = false,
          })
        end)
      end

      vim.api.nvim_create_user_command("DotnetBuild", build_solution, {})
      vim.api.nvim_create_user_command("DotnetBuildProject", build_project, {})
      vim.api.nvim_create_user_command("DotnetRunProject", run_project, {})
      vim.api.nvim_create_user_command("DotnetWatchProject", watch_project, {})
      vim.api.nvim_create_user_command("DotnetTest", test_solution, {})
      vim.api.nvim_create_user_command("DotnetTestProject", test_project, {})
      vim.api.nvim_create_user_command("DotnetDebugProject", debug_project, {})

      vim.keymap.set("n", "<leader>mb", build_solution, { desc = ".NET build solution" })
      vim.keymap.set("n", "<leader>mB", build_project, { desc = ".NET build project" })
      vim.keymap.set("n", "<leader>mr", run_project, { desc = ".NET run project" })
      vim.keymap.set("n", "<leader>mw", watch_project, { desc = ".NET watch project" })
      vim.keymap.set("n", "<leader>mt", test_solution, { desc = ".NET test solution" })
      vim.keymap.set("n", "<leader>mT", test_project, { desc = ".NET test project" })
      vim.keymap.set("n", "<leader>md", debug_project, { desc = ".NET debug project" })
      vim.keymap.set("n", "<F5>", function() dap.continue() end, { desc = "DAP continue" })
      vim.keymap.set("n", "<F10>", function() dap.step_over() end, { desc = "DAP step over" })
      vim.keymap.set("n", "<F11>", function() dap.step_into() end, { desc = "DAP step into" })
      vim.keymap.set("n", "<F12>", function() dap.step_out() end, { desc = "DAP step out" })
      vim.keymap.set("n", "<leader>dc", function() dap.toggle_breakpoint() end, { desc = "DAP toggle breakpoint" })
      vim.keymap.set("n", "<leader>dq", function() dap.terminate() end, { desc = "DAP terminate" })
      vim.keymap.set("n", "<leader>du", function() dapui.toggle() end, { desc = "DAP UI toggle" })
      vim.keymap.set({ "n", "v" }, "<leader>de", function() dapui.eval() end, { desc = "DAP evaluate" })
      vim.keymap.set("n", "<leader>dw", function()
        local expression = vim.fn.input("Watch expression: ")
        if expression ~= nil and expression ~= "" then
          dapui.elements.watches.add(expression)
          dapui.open()
        end
      end, { desc = "DAP add watch" })

      local servers = ${lib.generators.toLua { } lspServers}
      local blink = require("blink.cmp")

      require("csharpls_extended").buf_read_cmd_bind()

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
          if client and client.name == "csharp_ls" then
            map("n", "gd", function()
              require("csharpls_extended").lsp_definitions()
            end, "LSP definition")
          else
            map("n", "gd", vim.lsp.buf.definition, "LSP definition")
          end
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
