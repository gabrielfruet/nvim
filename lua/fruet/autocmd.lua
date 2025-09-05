vim.api.nvim_create_autocmd('TextYankPost', {
    group=vim.api.nvim_create_augroup('highlighted_yank_group', {clear=true}),
    callback=function ()
        vim.highlight.on_yank{higroup = 'IncSearch', timeout=1000}
    end
})

vim.api.nvim_create_autocmd('FileType', {
    pattern = 'qf',
    callback = function()
        vim.api.nvim_buf_set_keymap(0, 'n', 'q', ':cclose<CR>:lclose<cr>', { noremap = true, silent = true })
    end
})
