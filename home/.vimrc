"
"   Evan Stern's (G)vimrc
"

" Use vim settings rather than vi (who uses vi anymore?)
set nocompatible

" Ensure that PYTHONPATH is not set (this is a problem with jedi-vim)
:let $PYTHONPATH = ""

" Infect ourselves with plugin goodness!
filetype off                    " Force reloading *after* pathogen is loaded
execute pathogen#infect()
call pathogen#helptags()
filetype plugin indent on       " Enable plugin/indenting detection
syntax enable                   " Use syntax coloring

"======================================================================"
"   Pre-setup Initialization // Defaults                               "
"======================================================================"

" Do not load any plugins by default.
set noloadplugins

" Manually load the VIMRUNTIME plugins (NOT THE ONES IN THE ~/.vim/plugin
" folder)
runtime! plugin/*.vim

" List of plugins which have been loaded
let g:PluginList = []

" Set the default colorscheme.  It might be reset in another plugin
"colorscheme koehler

" Editing behavior {{{
set showmode                    " Show the current mode
set nowrap                      " Don't wordwrap, please.
set tabstop=4                   " Set tabs to 4 spaces
set softtabstop=4               " Allow deletion of the soft tabs
set expandtab                   " Expand tabs to spaces
set shiftwidth=4                " Set default tab to 4 (for auto-indenting)
set shiftround                  " Use multiple of shiftwidth when indenting with '<' and '>'
set backspace=indent,eol,start  " Allow backspaces over everything
set autoindent                  " Auto indenting
set smartindent                 " Smart indentation (remembers previous indent)
set number                      " Line numbers are on by default
set smartcase                   " When searching, ignore case unless a capital
set smarttab                    " Insert tabs according to shiftwidth not tabstop
set scrolloff=5                 " Keep 5 lines off edges of screen during scroll
set virtualedit=all             " Allow cursor to go where it shouldn't
set nolist                      " Don't show hidden characters by default
set mouse=a                     " Allways enable the mouse
set nohlsearch                  " Do not highlight search strings
set incsearch                   " Show the best match 'so far' while searching
set formatoptions=crqn          " c = Auto-Wrap comments to 'textwidth'
                                " r = Insert current comment leader after <CR>
                                " q = Allow formatting of comments with 'gq
                                " n = Recognize numbered lists during formatting

" F12 puts you into 'paste mode' that will let you paste text without it being
" autoindented. Super useful.
nnoremap <F12> :set invpaste paste?<CR>
set pastetoggle=<F12>

" Make scrolling a bit faster
nnoremap <C-e> 2<C-e>
nnoremap <C-y> 2<C-y>
" }}}

" Folding behavior {{{
set foldenable                  " Enable folding by default
set foldcolumn=2                " Add a fold column
set foldmethod=marker           " Look for the tripple-{ and } markers
set foldlevel=99                " Fold it all by default

" what can trigger a fold to open?
set foldopen=block,hor,insert,jump,mark,percent,quickfix,search,tag,undo
" }}}

" Editor layout {{{
set termencoding=utf-8
set encoding=utf-8
set lazyredraw                  " Don't update the display while executing macros
set laststatus=2                " Show the status line always.
set cmdheight=1                 " Command bar of height 1 (default)

 " Set the ruler format
set rulerformat=%20(line-%l\ col-%c%V\ %p%%%)
" }}}

" Editor behavior {{{
colorscheme candy               " This is from the color-scheme-sample-pack plugin
set background=dark             " Use a dark background
set hidden                      " Don't close buffers. Preserve history
set switchbuf=useopen           " Use open files if you can
set history=1000                " Remember lots of history (we have the memory for it!)
set undolevels=1000             " I undo a *LOT* of stuff, so this is helpful
set nobackup                    " Backup files are annoying
set noswapfile                  " I don't think I have ever used one of these in my life.
set wildmenu                    " Use bash-like completion syntax for commandline stuff
set wildignore=*.swp,*.pyc      " Ignore these during autocompletion
set visualbell                  " Silence the bell sound, flash screen instead.
set showcmd                     " Show partial commands
set nomodeline                  " Do not allow other files to modify this one
set magic                       " Allow regex in search strings
set tags=./tags;
set ruler                       " Show the cursor position in the status bar
" }}}


" System specific {{{
" MSWIN is *true* if we are in a windows environment
let s:MSWIN = has("win16") || has("win32") || has("win64")
                \ || has("win95") || has("win32unix")

" If VI is running in a windows or unix/linux environment, then the
" default lookup paths for various things must change accordingly.
if s:MSWIN
    let s:Path = $VIMRUNTIME.'/'
else
    let s:Path = $HOME.'/.vim/'
endif
let $VIMSTORE=s:Path
let s:PluginPath = s:Path.'plugin/'

" The '.setwin.vim' file is used only in GVIM.  It is used to set the
" size and position of the window after it has been closed and
" re-opened.  Doing this allows the newly opened window to reposition
" itself to the same place as the last window.
let g:SetWin = s:Path.'.setwin.vim'

" GUI is *true* if we are in GVIM
let s:GUI = has("gui_running")

" AU will be *true* if this version of (G)VIM was compiled with the
" autocommand feature enabled.
let s:Au = has("autocmd")

" MENU will be *true* if this version of (G)VIM was compiled with
" support for the 'menu' feature
let s:Menu = has("menu")
" }}}

" Plugin Specific {{{
" Tlist
if s:MSWIN
    let Tlist_Ctags_Cmd='C:\\unix\\bin\\ctags.exe'
else
    let Tlist_Ctags_Cmd='/usr/bin/ctags'
endif
let Tlist_Display_Prototype= 1
let s:TagListOn = executable(Tlist_Ctags_Cmd)
noremap     <silent>    <F11>   <ESC><ESC>:Tlist<CR>
inoremap    <silent>    <F11>   <ESC><ESC>:Tlist<CR>
" }}}

" Functions {{{
" SaveXY {{{
"======================================================================"
"                                                                      "
"      Function: SaveXY                                                "
"                                                                      "
"   Description: Creates or modifies a file called .setwin.vim which   "
"                contains commands to set GVIM's window's size and     "
"                position.                                             "
"                                                                      "
"======================================================================"
function! SaveXY()

    " Get the X and Y position of the window
    let x0=getwinposx()
    let y0=getwinposy()

    " Redirect the following command's output to the .setwin.vim file
    " by overwriting it (!).
    redir! > $VIMSTORE/setwin.vim
    silent echo "winpos" x0 y0
    silent echo "set lines=" . &lines
    silent echo "set columns=" . &columns
    redir END

endfunction
" }}}

" EnablePlugin {{{
"======================================================================"
"                                                                      "
"      Function: EnablePlugin                                          "
"                                                                      "
"   Description: Checks for the existance of a plugin and enables it   "
"                if possible.                                          "
"                                                                      "
"                The s:PluginPath directory is used as the base        "
"                directory when looking for the plugin to enable.      "
"                                                                      "
"                Adds the filename of the plugin to PluginList which   "
"                used when setting up specific options for plugins.    "
"                                                                      "
"          Args: <string> plugin -- The name of the plugin             "
"                                                                      "
"======================================================================"
function! EnablePlugin( plugin )

    if count( g:PluginList, a:plugin ) != 0
        return 0
    endif

    if filereadable( s:PluginPath.a:plugin )
        exe "source ".s:PluginPath.a:plugin
        let g:PluginList = add( g:PluginList, a:plugin )
    else
        echohl Error
        echo "Plugin ".s:PluginPath.a:plugin." was not read."
        echohl None
    endif

endfunction
" }}}

" ConfigurePluginSettings {{{
"======================================================================="
"                                                                       "
"      Function: ConfigurePluginSettings                                "
"                                                                       "
"   Description: Configures the settings for a specific plugin.         "
"                In order to use this method effectively, any new plugin"
"                must have its settings taken care of inside its own if "
"                statement.                                             "
"                This means that any time a new plugin is added, a new  "
"                section should be written here.                        "
"                                                                       "
"          Args: <string> plugin -- The name of the plugin              "
"                                                                       "
"======================================================================="
function! ConfigurePluginSettings( plugin )

    "==================================================================
    " NERD Commenter
    if a:plugin == 'NERD_commenter.vim'

    "
    "==================================================================

    "==================================================================
    " Alternate Header / Source Files ( a.vim )
    elseif a:plugin == 'a.vim'

    "
    "==================================================================

    "==================================================================
    " TAG LIST (taglist.vim)
    elseif a:plugin == 'taglist.vim'
        if s:MSWIN
            let Tlist_Ctags_Cmd='C:\\unix\\bin\\ctags.exe'
        else
            let Tlist_Ctags_Cmd='/usr/bin/ctags'
        endif
        let Tlist_Display_Prototype= 1
        let s:TagListOn = executable(Tlist_Ctags_Cmd)
        noremap     <silent>    <F11>   <ESC><ESC>:Tlist<CR>
        inoremap    <silent>    <F11>   <ESC><ESC>:Tlist<CR>
    "
    "==================================================================

    "==================================================================
    " NERD Tree (NERD_tree.vim)
    elseif a:plugin == 'NERD_tree.vim'

        noremap     <silent>    <F8>    <ESC><ESC>:NERDTreeToggle<CR>
        inoremap    <silent>    <F8>    <ESC><ESC>:NERDTreeToggle<CR>

    "
    "==================================================================

    "==================================================================
    " CSUPPORT (c.vim)
    elseif a:plugin == 'c.vim'
        let g:C_FormatDate      = '%D'
        let g:C_FormatYear      = '%Y'
        "let g:C_AuthorName        = 'E Stern'
        "let g:C_AuthorRef         = ''
        "let g:C_Email             = 'estern@wms.com'
        "let g:C_Company           = 'WMS'
        "let g:C_CopyrightHolder   = 'WMS'

    "
    "==================================================================

    "==================================================================
    " PROJECT (project.vim)
    elseif a:plugin == 'project.vim'

    "
    "==================================================================

    "==================================================================
    " COLOR THEMES (themes.vim)
    elseif a:plugin == 'themes.vim'

        colorscheme koehler

    "
    "==================================================================

    "==================================================================
    " COLOR SAMPLE PACK (color_sample_pack.vim)
    elseif a:plugin == 'color_sample_pack.vim'

        colorscheme candy

    "
    "==================================================================

    "==================================================================
    "
    elseif a:plugin == 'bufexplorer.vim'

    "
    "==================================================================

    endif

endfunction
" }}}

" Enable plugins {{{
"call EnablePlugin('taglist.vim')
"call EnablePlugin('showmarks.vim')
"call EnablePlugin('themes.vim')
"call EnablePlugin('c.vim')
"call EnablePlugin('a.vim')
"call EnablePlugin('doxygen-support.vim')
"call EnablePlugin('cscope_maps.vim')
"call EnablePlugin('project.vim')
"call EnablePlugin('bufexplorer.vim')
"call EnablePlugin('FeralToggleCommentify.vim')
"call EnablePlugin('screen.vim')
"call EnablePlugin('color_sample_pack.vim')
"call EnablePlugin('NERD_tree.vim')
"call EnablePlugin('xml.vim')
"call EnablePlugin('NERD_commenter.vim')
"call EnablePlugin('vcscommand.vim')
"call EnablePlugin('vcsbzr.vim')
"call EnablePlugin('vcscvs.vim')
"call EnablePlugin('vcsgit.vim')
"call EnablePlugin('vcshg.vim')
"call EnablePlugin('vcssvk.vim')
"call EnablePlugin('vcssvn.vim')
"call EnablePlugin('AlignPlugin.vim')

" Turn on all settings for the enabled plugins.  Any plugin-config should be
" done inside the ConfigurePluginSettings function
"
"for plugin in g:PluginList
"    call ConfigurePluginSettings(plugin)
"endfor
" }}}



" Filetype Specific {{{
if s:Au
    augroup filetype

        "===
        " Try to read a skel file for this filetype
        " Set up <ctrl-P> for going to next highlighted %VAR%
        "========
        "autocmd BufNewFile * call LoadTemplate()
        "nnoremap <c-p> /%\u.\{-1,}%<cr>c/%/e<cr>
        "inoremap <c-p> <ESC>/%\u.\{-1,}%<cr>c/%/e<cr>

        "===
        " Remove trailing whitespace
        "========
        autocmd BufWritePre * :%s/\s\+$//e

        "====
        " Text Files
        "=========
        autocmd BufRead *.txt set textwidth=72

        "====
        " PSQL temp files
        "========
        autocmd BufRead,BufNewFile *\.edit\.* set filetype=sql

        "====
        " Perl Files
        "=========
        autocmd BufRead *.pl
                \ vmap <silent> <F9> :s/^.\\|^$/#\ /g<CR> |
                \ vmap <silent> <F10> :s/\(^\ *\)#/\1/g<CR>

        "===
        " Python Files
        "=========
        autocmd FileType python let PYTHONPATH='/usr/lib/python2.5'
"        autocmd FileType python setlocal omnifunc=pysmell#Complete
"        autocmd BufNewFile,BufRead *.py call EnablePlugin("pysmell.vim")
"        autocmd BufNewFile,BufRead *.py call EnablePlugin("pydoc.vim")
"        autocmd FileType python call EnablePlugin("python.vim")
"        autocmd BufNewFile,BufRead *.py call EnablePlugin("python_fold.vim")
"        autocmd BufNewFile,BufRead *.py exe "source ".s:PluginPath."python_fold.vim"
        autocmd FileType python inoremap <Nul> <C-x><C-o>
        autocmd FileType python set formatoptions=cqro
        autocmd FileType python set textwidth=79
        "autocmd FileType python let g:pysmell_matcher='case-insensitive'
        autocmd Filetype python set tabstop=4

        "====
        " Set XML Filetype on certain files
        "=========
        "au BufRead,BufNewFile *.scs,*.res,*.tpscene setfiletype xml

        "====
        " Set XHTML on turbogears .kid files
        "========
        autocmd BufRead,BufNewFile *.kid
                \ setfiletype xhtml |
                \ set fo-=c


        "====
        " C++ files
        "=========
        ""Set the colorscheme for cpp file editing
        "autocmd BufWritePost,BufFilePost,BufNewFile,BufRead
        "        \ *.cpp,*.h let psc_style='defdark' | colorscheme koehler
        "" Get doxygen.vim from:
        "" http://www.vim.org/scripts/script.php?script_id=5
        "autocmd BufEnter
        "        \ *.cpp,*.h source $VIMSTORE/syntax/doxygen.vim
        "" Get c.vim from:
        "" http://www.vim.org/scripts/script.php?script_id=21
        "autocmd BufNewFile,BufRead *.cpp,*.h call EnablePlugin("c.vim")
        "" Set comment string
        "autocmd BufNewFile,BufRead,BufFilePost,BufWritePost
        "        \ *.cpp,*.h set comments=s1:/*,mb:*,ex:*/,://
        "" Set textwidth to 78
        "autocmd BufNewFile,BufRead,BufFilePost,BufWritePost
        "        \ *.cpp,*.h set textwidth=78
        "" Set c style indenting
        "autocmd BufNewFile,BufRead,BufFilePost,BufWritePost
        "        \ *.cpp,*.h set cindent |
        "        \ set cino=:0,b1,g0
        "" Set Omnicpp settings
        "autocmd BufNewFile,BufRead *.cpp,*.h
        "        \ nmap <F12> :!ctags -R --c++-kinds=+p --fields=+iaS --extra=+q .<CR> |
        "        \ let OmniCpp_NamespaceSearch=2 |
        "        \ let OmniCpp_ShowPrototypeInAbbr=1 |
        "        \ let OmniCpp_DefaultNamespaces=["std", "_GLIBCXX_STD"] |
        "        \ let OmniCpp_MayCompleteScope=1 |
        "        \ let OmniCpp_SelectFirstItem=2 |
        "        \ let OmniCpp_DisplayMode = 1 |
        "        \ source ${HOME}/.vim/.tagloader.vim |
        "        \ set completeopt=menu,preview
        "autocmd BufNewFile,BufRead *.cpp,*.h
        "        \ inoremap [ []<Left> |
        "        \ vnoremap [ s[]<Esc>P<Right>%
        "" Close the helper window for omnicpp when done
        "autocmd CursorMovedI *.cpp,*.h if pumvisible() == 0|pclose|endif
        "autocmd InsertLeave *.cpp,*.h if pumvisible() == 0|pclose|endif
        "
        ""====
        "" Makefile
        ""=========
        "autocmd BufWritePost,BufFilePost,BufNewFile,BufRead,BufReadPost
        "        \ Makefile set noexpandtab

        "====
        " Vim Files
        "=========
        autocmd BufRead,BufNewFile *.vim set comments=fb:-,:\"
        autocmd BufRead,BufNewFile *.vim set textwidth=78

        "====
        " Javascript
        "========
        autocmd BufRead,BufNewFile *.js set ft=javascript syntax=javascript
        autocmd BufRead,BufNewFile *.js set comments=sr:/*,mb:*,ex:*/,://
"        autocmd BufRead,BufNewFile *.js call EnablePlugin('MyJavaScriptLint.vim')

        "====
        " JSON files
        "========
        autocmd BufRead, BufNewFile *.json set ft=javascript syntax=javascript

        "====
        " Make sure that there fo does not have the t option
        "========
        autocmd Filetype * set fo-=t

        "==
        " RST files
        "========
        autocmd FileType rst
            \ set formatoptions=want |
            \ set textwidth=82 |
            \ set nowrap

    augroup END

    " Jump to the last cursor position when opening a new buffer
    autocmd BufReadPost *
        \ if line("'\"") > 0 && line("'\"") <= line("$") |
        \   exe "normal g'\"" |
        \ endif
endif
" }}}

" Useful mappings {{{
nmap <Leader>s :source $MYVIMRC <CR>
nmap <Leader>e :vsplit $MYVIMRC <CR>
vmap sb "zdi<b><C-R>z</b><ESC>
vmap sdi "zdi<div><C-R>z</div><ESC>
vmap ssp "zdi<span><C-R>z</span><ESC>
vmap scc "zdi<!--<C-R>z--><ESC>
inoremap <Leader>d <ESC>:r! date +\%m/\%d/\%Y\ \%H:\%M <CR>i
" }}}

" Entry and Exit {{{
"" When GVIM is exited, call SaveXY() and when GVIM is entered into again
"" read the .setwin.vim file and execute the commands to set the window
"" back to the correct position again.
if s:Au && s:GUI
    autocmd VimLeave * call SaveXY()
    autocmd VimEnter * if filereadable( $VIMSTORE."/setwin.vim" )
                     \ | source $VIMSTORE/setwin.vim
                     \ | endif
endif
" }}}

