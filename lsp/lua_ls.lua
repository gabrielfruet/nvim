vim.lsp.config('lua_ls', {
    settings = {
        Lua = {
            runtime = {
                version = 'LuaJIT',
                path = {
                    '?/init.lua',
                    '?.lua'
                }
            },
            workspace = {
                library = {
                    '/usr/share/nvim/runtime/lua',
                    '/usr/share/nvim/runtime/lua/lsp',
                    '/usr/share/awesome/lib'
                }
            },
            completion = {
                enable = true,
            },
            diagnostics = {
                enable = true,
                globals = { 'vim', 'awesome', 'client', 'root' }
            },
            telemetry = {
                enable = false
            }
        }
    }
})
