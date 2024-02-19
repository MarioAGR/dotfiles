-- Automatically set the working directory to the project root.
return {
    'airblade/vim-rooter',
    init = function()
        -- Instead of this running every time we open a file, we'll ust run it once when Neovim starts
        vim.g.rooter_manual_only = 1
    end,
    config = function()
        vim.cmd('Rooter')
    end
}
