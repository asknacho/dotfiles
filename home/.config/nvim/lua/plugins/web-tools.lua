return {
  "ray-x/web-tools.nvim",
  ft = { "html", "css", "javascript", "typescript", "hurl" },
  cmd = {
    "BrowserSync",
    "BrowserOpen",
    "BrowserPreview",
    "BrowserRestart",
    "BrowserStop",
    "TagRename",
    "HurlRun",
    "Npm",
    "Yarn",
    "Pnpm",
    "Npx",
    "Node",
    "JobStop",
  },
  config = function()
    require("web-tools").setup({
      keymaps = {
        rename = nil,
        repeat_rename = ".",
      },
      hurl = {
        show_headers = false,
        floating = false,
        json5 = false,
        formatters = {
          json = { "jq" },
          html = { "prettier", "--parser", "html" },
        },
      },
    })

    vim.keymap.set("n", "<leader>bp", "<cmd>BrowserPreview<cr>", { desc = "Browser: Start preview" })
    vim.keymap.set("n", "<leader>bP", "<cmd>BrowserStop<cr>", { desc = "Browser: Stop preview" })
    vim.keymap.set("n", "<leader>br", "<cmd>BrowserRestart<cr>", { desc = "Browser: Restart preview" })
  end,
}
