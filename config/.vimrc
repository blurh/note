" 编码格式
set encoding=utf-8
" 不自动缩进
set noautoindent
" 设置自动缩进的单位. 设置 = 4 之后 >> 缩进四个空格
set shiftwidth=4
" 手工折叠
:set foldmethod=manual
" 设置 tab 长度
set tabstop=4
" 设置 js 文件缩进
au BufRead *.\(js\|html\|css\|jsx\) set shiftwidth=2 tabstop=2 nu
au BufRead *.\(\|yml\|yaml\) set shiftwidth=2 tabstop=2 cuc
" 设置空格替换制表符
set expandtab
" 查找高亮
set hlsearch
" 语法高亮
syntax on
" 允许使用退格键
set backspace=eol,start,indent " eol 行开头, indent 缩进, start 光标前位置
" 屏蔽输入错误提示声音
set noeb
" 光标移动到buffer的顶部和底部时保持 2 行距离
set scrolloff=2
" 命令模式 tab 补全
set wildmenu
" 禁用翻页键
imap <PageUp> <NOP>
nmap <PageUp> <NOP>
imap <PageDown> <NOP>
nmap <PageDown> <NOP>
" 支持输入状态下 Ctrl + b/f 左右移动
imap <C-b> <Esc>i
imap <C-f> <Esc>la
" 注释 " Shift + 33, Ctrl + /
nmap ## :s/\(^\s*\)\(\S\)/\1# \2/<CR>:noh<CR><C-o>
vmap ## :s/\(^\s*\)\(\S\)/\1# \2/<CR>:noh<CR>
nmap <C-_> :s/\(^\s*\)\(\S\)/\1\/\/ \2/<CR>:noh<CR><C-o>
vmap <C-_> :s/\(^\s*\)\(\S\)/\1\/\/ \2/<CR>:noh<CR>
vmap <C-?> :s/^/ * /<CR>o */<Esc><C-o><S-o>/* <Esc>:noh<CR>
" 取消注释
nmap <C-\> :s/\(^\s*\)\(\/\/\s\?\)/\1/<CR>:noh<CR><C-o>
vmap <C-\> :s/\(^\s*\)\(\/\/\s\?\)/\1/<CR>:noh<CR>
vmap <leader>8 :s/\(\(^ \)\\|\(\/\)\)\*\(\/\\| \)//<CR>:noh<CR>
nmap <leader>3 :s/\(^\s*\)\(\#\s\?\)/\1/<CR>:noh<CR><C-o>
vmap <leader>3 :s/\(^\s*\)\(\#\s\?\)/\1/<CR>:noh<CR>
" 即时搜索
set incsearch
" NERDTree
nmap <leader>ls :NERDTree<CR>
" NERDTree 宽度
let NERDTreeWinSize = 20
" 自动打开 NERDTree
" autocmd vimenter * NERDTree
" 记住浏览位置
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" =========================== 插入 ===========================
" 插入 ip
:command Ip :r! echo "$(ip addr | perl -ne 'print "$1 $2\t" if /inet ((?:\d+\.){3}\d+).* brd .*? scope global (.*)/')"
nmap <leader>ip :Ip<CR>
" 插入 date 命令
nmap <leader>date a<C-R>='$(date +%Y-%m-%d %H:%M:%S)'<CR>

" =========================== 注释头 ===========================
:command Shebang :r! echo -e "\# @Author: blurh
\\n\# @Create time: `date +\%Y-\%m-\%d\ \%H:\%M:\%S`
\\n\# @Description:"
:command Chebang :r! echo -e "// @Author: blurh
\\n// @Create time: `date +\%Y-\%m-\%d\ \%H:\%M:\%S`
\\n// @Description: "
:command Golang :r! echo -e "package main
\\nimport (
\\n    \"fmt\"
\\n)
\\n
\\nfunc main() {
\\n
\\n}"

nmap <leader>sh :0put='#!/bin/bash'<CR>:Shebang<CR>A<space>
nmap <leader>py :0put='#!/usr/bin/python3'<CR>:Shebang<CR>A<space>

nmap <leader>clang :0put='//usr/bin/env gcc $0 && ./a.out $@; exit'<CR>:Chebang<CR>A
nmap <leader>node :0put='#!/usr/bin/env node'<CR>:Chebang<CR>A
nmap <leader>go :0put='//usr/bin/env go run $0 $@; exit'<CR>:Golang<CR>kA

" =========================== 运行脚本 ===========================
" chmod 加可执行权限
nmap <leader>chmod :w<CR>:w !chmod +x `pwd`/%<CR>

" 运行
:nmap <leader>run :w <CR>:!
\perl -e '$enter="\n"x'$(( `tput lines` - 1 ))';print"$enter"'
\&& tput cup 0 0
\&& perl -e '$path="'`pwd`/%'";$len=(`tput cols` - length($path)) / 2 - 1;$eq="="x"$len";print "$eq $path $eq\n\n"'
\&& cat %
\&& perl -e '$eq="="x'$(( `tput cols` / 2 - 13 ))';$time=localtime();print "\n$eq $time $eq\n\n"'
\&& time `pwd`/%
\&& echo -e "\nshell returned $?"
\&& perl -e '$eq="-"x'$(( `tput cols` ))';print "\n$eq"'<CR>

" 运行需要加参数的脚本
nmap <leader>arg :w <CR>:InputArgs<space>
:command -nargs=* InputArgs :!
\perl -e '$enter="\n"x'$(( `tput lines` - 1 ))';print"$enter"'
\&& tput cup 0 0
\&& perl -e '$path="'`pwd`/%'";$len=(`tput cols` - length($path)) / 2 - 1;$eq="="x"$len";print "$eq $path $eq\n\n"'
\&& cat %
\&& perl -e '$eq="="x'$(( `tput cols` / 2 - 13 ))';$time=localtime();print "\n$eq $time $eq\n\n"'
\&& `pwd`/% <args>
\&& echo -e "\nshell returned $?"
\&& perl -e '$eq="-"x'$(( `tput cols` ))';print "\n$eq"'<CR>

" F9 运行脚本
nmap <F9> <leader>arg
imap <F9> <Esc><leader>arg
" ctrl + Enter 运行脚本
nmap <C-j> <leader>run

