return {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
        'nvim-treesitter/nvim-treesitter-textobjects',
        { 'windwp/nvim-ts-autotag', opts = {} },
        -- NOTE: Not sure if it is necessary, but not included by now
        -- 'JoosepAlviste/nvim-ts-context-commentstring',
        -- An alternative could be
        -- 'folke/ts-comments.nvim'
    },
    build = ':TSUpdate',
    opts = {
        -- Add languages to be installed here that you want installed for treesitter
        ensure_installed = 'all',
        -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
        auto_install = true,
        -- Install languages synchronously (only applied to `ensure_installed`)
        sync_install = false,
        -- List of parsers to ignore installing
        ignore_install = {},
        -- You can specify additional treesitter modules here: -- For example: -- playground = {--enable = true,-- },
        modules = {},
        highlight = {
            enable = true,
            -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
            --  If you are experiencing weird indenting issues, add the language to
            --  the list of additional_vim_regex_highlighting and disabled languages for indent.
            additional_vim_regex_highlighting = { 'ruby' },
        },
        indent = { enable = true, disable = { 'ruby' } },
        incremental_selection = {
            enable = true,
            keymaps = {
                init_selection = '<C-space>',
                node_incremental = '<C-space>',
                scope_incremental = '<C-s>',
                node_decremental = '<M-space>',
            },
        },
        textobjects = {
            select = {
                enable = true,
                lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
                keymaps = {
                    -- You can use the capture groups defined in textobjects.scm
                    ['aa'] = { query = '@parameter.outer', desc = 'Around p[a]rameter' },
                    ['ia'] = { query = '@parameter.inner', desc = 'Inner p[a]rameter' },
                    ['af'] = { query = '@function.outer', desc = 'Around a [f]unction region' },
                    ['if'] = { query = '@function.inner', desc = 'Inside a [f]unction region' },
                    ['ac'] = { query = '@comment.outer', desc = 'Around a [c]omment region' },
                    ['ic'] = { query = '@comment.inner', desc = 'Inside a [c]omment region' },
                    ['aC'] = { query = '@class.outer', desc = 'Around a [C]lass region' },
                    ['iC'] = { query = '@class.inner', desc = 'Inside a [C]lass region' },
                    ['ai'] = { query = '@conditional.outer', desc = 'Around an [i]f (conditional) region' },
                    ['ii'] = { query = '@conditional.inner', desc = 'Inside an [i]f (conditional) region' },
                },
            },
            move = {
                enable = true,
                set_jumps = true, -- whether to set jumps in the jumplist
                goto_next_start = {
                    [']a'] = { query = '@parameter.inner', desc = 'Go to the start of the next parameter' },
                    [']m'] = { query = '@function.outer', desc = 'Go to the start of the next function' },
                    [']]'] = { query = '@class.outer', desc = 'Go to the start of the next class' },
                },
                goto_next_end = {
                    [']A'] = { query = '@parameter.outer', desc = 'Go to the end of the next parameter' },
                    [']M'] = { query = '@function.outer', desc = 'Go to the end of the next function' },
                    [']['] = { query = '@class.outer', desc = 'Go to the end of the next class' },
                },
                goto_previous_start = {
                    ['[a'] = { query = '@parameter.outer', desc = 'Go to the start of the previous parameter' },
                    ['[m'] = { query = '@function.outer', desc = 'Go to the start of the previous function' },
                    ['[['] = { query = '@class.outer', desc = 'Go to the start of the previous class' },
                },
                goto_previous_end = {
                    ['[A'] = { query = '@parameter.outer', desc = 'Go to the end of the previous parameter' },
                    ['[M'] = { query = '@function.outer', desc = 'Go to the end of the previous function' },
                    ['[]'] = { query = '@class.outer', desc = 'Go to the end of the previous function' },
                },
            },
            swap = {
                enable = true,
                swap_next = {
                    ['<leader>ps'] = { query = '@parameter.inner', desc = '[p]arameter [s]wap with next' },
                },
                swap_previous = {
                    ['<leader>pS'] = { query = '@parameter.inner', desc = '[p]arameter [S]wap with previous' },
                },
            },
        },
    },
    config = function(_, opts)
        -- [[ Configure treesitter ]] See `:help nvim-treesitter`
        -- Defer treesitter setup after first render to improve startup time of 'nvim {filename}'
        vim.defer_fn(function()
            require('nvim-treesitter.configs').setup(opts)
            -- require('ts_context_commentstring').setup()

            local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
            ---@diagnostic disable-next-line: inject-field
            parser_config.blade = {
                install_info = {
                    url = 'https://github.com/EmranMR/tree-sitter-blade',
                    files = { 'src/parser.c' },
                    branch = 'main',
                },
                filetype = 'blade',
            }
        end, 0)
    end,
}
