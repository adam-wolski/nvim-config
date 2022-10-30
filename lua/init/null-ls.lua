require("null-ls").setup({
  sources = {
    require("null-ls").builtins.diagnostics.vale.with({
      extra_args = {"--ignore-syntax"}
    }),
  },
})
