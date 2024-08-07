-- Set lualine as statusline
return {
    'nvim-lualine/lualine.nvim',
    config = function()
        local dbui = {
            filetypes = { 'dbui' },
            sections = {
                lualine_a = {
                    'mode',
                },
                lualine_b = {
                    'filename',
                    'searchcount',
                },
            },
        }
        require('lualine').setup({
            options = {
                icons_enabled = true,
                component_separators = '|',
                section_separators = '',
            },
            sections = {
                lualine_a = {
                    'mode',
                },
                lualine_b = {
                    'branch',
                    'diff',
                    '" " .. tostring(#vim.tbl_keys(vim.lsp.buf_get_clients()))',
                    { 'diagnostics', sources = { 'nvim_diagnostic' } },
                },
                lualine_c = {
                    { 'filename', path = 1 },
                    'searchcount',
                },
                lualine_x = {
                    'filetype',
                    { 'encoding', show_bomb = true },
                    'fileformat',
                },
                lualine_y = {
                    '(vim.bo.expandtab and "␠ " or "⇥ ") .. " " .. vim.bo.shiftwidth',
                },
                lualine_z = {
                    'location',
                    'progress',
                },
            },
            extensions = {
                'lazy',
                'mason',
                'nvim-tree',
                dbui,
            },
        })
    end,
}
