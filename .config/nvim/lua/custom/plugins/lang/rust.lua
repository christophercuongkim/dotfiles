return {
  {
    'mrcjkb/rustaceanvim',
    -- Track the 8.x line so patch/minor fixes land without a breaking bump.
    version = '^8',
    -- This plugin implements proper lazy-loading (see :h lua-plugin-lazy).
    -- No need for lazy.nvim to lazy-load it.
    lazy = false,
  },
}
