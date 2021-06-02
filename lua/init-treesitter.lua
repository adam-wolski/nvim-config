require'nvim-treesitter.configs'.setup {
	-- one of "all", "maintained" (parsers with maintainers), or a list of languages
	ensure_installed = "maintained", 

	highlight = {
		-- false will disable the whole extension
		enable = true,              

		-- list of language that will be disabled
		disable = {},  
	},

	rainbow = {
		enable = true,
		-- Highlight also non-parentheses delimiters, boolean or table: lang -> boolean
		extended_mode = true, 
		-- Do not enable for files with more than 1000 lines, int
		max_file_lines = 1000, 
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
				list_definitions = "gD",
				list_definitions_toc = "gO",
				goto_next_usage = "<a-*>",
				goto_previous_usage = "<a-#>",
			},
		},
	},
}
