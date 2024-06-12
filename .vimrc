set tabstop=4 " tab size
set shiftwidth=4
set number " line number
"set completeopt-=preview,longest,menuone " completion popup
set nowrap " no text wrap
set ai " auto indenting
set backspace=indent,eol,start " make that backspace key work the way it should
set laststatus=2 " make the last line where the status is two lines deep so you can see status always
set ruler " show cursor pos
set showmatch " show matching braces
set showmode " show the current mode
set nocompatible " be iMproved, required
"syntax on " default syntax highlighting
"colorscheme onehalfdark	" colorscheme
set hlsearch " highlights matches in search
set path+=usr/include/c++/10 " add c++ includes to path
set nofoldenable " disable folding

"let g:CommandTPreferredImplementation='lua'

if !has('nvim')
	set ttymouse=xterm2
endif

filetype off " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/autoload/plug.vim
call plug#begin()

"Plug 'Valloric/YouCompleteMe' " Completion window
Plug 'rstacruz/sparkup', {'rtp': 'vim/'} " HTML parser
Plug 'tpope/vim-fugitive' " Git wrapper
Plug 'dense-analysis/ale' " Syntax and error analysis and messages
Plug 'nvim-tree/nvim-tree.lua' " File system explorer
Plug 'nvim-lua/plenary.nvim' " Required by todo-comments
Plug 'folke/todo-comments.nvim' " Todo comment highlighting, view todos, etc.
Plug 'nvim-lualine/lualine.nvim' " Statusline (bottom bar)
Plug 'nvim-tree/nvim-web-devicons' " Icons for statusline
Plug 'shellRaining/hlchunk.nvim' " Braces/chunk highligher. Indent lines.
Plug 'MattesGroeger/vim-bookmarks' " Bookmark manager
Plug 'stevearc/aerial.nvim' " Symbols outline
Plug 'sakhnik/nvim-gdb' " GDB Debugger
Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' } " Treesitter
Plug 'eandrju/cellular-automaton.nvim' " make_it_rain or game_of_life (Useless (For funzies))
Plug 'themercorp/themer.lua' " Theme manager
Plug 'rush-rs/tree-sitter-asm' " Assembly grammar for treesitter
Plug 'neoclide/coc.nvim', {'branch': 'master', 'do': 'npm ci'}
Plug 'https://gitlab.com/yorickpeterse/nvim-window.git'

call plug#end() " required
filetype plugin on " required

let g:cpp_attributes_highlight = 1
let g:cpp_member_highlight = 1

let g:ale_fix_on_save = 1
let g:ale_sign_column_always = 1
let g:ale_linters = { 'cpp': ['clang'], 'c': ['gcc'] }
let g:ale_cpp_cc_options = "-std=c++20 -Wall"
let g:ale_pattern_options = { '.*\.asm': {'ale_enabled': 0 } } " Disable ale for .asm files

let g:coc_node_path = '/usr/local/bin/node'

"let g:clang_library_path='/usr/lib/llvm-13/lib/libclang-13.so.1'

nnoremap <C-n> :NvimTreeToggle<CR>
nnoremap <C-b> :AerialToggle<CR>

nnoremap <F2> :noh<CR>

inoremap <expr> <Tab> coc#pum#visible() ? coc#pum#next(1) : "\<Tab>"
inoremap <expr> <S-Tab> coc#pum#visible() ? coc#pum#prev(1) : "\<S-Tab>"

inoremap <expr> <cr> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"

nmap <silent> <leader>gd <Plug>(coc-definition)
nmap <silent> <leader>gr <Plug>(coc-references)
inoremap <silent><expr> <c-@> coc#refresh()
nmap <leader>rn <Plug>(coc-rename)

map <silent> , :lua require('nvim-window').pick()<CR>

command Wq wq

lua << EOF

local lastplace = vim.api.nvim_create_augroup("LastPlace", {})
vim.api.nvim_clear_autocmds({ group = lastplace })
vim.api.nvim_create_autocmd("BufReadPost", {
    group = lastplace,
    pattern = { "*" },
    desc = "remember last cursor place",
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

require'hlchunk'.setup{
	indent = {
		enable = false,
		chars = {
			"│",
			"¦",
			"┆",
			"┊"
		},
		style = {
			{ fg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Whitespace")), "fg", "gui") }
		}
	},
	chunk = {
		{ fg = "#806d9c" }, -- I hate hardcoding these, but I can't get anything else to work
		{ fg = "#806d9c" }
	},
	blank = { enable = false }
}

require'lualine'.setup{
	options = {
		icons_enabled = true,
		theme = 'auto',
		component_separators = { left = '|', right = '|'},
		section_separators = { left = '◣', right = '◢'},
		disabled_filetypes = {
			statusline = {},
			winbar = {},
		},
		ignore_focus = {},
		always_divide_middle = true,
		globalstatus = false,
		refresh = {
			statusline = 1000,
			tabline = 1000,
			winbar = 1000,
		}
	},
	sections = {
		lualine_a = {'mode'},
		lualine_b = {'filename', 'branch', 'diff'},
		lualine_c = {'diagnostics'},
		lualine_x = {'encoding', 'fileformat', 'filetype'},
		lualine_y = {'progress'},
		lualine_z = {'location'}
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = {},
		lualine_x = {},
		lualine_y = {},
		lualine_z = {}
	},
	tabline = {},
	winbar = {},
	inactive_winbar = {},
	extensions = {'fugitive', 'nerdtree', 'symbols-outline'}
}

require('nvim-treesitter.parsers').get_parser_configs().asm = {
    install_info = {
        url = 'https://github.com/rush-rs/tree-sitter-asm.git',
        files = { 'src/parser.c' },
        branch = 'main',
    }
}

require'nvim-treesitter.configs'.setup{
	ensure_installed = "all", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
	highlight = {
		enable = true              -- false will disable the whole extension
	},
	indent = {
		enable = true
	}
}

require"themer".setup{
	colorscheme = "onedark",
	styles = {
    	--["function"] = { style = 'italic' },
        --functionbuiltin = { style = 'italic' },
		--variable = { style = 'italic' },
		--variableBuiltIn = { style = 'italic' },
		--parameter  = { style = 'italic' },
		comment = { style = 'italic' },
		todo = { style = 'bold' }
	}
}

require'aerial'.setup{}

require'nvim-tree'.setup{
	git = {
		enable = true,
		ignore = false,
		timeout = 500
	}
}

EOF

