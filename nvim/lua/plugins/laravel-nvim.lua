-- Ease some things with Laravel projects
return {
    'adalessa/laravel.nvim',
    dependencies = {
        'nvim-telescope/telescope.nvim',
        'tpope/vim-dotenv',
        'MunifTanjim/nui.nvim',
        -- 'nvimtools/none-ls.nvim',
        'kevinhwang91/promise-async',
    },
    cmd = { 'Laravel' },
    keys = {
        { '<leader>la', ':Laravel artisan<cr>', desc = 'Open Laravel Artisan menu' },
        { '<leader>lc', ':Laravel commands<cr>', desc = 'Execute a user [c]ommand' },
        { '<leader>lf', ':Laravel related<cr>', desc = 'Show Laravel related files' },
        { '<leader>lh', ':Laravel history<cr>', desc = 'Show history of Laravel commands' },
        { '<leader>lm', ':Laravel make<cr>', desc = 'Available content to [m]ake' },
        { '<leader>lr', ':Laravel routes<cr>', desc = 'Show current routes of the project' },
        { '<leader>lR', ':Laravel resources<cr>', desc = 'Go to a resource of the project' },
    },
    event = { 'VeryLazy' },
    opts = {
        lsp_server = 'intelephense',
        ui = {
            nui_opts = {
                split = {
                    position = 'bottom',
                    win_options = {
                        signcolumn = 'no',
                    },
                },
                -- Maybe set the same window option for the popup?
            },
        },
        user_commands = {
            artisan = {
                ['db:fresh'] = {
                    cmd = { 'migrate:fresh', '--seed' },
                    desc = "Re-creates the db and seed's it",
                },
            },
            npm = {
                build = {
                    cmd = { 'run', 'build' },
                    desc = 'Builds the javascript assets',
                },
                dev = {
                    cmd = { 'run', 'dev' },
                    desc = 'Builds the javascript assets',
                },
            },
            composer = {
                autoload = {
                    cmd = { 'dump-autoload' },
                    desc = 'Dumps the composer autoload',
                },
            },
            sail = {
                start = {
                    cmd = { 'up', '-d' },
                    desc = 'Start Sail dettached',
                },
                stop = {
                    cmd = { 'stop' },
                    desc = 'Stop Sail',
                },
                build_no_cache = {
                    cmd = { 'build', '--no-cache' },
                    desc = 'Build Sail with no cache',
                },
            },
        },
    },
}
