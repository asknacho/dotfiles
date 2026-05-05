local function safe_nerdtree_toggle()
  if #vim.api.nvim_tabpage_list_wins(0) == 1 and vim.bo.filetype == "nerdtree" then
    vim.notify("NERDTree is the only window; not closing", vim.log.levels.WARN)
    return
  end
  vim.cmd("NERDTreeToggle")
end

return {
  "scrooloose/nerdtree",
  dependencies = {
    "Xuyuanp/nerdtree-git-plugin",
  },
  keys = {
    { "<leader>n",  safe_nerdtree_toggle,        desc = "Toggle NERDTree" },
    { "<leader>nf", "<ESC>:NERDTreeFind<cr>",    desc = "Find in NERDTree" },
  },
  config = function()
    local function selected_path()
      local ok, path = pcall(vim.api.nvim_eval, "g:NERDTreeFileNode.GetSelected().path.str()")
      if not ok or type(path) ~= "string" or path == "" then
        return nil
      end
      return path
    end

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "nerdtree",
      callback = function(args)
        vim.keymap.set("n", "yp", function()
          local path = selected_path()
          if not path then
            vim.notify("No NERDTree node under cursor", vim.log.levels.WARN)
            return
          end
          vim.fn.setreg("+", path)
          vim.fn.setreg('"', path)
          vim.notify("Copied: " .. path)
        end, { buffer = args.buf, desc = "Copy full path" })

        vim.keymap.set("n", "yr", function()
          local path = selected_path()
          if not path then
            vim.notify("No NERDTree node under cursor", vim.log.levels.WARN)
            return
          end
          local rel = vim.fn.fnamemodify(path, ":.")
          vim.fn.setreg("+", rel)
          vim.fn.setreg('"', rel)
          vim.notify("Copied: " .. rel)
        end, { buffer = args.buf, desc = "Copy relative path" })
      end,
    })
  end,
}
