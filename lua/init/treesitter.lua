vim.cmd('packadd nvim-treesitter')
vim.cmd('packadd nvim-treesitter-context')
vim.cmd('packadd rainbow-delimiters.nvim')

require'nvim-treesitter.configs'.setup {
	ensure_installed = {
    "c",
    "c_sharp",
    "cmake",
    "commonlisp",
    "cpp",
    "dockerfile",
    "glsl",
    "go",
    "graphql",
    "hlsl",
    "html",
    "http",
    "java",
    "javascript",
    "json",
    "lua",
    "luadoc",
    "markdown",
    "nu",
    "python",
    "toml",
    "typescript",
    "vim",
    "vimdoc",
    "wgsl",
    "yaml",
  },

	highlight = {
		-- false will disable the whole extension
		enable = true,

		-- list of language that will be disabled
		disable = {'cpp', 'rust'},
	},

	textobjects = {
		select = {
			enable = true,
			keymaps = {
				-- You can use the capture groups defined in textobjects.scm
				["af"] = "@function.outer",
				["if"] = "@function.inner",
				["ac"] = "@class.outer",
				["ic"] = "@class.inner",
			}
		},

		move = {
			enable = true,
			set_jumps = true, -- whether to set jumps in the jumplist
			goto_next_start = {
				["]m"] = "@function.outer",
				["]]"] = "@class.outer",
			},
			goto_next_end = {
				["]M"] = "@function.outer",
				["]["] = "@class.outer",
			},
			goto_previous_start = {
				["[m"] = "@function.outer",
				["[["] = "@class.outer",
			},
			goto_previous_end = {
				["[M"] = "@function.outer",
				["[]"] = "@class.outer",
			},
		},
	},

  refactor = {
		-- highlight_definitions = { enable = true },
		-- highlight_current_scope = { enable = true },
		smart_rename = {
			enable = true,
			keymaps = {
			smart_rename = "<leader>tr",
			},
		},

		navigation = {
			enable = true,
			keymaps = {
				goto_definition_lsp_fallback = "gd",
				list_definitions = "<leader>tD",
				list_definitions_toc = "<leader>tO",
				goto_next_usage = "<a-*>",
				goto_previous_usage = "<a-#>",
			},
		},
	},

  autotag = {
    enable = true,
  }
}

