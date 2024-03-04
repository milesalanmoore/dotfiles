local plugins = {
  {
    "jalvesaq/Nvim-R",
    lazy=false
  },
  {
    "pappasam/nvim-repl",
    lazy=false,
    init = function()
      vim.g["repl_filetype_commands"] = {
        javascript = "node",
        python = "ipython --no-autoindent"
      }
    end,
    keys = {
      { "<leader>rt", "<cmd>ReplToggle<cr>", desc = "Toggle nvim-repl" },
      { "<leader>rc", "<cmd>ReplRunCell<cr>", desc = "nvim-repl run cell" },
    },
  }
}

return plugins
