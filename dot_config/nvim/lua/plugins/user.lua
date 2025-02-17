return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "bash",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
        "tsx",
        "typescript",
        "vim",
        "yaml",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      ---@type lspconfig.options
      servers = {
        -- pyright will be automatically installed with mason and loaded with lspconfig
        pyright = {},
      },
    },
  },
  {
    "Vigemus/iron.nvim",
    cmd = "IronRepl",
    main = "iron.core",
    ft = { "r", "rmd", "python", "julia" },
    opts = function()
      local view = require("iron.view")
      -- Remove extra <CR> when sending lines to R console
      local bracketed_paste_radian = function(lines)
        local open_code = "\27[200~"
        local close_code = "\27[201~"
        local cr = "\13"
        if #lines == 1 then
          return { lines[1] .. cr }
        else
          local new = { open_code .. lines[1] }
          for line = 2, #lines do
            table.insert(new, lines[line])
          end

          table.insert(new, close_code)
          return new
        end
      end
      return {
        config = {
          highlight_last = false,
          scratch_repl = true,
          close_window_on_exit = true,
          repl_definition = {
            r = {
              command = { "radian" },
              format = bracketed_paste_radian,
            },
            rmd = {
              command = { "radian" },
              format = bracketed_paste_radian,
            },
            qmd = {
              command = { "radian" },
              format = bracketed_paste_radian,
            },
          },
          repl_open_cmd = {
            view.split.vertical.rightbelow("%40"), -- cmd_1: open a repl to the right
            view.split.rightbelow("%25"), -- cmd_2: open a repl below
          },
        },
        keymaps = {
          toggle_repl_with_cmd_1 = "<space>rv",
          toggle_repl_with_cmd_2 = "<space>rh",
          send_motion = "<space>sc",
          send_until_cursor = "<space>su",
          send_code_block_and_move = "<space>sn",
          visual_send = "<space>sc",
          send_file = "<space>sf",
          send_line = "<space>sl",
          send_mark = "<space>sm",
          mark_motion = "<space>mc",
          mark_visual = "<space>mc",
          remove_mark = "<space>md",
          cr = "<space>s<cr>",
          interrupt = "<space>s<space>",
          exit = "<space>sq",
          clear = "<space>cl",
        },
        -- If the highlight is on, you can change how it looks
        -- For the available options, check nvim_set_hl
        highlight = {
          italic = true,
        },
        ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
      }
    end,
  },
}
