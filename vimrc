set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
"Plugin 'tpope/vim-fugitive'
" plugin from http://vim-scripts.org/vim/scripts.html
"Plugin 'L9'
" Git plugin not hosted on GitHub
"Plugin 'git://git.wincent.com/command-t.git'
" git repos on your local machine (i.e. when working on your own plugin)
"Plugin 'file:///home/gmarik/path/to/plugin'
" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
"Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
" Install L9 and avoid a Naming conflict if you've already installed a
" different version somewhere else.
"Plugin 'ascenator/L9', {'name': 'newL9'}

Plugin 'davidhalter/jedi-vim'
Plugin 'scrooloose/syntastic'
Plugin 'scrooloose/nerdtree'
Plugin 'tpope/vim-fugitive'
Plugin 'Lokaltog/powerline', {'rtp': 'powerline/bindings/vim/'}
Plugin 'aklt/plantuml-syntax'
Plugin 'pangloss/vim-javascript'
Plugin 'mxw/vim-jsx'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line
let python_hightlight_all=1
syntax on

" Enable code styling in markdown
let g:markdown_fenced_languages = ['html', 'python', 'bash=sh', 'json', 'javascript', 'yaml']

" Set the max line length for pylint
let g:syntastic_python_pylint_post_args="--max-line-length=120"
" let g:syntastic_python_flake8_args='--ignore=E501'
let g:syntastic_python_python_exec = 'python3'
let g:syntastic_python_pylint_exec = 'pylint3'
let g:syntastic_python_checkers = ['python', 'pylint3', 'flake8']
let g:syntastic_javascript_checkers = ['eslint']
let g:syntastic_aggregate_errors = 1


" Nerd tree hide files
let NERDTreeIgnore=['\.pyc$', '\~$'] "ignore files in NERDTree
map <C-n> :NERDTreeToggle


set nu
set mouse=a

set laststatus=2

source $VIMRUNTIME/mswin.vim

set wildmode=longest,list,full
set wildmenu

" Deal with tabs and specials for files
set tabstop=4
set expandtab
set shiftwidth=4

" Highlight search results
set hlsearch

" Override indent for yaml and html
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType html setlocal ts=2 sts=2 sw=2 expandtab

vmap <Tab> >gv
vmap <S-Tab> <gv

" Strip trailing whitespace on hitting F4
fun! <SID>StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    keepp %s/\s\+$//e
    call cursor(l, c)
endfun

map <F6> :silent call <SID>StripTrailingWhitespaces()<cr>

" Show syntastic errors on hitting F8
map <F8> :Errors<cr>

" Controls tabbing
map <A-up> :tabr<cr>
map <A-down> :tabl<cr>
map <A-left> :tabp<cr>
map <A-right> :tabn<cr>
map <A-P> :tabnew<cr>
