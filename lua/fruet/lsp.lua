vim.lsp.enable({ "basedpyright", "lua_ls", "bashls", "cmake", "dockerls" })
vim.lsp.enable('ruff', false)

-- This strips out &nbsp; and some ending escaped backslashes out of hover
-- strings because the pyright LSP is... odd with how it creates hover strings.
-- local hover = function(result, ctx)
--     if not (result and result.contents) then
--         return
--     end
--     if type(result.contents) == "string" then
--         local s = string.gsub(result.contents or "", "&nbsp;", " ")
--         s = string.gsub(s, [[\\\n]], [[\n]])
--         result.contents = s
--     else
--         local s = string.gsub((result.contents or {}).value or "", "&nbsp;", " ")
--         s = string.gsub(s, "\\\n", "\n")
--         result.contents.value = s
--     end
--     return vim.lsp.handlers.hover(result, ctx)
-- end
--
-- vim.lsp.set_handler("hover", hover)
