return {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
        -- Snippet Engine & its associated nvim-cmp source
        {
            'L3MON4D3/LuaSnip',
            dependencies = {
                -- Adds a number of user-friendly snippets
                'rafamadriz/friendly-snippets',
            },
            build = (function()
                -- Build Step is needed for regex support in snippets
                -- This step is not supported in many windows environments
                -- Remove the below condition to re-enable on windows
                if vim.fn.has('win32') == 1 or vim.fn.executable('make') == 0 then
                    return
                end
                return 'make install_jsregexp'
            end)(),
        },
        'saadparwaiz1/cmp_luasnip',

        -- Adds LSP completion capabilities
        'hrsh7th/cmp-nvim-lsp', -- For Neovim's built-in language server client
        'hrsh7th/cmp-path', -- For filesystem paths
        'hrsh7th/cmp-nvim-lsp-signature-help', -- For displaying function signatures with the current parameter emphasized
        -- 'hrsh7th/cmp-calc', -- Math calculations, has to be enabled below on cmp.setup.sources
        'hrsh7th/cmp-omni', -- Guess this helps with the omnifunc function?

        -- Add VSCode-like pictograms to Neovim built-in lsp
        'onsails/lspkind.nvim',
    },
    -- Recommended config
    event = { 'InsertEnter', 'CmdlineEnter' },
    config = function()
        -- [[ Configure nvim-cmp ]]
        -- See `:help cmp`
        local cmp = require('cmp')
        local lspkind = require('lspkind')
        local luasnip = require('luasnip')
        require('luasnip.loaders.from_vscode').lazy_load()
        luasnip.config.setup({})

        cmp.setup({
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },
            window = {
                completion = cmp.config.window.bordered(),
                documentation = cmp.config.window.bordered(),
            },
            completion = {
                --[[
                    Recommended to be disabled but meh
                        autocomplete = false,
                    Can be overriden instead of vim.opt.completeopt
                        completeopt = 'menu,menuone,preview',
                --]]
            },
            formatting = {
                format = lspkind.cmp_format({
                    mode = 'symbol_text',
                    show_labelDetails = true,
                }),
            },
            mapping = cmp.mapping.preset.insert({
                -- Select the [n]ext item
                ['<C-n>'] = cmp.mapping.select_next_item(),

                -- Select the [p]revious item
                ['<C-p>'] = cmp.mapping.select_prev_item(),

                -- Move docs [f]orward
                ['<C-f>'] = cmp.mapping.scroll_docs(4),

                -- Move docs [b]ackward
                ['<C-b>'] = cmp.mapping.scroll_docs(-4),

                -- ['<C-e'>] = cmp.abort,

                -- Accept ([y]es) the completion.
                --  This will auto-import if your LSP supports it.
                --  This will expand snippets if the LSP sent a snippet.
                ['<C-y>'] = cmp.mapping.confirm(),

                -- Manually trigger a completion from nvim-cmp.
                --  Generally you don't need this, because nvim-cmp will display
                --  completions whenever it has completion options available.
                ['<C-Space>'] = cmp.mapping.complete(),

                -- Think of <c-l> as moving to the right of your snippet expansion.
                --  So if you have a snippet that's like:
                --  function $name($args)
                --    $body
                --  end
                --
                -- <c-l> will move you to the right of each of the expansion locations.
                -- <c-h> is similar, except moving you backwards.
                ['<C-l>'] = cmp.mapping(function()
                    if luasnip.expand_or_locally_jumpable() then
                        luasnip.expand_or_jump()
                    end
                end, { 'i', 's' }),
                ['<C-h>'] = cmp.mapping(function()
                    if luasnip.locally_jumpable(-1) then
                        luasnip.jump(-1)
                    end
                end, { 'i', 's' }),
            }),
            sources = {
                { name = 'nvim_lsp' },
                { name = 'luasnip' },
                { name = 'path' },
                { name = 'nvim_lsp_signature_help' },
                {
                    name = 'omni',
                    option = {
                        disable_omnifuncs = { 'v:lua.vim.lsp.omnifunc' },
                    },
                },
            },
        })

        -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
        cmp.setup.cmdline({ '/', '?' }, {
            mapping = cmp.mapping.preset.cmdline(),
            sources = {
                { name = 'buffer' },
            },
        })

        local function cmp_complete()
            require('cmp').complete()
        end

        vim.keymap.set('i', '<C-x><C-o>', cmp_complete, { desc = 'Show cmp completion' })
    end,
}
