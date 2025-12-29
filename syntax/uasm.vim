" Vim syntax file
" Language:	ULM assembler
" Maintainer:	Michael Christian Lehn <michael.lehn@uni-ulm.de>
" Last Change:  2020-2-15
" License:      Vim (see :h license)

if exists("b:current_syntax")
  finish
endif

syntax case match

syntax match Type /[a-zA-Z_]\+\>/ contained skipwhite
syntax match Type /\.align\>/ contained skipwhite
syntax match Type /\.bss\>/ contained skipwhite
syntax match Type /\.byte\>/ contained skipwhite
syntax match Type /\.data\>/ contained skipwhite
syntax match Type /\.equ\>/ contained skipwhite
syntax match Type /\.equiv\>/ contained skipwhite
syntax match Type /\.global\>/ contained skipwhite
syntax match Type /\.globl\>/ contained skipwhite
syntax match Type /\.long\>/ contained skipwhite
syntax match Type /\.quad\>/ contained skipwhite
syntax match Type /\.set\>/ contained skipwhite
syntax match Type /\.space\>/ contained skipwhite
syntax match Type /\.string\>/ contained skipwhite
syntax match Type /\.text\>/ contained skipwhite
syntax match Type /\.word\>/ contained skipwhite

syntax match asmColon ":" nextgroup=Type skipwhite
syntax match asmDelimiter /[.$%,()]\|@w[0-3]/
syntax match Number /[1-9][0-9]*/
syntax match Number /[0-7][0-7]*/
syntax match Number /0x[0-9a-zA-Z][0-9a-zA-Z]*/
syntax region Number start=/"/ skip=/\\"/ end=/"/
syntax match Identifier /[A-Za-z_.][A-Za-z0-9_.]*/

syntax match Label /^[A-Za-z_.][A-Za-z0-9_.]*/ nextgroup=Type,asmColon,asmComment skipwhite
syntax match Label /^[ \t][ \t]*/ nextgroup=Type skipwhite

syntax match asmStillLabel /[A-Za-z_.][A-Za-z0-9_.]*/ contained nextgroup=Type,asmColon,asmComment skipwhite
syntax match asmStillLabel /[ \t][ \t]*/ contained nextgroup=Type skipwhite

syntax region Comment start="^//" end="$"
syntax region Comment start="//" end="$"
syntax region Comment start="/\*" end="\*/"
syntax region Comment start="^/\*" end="\*/" nextgroup=asmStillLabel
syntax region Comment start="^#" end="$"
syntax region Comment start="#" end="$"

" for avr-as
syntax region Comment start="^;" end="$"
syntax region Comment start=";" end="$"

highlight link asmStillLabel Label

let b:current_syntax = "uasm"
