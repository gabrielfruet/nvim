vim.lsp.enable({ "basedpyright", "lua_ls", "bashls", "cmake", "dockerls" })
vim.lsp.enable('ruff', false)

-- This strips out &nbsp; and some ending escaped backslashes out of hover
-- strings because the pyright LSP is... odd with how it creates hover strings.
local hover = function(_, result, ctx, config)
    if not (result and result.contents) then
        return vim.lsp.handlers.hover(_, result, ctx, config)
    end
    if type(result.contents) == "string" then
        local s = string.gsub(result.contents or "", "&nbsp;", " ")
        s = string.gsub(s, [[\\\n]], [[\n]])
        result.contents = s
        return vim.lsp.handlers.hover(_, result, ctx, config)
    else
        local s = string.gsub((result.contents or {}).value or "", "&nbsp;", " ")
        s = string.gsub(s, "\\\n", "\n")
        result.contents.value = s
        return vim.lsp.handlers.hover(_, result, ctx, config)
    end
end

-- rest of lsp config goes here
-- this get passed into lspconfig.setup
--  or server:setup_lsp() from nvim-lsp-installer
local lsp_setup_config = {
    handlers = {
        ["textDocument/hover"] = vim.lsp.with(hover),
    },
}
