-- Function to set bg to fully transparent. Can't figure out how to scale alpha.
-- Commented out for now.
function SetTransparency()
        vim.api.nvim_set_hl(0, "Normal", { bg = 'none'})
        vim.api.nvim_set_hl(0, "NormalFloat", { bg = 'none' }
end
  -- SetTransparency()

  
