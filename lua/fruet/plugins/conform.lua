return {
    'stevearc/conform.nvim',
    opts = {
        formatters_by_ft = {
            python = { "ruff_fix", "ruff_format" },
            cpp = { "clang_format" }, -- external clang-format
            c = { "clang_format" },
        },
        format_on_save = function(bufnr)
            -- Check for a .no-format file in the current directory or any parent directory
            if vim.fn.findfile(".no-format", ".;") ~= "" then
                -- If .no-format is found, disable format on save
                return
            end

            -- Default behavior: format with a timeout and LSP fallback
            return { timeout_ms = 500, lsp_fallback = true }
        end,
    },
}
