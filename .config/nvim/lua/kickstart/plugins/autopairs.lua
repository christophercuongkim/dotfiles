-- autopairs
-- https://github.com/windwp/nvim-autopairs

return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  -- No cmp integration: blink.cmp is the completion engine and inserts function
  -- brackets itself (completion.accept.auto_brackets). Pulling in nvim-cmp just
  -- for the old confirm_done hook would load a dead second engine.
  config = function()
    require('nvim-autopairs').setup {}
  end,
}
