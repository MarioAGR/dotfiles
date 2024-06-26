return { -- Lightweight yet powerful formatter plugin for Neovim
    'stevearc/conform.nvim',
    config = function()
        local conform = require('conform')
        conform.setup({
            -- notify_on_error = false,
            format_on_save = function(bufnr)
                -- Disable with a global or buffer-local variable
                if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
                    return
                end
                return { timeout_ms = 500, lsp_fallback = true }
            end,
            formatters_by_ft = {
                blade = { 'blade-formatter' },
                css = { 'prettierd', 'prettier' },
                -- You can use a sub-list to tell conform to run *until* a formatter
                -- is found.
                javascript = { { 'prettierd', 'prettier' } },
                lua = { 'stylua' },
                php = { 'pint' },
                -- Conform can also run multiple formatters sequentially
                -- python = { "isort", "black" },
                yml = { 'yamlls' },
            },
        })

        vim.api.nvim_create_user_command('FormatDisable', function(args)
            if args.bang then
                -- FormatDisable! will disable formatting just for this buffer
                vim.b.disable_autoformat = true
            else
                vim.g.disable_autoformat = true
            end
        end, {
            desc = 'Disable autoformat-on-save(!)',
            bang = true,
        })

        vim.api.nvim_create_user_command('FormatEnable', function()
            vim.b.disable_autoformat = false
            vim.g.disable_autoformat = false
        end, {
            desc = 'Re-enable autoformat-on-save',
        })

        vim.api.nvim_create_user_command('FormatStatus', function()
            if vim.b.disable_autoformat == true then
                vim.notify('Formatter is disabled', vim.log.levels.WARN, { title = 'Buffer' })
            else
                vim.notify('Formatter is enabled', vim.log.levels.INFO, { title = 'Buffer' })
            end
            if vim.g.disable_autoformat == true then
                vim.notify('Formatter is disabled', vim.log.levels.WARN, { title = 'Global' })
            else
                vim.notify('Formatter is enabled', vim.log.levels.INFO, { title = 'Global' })
            end
        end, {
            desc = 'Check status for formatter',
        })
    end,
    keys = {
        {
            '<leader>ff',
            function()
                require('conform').format({ async = true, lsp_fallback = true })
            end,
            mode = { 'n', 'v' },
            desc = '[N]ormal: Format buffer, [V]isual: Format selection',
        },
    },
    init = function()
        vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
}
