return {
    'neovim/nvim-lspconfig',
    dependencies = {
        -- Automatically install LSPs and related tools to stdpath for neovim
        -- NOTE: Must be loaded before dependants
        {
            'williamboman/mason.nvim',
            opts = {
                ui = {
                    border = 'rounded',
                    icons = {
                        package_installed = '✓',
                        package_pending = '...',
                        package_uninstalled = '✗',
                    },
                },
            },
        },
        'williamboman/mason-lspconfig.nvim',
        'WhoIsSethDaniel/mason-tool-installer.nvim',

        -- Universal JSON schema store, where schemas for popular JSON documents can be found.
        'b0o/schemastore.nvim',

        -- Useful status updates for LSP
        -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
        { 'j-hui/fidget.nvim', opts = {} },

        -- lazydev configures Lua LSP for your Neovim config, runtime and plugins
        {
            'folke/lazydev.nvim',
            ft = 'lua',
            opts = {
                library = {
                    -- Load luvit types when the `vim.uv` word is found
                    { path = 'luvit-meta/library', words = { 'vim%.uv' } },
                },
            },
        },
        { 'Bilal2453/luvit-meta', lazy = true },

        -- Allows extra capabilities provided by nvim-cmp
        'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
        -- Sets a border for :LspInfo
        require('lspconfig.ui.windows').default_options.border = 'rounded'

        -- Brief Aside: **What is LSP?**
        --
        -- LSP is an acronym you've probably heard, but might not understand what it is.
        --
        -- LSP stands for Language Server Protocol. It's a protocol that helps editors
        -- and language tooling communicate in a standardized fashion.
        --
        -- In general, you have a "server" which is some tool built to understand a particular
        -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc). These Language Servers
        -- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
        -- processes that communicate with some "client" - in this case, Neovim!
        --
        -- LSP provides Neovim with features like:
        --  - Go to definition
        --  - Find references
        --  - Autocompletion
        --  - Symbol Search
        --  - and more!
        --
        -- Thus, Language Servers are external tools that must be installed separately from
        -- Neovim. This is where `mason` and related plugins come into play.
        --
        -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
        -- and elegantly composed help section, :help lsp-vs-treesitter

        --  This function gets run when an LSP attaches to a particular buffer.
        --    That is to say, every time a new file is opened that is associated with
        --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
        --    function will be executed to configure the current buffer
        vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
            callback = function(event)
                --  NOTE: Remember that lua is a real programming language, and as such it is possible
                --  to define small helper and utility functions so you don't have to repeat yourself
                --  many times.
                --
                --  In this case, we create a function that lets us more easily define mappings specific
                --  for LSP related items. It sets the mode, buffer and description for us each time.
                local map = function(keys, func, desc, mode)
                    mode = mode or 'n'
                    vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
                end

                local function use_code_action()
                    ---@diagnostic disable-next-line: missing-fields
                    vim.lsp.buf.code_action()
                end

                local function workspace_list_folders()
                    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                end

                -- Jump to the definition of the word under your cursor.
                --  This is where a variable was first declared, or where a function is defined, etc.
                --  To jump back, press <C-T>.
                map('gd', require('telescope.builtin').lsp_definitions, '[g]o to [d]efinition')

                -- Find references for the word under your cursor.
                map('gr', require('telescope.builtin').lsp_references, '[g]o to [r]eferences')

                -- Jump to the implementation of the word under your cursor.
                --  Useful when your language has ways of declaring types without an actual implementation.
                map('gi', require('telescope.builtin').lsp_implementations, '[g]o to [i]mplementation')

                -- Jump to the type of the word under your cursor.
                --  Useful when you're not sure what type a variable is and you want to see
                --  the definition of its *type*, not where it was *defined*.
                map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

                -- Fuzzy find all the symbols in your current document.
                --  Symbols are things like variables, functions, types, etc.
                map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[d]ocument [s]ymbols')

                -- Fuzzy find all the symbols in your current workspace
                --  Similar to document symbols, except searches over your whole project.
                map('<leader>Ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [s]ymbols')

                -- Rename the variable under your cursor
                --  Most Language Servers support renaming across files, etc.
                map('<leader>rn', vim.lsp.buf.rename, '[r]e[n]ame')
                -- List the references under the cursor
                map('<leader>rl', vim.lsp.buf.references, '[r]eferenes [l]ist')

                -- Execute a code action, usually your cursor needs to be on top of an error
                -- or a suggestion from your LSP for this to activate.
                map('<leader>ca', use_code_action, '[c]ode [a]ction', { 'n', 'x' })

                -- Opens a popup that displays documentation about the word under your cursor
                --  See `:help K` for why this keymap
                map('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

                -- WARN: This is not Goto Definition, this is Goto Declaration.
                --  For example, in C this would take you to the header
                map('gD', vim.lsp.buf.declaration, '[g]o to [D]eclaration')
                map('<leader>Wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [a]dd Folder')
                -- nmap('<leader>Wr', vim.lsp.buf.remove_workspace_folder, '[w]orkspace [r]emove Folder')
                map('<leader>WL', workspace_list_folders, '[W]orkspace [l]ist Folders')

                -- vim.keymap.set('n', '<leader>ft', vim.lsp.buf.format, { desc = 'Format code using None-LSP' })

                -- The following two autocommands are used to highlight references of the
                -- word under your cursor when your cursor rests there for a little while.
                --    See `:help CursorHold` for information about when this is executed
                --
                -- When you move your cursor, the highlights will be cleared (the second autocommand).
                local client = vim.lsp.get_client_by_id(event.data.client_id)
                if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
                    local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
                    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                        buffer = event.buf,
                        group = highlight_augroup,
                        callback = vim.lsp.buf.document_highlight,
                    })

                    vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                        buffer = event.buf,
                        group = highlight_augroup,
                        callback = vim.lsp.buf.clear_references,
                    })
                end

                vim.api.nvim_create_autocmd('LspDetach', {
                    group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
                    callback = function(event)
                        vim.lsp.buf.clear_references()
                        vim.api.nvim_clear_autocmds({ group = 'kickstart-lsp-highlight', buffer = event.buf })
                    end,
                })

                -- The following autocommand is used to enable inlay hints in your
                -- code, if the language server you are using supports them
                --
                -- This may be unwanted, since they displace some of your code
                if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
                    map('<leader>th', function()
                        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
                    end, '[t]oggle Inlay [h]ints')
                end
            end,
        })

        -- Sign configuration
        vim.fn.sign_define('DiagnosticSignError', { text = '', texthl = 'DiagnosticSignError' })
        vim.fn.sign_define('DiagnosticSignWarn', { text = '', texthl = 'DiagnosticSignWarn' })
        vim.fn.sign_define('DiagnosticSignInfo', { text = '', texthl = 'DiagnosticSignInfo' })
        vim.fn.sign_define('DiagnosticSignHint', { text = '', texthl = 'DiagnosticSignHint' })

        -- LSP servers and clients are able to communicate to each other what features they support.
        --  By default, Neovim doesn't support everything that is in the LSP Specification.
        --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
        --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

        -- Enable the following language servers
        --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
        --
        --  Add any additional override configuration in the following tables. Available keys are:
        --  - cmd (table): Override the default command used to start the server
        --  - filetypes (table): Override the default list of associated filetypes for the server
        --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
        --  - settings (table): Override the default settings passed when initializing the server.
        --    For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
        -- TODO: Check a way to extend the filetypes and not override them?
        local servers = {
            -- clangd = {},
            -- gopls = {},
            -- pyright = {},
            -- rust_analyzer = {},
            -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
            --
            -- Some languages (like typescript) have entire language plugins that can be useful:
            --    https://github.com/pmizio/typescript-tools.nvim
            --
            -- But for many setups, the LSP (`ts_ls`) will work just fine
            -- antlersls = {},
            cssls = {
                filetypes = {
                    -- 'antlers',
                    'blade',
                    'html',
                },
            },
            emmet_language_server = {
                filetypes = {
                    -- 'antlers',
                    'blade',
                    'php',
                },
            },
            html = {
                filetypes = {
                    -- 'antlers',
                    'hbs',
                    'php',
                    'twig',
                },
            },
            intelephense = {},
            -- https://github.com/b0o/schemastore.nvim
            jsonls = {
                settings = {
                    json = {
                        schemas = require('schemastore').json.schemas(),
                        validate = { enable = true },
                    },
                },
            },
            lua_ls = {
                -- cmd = {...},
                -- filetypes = { ...},
                -- capabilities = {},
                settings = {
                    Lua = {
                        telemetry = { enable = false },
                        -- Formatting options
                        -- https://luals.github.io/wiki/formatter/
                        -- https://github.com/CppCXY/EmmyLuaCodeStyle/blob/master/docs/format_config_EN.md
                        completion = {
                            callSnippet = 'Replace',
                        },
                        -- NOTE: toggle below to ignore Lua_LS's noisy `missing-fields` warnings
                        -- diagnostics = { disable = { 'missing-fields' } },
                    },
                },
            },
            tailwindcss = {
                -- filetypes = {
                --     'antlers',
                -- },
                -- settings = {
                --     tailwindCss = {
                --         includeLanguages = {
                --             antlers = 'html',
                --         },
                --     },
                -- },
            },
            ts_ls = {},
            -- In case I need to configure it deeply
            -- https://www.arthurkoziel.com/json-schemas-in-neovim/
            yamlls = {
                settings = {
                    yaml = {
                        format = {
                            enable = true,
                            singleQuote = true,
                            bracketSpacing = true,
                        },
                        completion = true,
                        schemaStore = {
                            enable = true,
                        },
                    },
                },
            },
        }

        -- Merge LSPs defined ft list with my servers table
        for server_name, opts in pairs(servers) do
            -- Get LSP defined ft list
            local current_server_ft_list = require('lspconfig.configs.' .. server_name).default_config.filetypes
            -- Get my defined ft list for a given LSP from the servers table
            opts.filetypes = opts.filetypes or {}
            -- "Merge" them
            vim.list_extend(opts.filetypes, current_server_ft_list)
        end

        -- Ensure the servers and tools above are installed
        --  To check the current status of installed tools and/or manually install
        --  other tools, you can run
        --    :Mason
        --
        --  You can press `g?` for help in this menu

        -- Set border globally instead of per client
        -- See https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization#borders
        local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
        ---@diagnostic disable-next-line: duplicate-set-field
        function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
            opts = opts or {}
            opts.border = opts.border or 'rounded'
            return orig_util_open_floating_preview(contents, syntax, opts, ...)
        end

        -- You can add other tools here that you want Mason to install
        -- for you, so that they are available from within Neovim.
        -- NOTE: Used in Conform.nvim
        local ensure_installed = vim.tbl_keys(servers or {})
        vim.list_extend(ensure_installed, {
            'stylua', -- Used to format lua code
            'prettierd',
            'mdslw', -- Markdown formatter
            'pint', -- PHP formatter
            'blade-formatter',
        })

        require('mason-tool-installer').setup({ ensure_installed = ensure_installed })

        require('mason-lspconfig').setup({
            handlers = {
                function(server_name)
                    local server = servers[server_name] or {}
                    -- This handles overriding only values explicitly passed by the server
                    -- configuration above. Useful when disabling certain features of
                    -- an LSP (for example, turning off formatting for ts_ls)
                    server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
                    require('lspconfig')[server_name].setup(server)
                end,
            },
        })
    end,
}
