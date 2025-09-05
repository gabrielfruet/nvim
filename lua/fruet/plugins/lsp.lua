return {
    {
        'onsails/lspkind-nvim',
        config = function ()
            local lspkind = require('lspkind')
            lspkind.init{
                symbol_map={
                    Copilot = "",
                }
            }
        end
    }
}
