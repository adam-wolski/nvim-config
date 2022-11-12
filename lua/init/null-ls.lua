local null_ls = require("null-ls")

null_ls.setup({
  sources = {
    null_ls.builtins.code_actions.gitsigns,
    null_ls.builtins.diagnostics.vale.with({
      extra_args = {"--ignore-syntax"}
    }),
  },
})
