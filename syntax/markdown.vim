" Vim syntax file
" Language:     Markdown
" Maintainer:   Tim Pope <vimNOSPAM@tpope.org>
" Filenames:    *.markdown
" Last Change:  2020 Jan 14

if exists("b:current_syntax")
  finish
endif

if !exists('main_syntax')
  let main_syntax = 'markdown'
endif

if has('folding')
  let s:foldmethod = &l:foldmethod
endif

let s:highlight_langs = get(g:, 'markdown_fenced_languages', [])

let s:done_include = {}
for s:type in map(copy(s:highlight_langs),'matchstr(v:val,"[^=]*$")')
  if has_key(s:done_include, matchstr(s:type,'[^.]*'))
    continue
  endif
  if s:type =~ '\.'
    let b:{matchstr(s:type,'[^.]*')}_subtype = matchstr(s:type,'\.\zs.*')
  endif
  exe 'syn include @mdHighlight'.substitute(s:type,'\.','','g').' syntax/'.matchstr(s:type,'[^.]*').'.vim'
  unlet! b:current_syntax
  let s:done_include[matchstr(s:type,'[^.]*')] = 1
endfor
unlet! s:type
unlet! s:done_include

if exists('s:foldmethod') && s:foldmethod !=# &l:foldmethod
  let &l:foldmethod = s:foldmethod
  unlet s:foldmethod
endif

let s:conceal = ''
let s:concealends = ''
if has('conceal') && get(g:, 'markdown_conceal_small', 1) == 1
  let s:conceal = ' conceal'
  let s:concealends = ' concealends'
endif

let s:conceal_link = ''
let s:conceal_image = ''
let s:concealends_link = ''
if has('conceal') && get(g:, 'markdown_conceal_link', 1) == 1
  let s:conceal_link = ' conceal'
  let s:concealends_link = ' concealends'
  let s:conceal_image = ' cchar=' . get(g:, 'markdown_conceal_link_cchar', '▨')
endif

execute 'syn sync minlines=' . get(g:, 'markdown_minlines', 50)
syn case ignore

" Embedded HTML {{{2
syn include @HTML syntax/html.vim
unlet! b:current_syntax
syn match mdHTML /<\/\?\a.\{-}>/ contains=@HTML
syn region mdHTMLComment matchgroup=mdHTMLComment start=/<!--\s\=/ end=/\s\=-->/ contains=vimTodo
" }}}

syn match mdValid '[<>]\c[a-z/$!]\@!' transparent contains=NONE
syn match mdValid '&\%(#\=\w*;\)\@!' transparent contains=NONE

syn match mdLineStart "^[<@]\@!" nextgroup=@mdBlock,htmlSpecialChar

syn cluster mdBlock contains=mdH1,mdH2,mdH3,mdH4,mdH5,mdH6,mdBlockquote,mdList_,mdOrderedList_,mdEmptyCheckboxList_,mdCheckboxList_,mdCodeBlock,mdRule
syn cluster mdInline contains=mdLineBreak,mdLinkText,mdItalic,mdBold,mdCodeInline,mdMathInline,mdEscape,mdError,mdValid,mdFootnote

" Headings {{{2
syn match mdH1 "^.\+\n=\+$" contained contains=@mdInline,mdHeadingRule,mdAutomaticLink
syn match mdH2 "^.\+\n-\+$" contained contains=@mdInline,mdHeadingRule,mdAutomaticLink

syn match mdHeadingRule "^[=-]\+$" contained

syn region mdH1 matchgroup=mdH1_ start="^#\s\+"      end="\( #\+\|\s*\)$" keepend oneline contains=@mdInline,mdAutomaticLink contained
syn region mdH2 matchgroup=mdH2_ start="^##\s\+"     end="\( #\+\|\s*\)$" keepend oneline contains=@mdInline,mdAutomaticLink contained
syn region mdH3 matchgroup=mdH3_ start="^###\s\+"    end="\( #\+\|\s*\)$" keepend oneline contains=@mdInline,mdAutomaticLink contained
syn region mdH4 matchgroup=mdH4_ start="^####\s\+"   end="\( #\+\|\s*\)$" keepend oneline contains=@mdInline,mdAutomaticLink contained
syn region mdH5 matchgroup=mdH5_ start="^#####\s\+"  end="\( #\+\|\s*\)$" keepend oneline contains=@mdInline,mdAutomaticLink contained
syn region mdH6 matchgroup=mdH6_ start="^######\s\+" end="\( #\+\|\s*\)$" keepend oneline contains=@mdInline,mdAutomaticLink contained
" }}}

syn region mdBlockquote matchgroup=mdBlockquote_ start="^\s*>\s\+" end="$" contains=@mdInline

syn region mdCodeBlock start=/\(^\S.*\n\)\@<!\(^\(\s\{4,}\|\t\+\)\).*\n/ end=/.\(\n^\s*\n\)\@=/ contained

" List {{{2
syn match mdList_ "^\s*[-*+]\ze\s\+" contained
syn match mdOrderedList_ "^\s*\(#\|\d\+\)\.\ze\s\+" contained
syn match mdEmptyCheckboxList_ "^\s*[-*+] \[ \]\ze\s\+" contained
syn match mdCheckboxList_ "^\s*[-*+]\s\+\[[^ ]\]\ze\s\+" contained
" }}}

syn match mdRule "\* *\* *\*[ *]*$" contained
syn match mdRule "- *- *-[ -]*$" contained

syn match mdLineBreak " \{2,\}$"

" Link {{{2
" Autolink without angle brackets.
" md  inline links: protocol     optional  user:pass@  sub/domain                    .com, .co.uk, etc         optional port   path/querystring/hash fragment
"                  ------------ _____________________ ----------------------------- _________________________ ----------------- __
syn match  mdURL /https\?:\/\/\(\w\+\(:\w\+\)\?@\)\?\([A-Za-z0-9][-_0-9A-Za-z]*\.\)\{1,}\(\w\{2,}\.\?\)\{1,}\(:[0-9]\{1,5}\)\?\S*/
" Autolink with parenthesis.
syn region mdURL matchgroup=mdURL_ start="(\(https\?:\/\/\(\w\+\(:\w\+\)\?@\)\?\([A-Za-z0-9][-_0-9A-Za-z]*\.\)\{1,}\(\w\{2,}\.\?\)\{1,}\(:[0-9]\{1,5}\)\?\S*)\)\@=" end=")"
" Autolink with angle brackets.
syn region mdURL matchgroup=mdURL_ start="\\\@<!<\ze[a-z][a-z0-9,.-]\{1,22}:\/\/[^> ]*>" end=">"

" [linkText](URL) | [linkText][id] | [linkText][] | ![image](URL)
execute 'syn region mdID matchgroup=mdID_    start="\["    end="\]" contained oneline' . s:conceal_link
execute 'syn region mdURL matchgroup=mdURL_   start="("     end=")"  contained oneline' . s:conceal_link
execute 'syn match mdImageMarker /!/ oneline nextgroup=mdLinkText' . s:conceal_link . s:conceal_image
execute 'syn region mdLinkText matchgroup=mdLinkText_  start="\\\@<!\[\ze[^]\n]*\n\?[^]\n]*\][[(]" end="\]" contains=@mdInline,@Spell nextgroup=mdURL,mdID skipwhite' . s:concealends_link

" Link definitions: [ID]: URL (Optional Title)
syn region mdLinkDef matchgroup=mdLinkDef_   start="^ \{,3}\zs\[\^\@!" end="]:" oneline nextgroup=mdLinkDefTarget skipwhite
syn region mdLinkDefTarget start="<\?\zs\S" excludenl end="\ze[>[:space:]\n]"   contained nextgroup=mdLinkTitle,mdLinkDef skipwhite skipnl oneline
syn region mdLinkTitle matchgroup=mdLinkTitle_ start=+"+     end=+"+  contained
syn region mdLinkTitle matchgroup=mdLinkTitle_ start=+'+     end=+'+  contained
syn region mdLinkTitle matchgroup=mdLinkTitle_ start=+(+     end=+)+  contained
" }}}

exe 'syn region mdItalic matchgroup=mdItalic_ start="\S\@<=\*\|\*\S\@=" end="\S\@<=\*\|\*\S\@=" skip="\\\*" contains=mdLineStart,@Spell' . s:concealends
exe 'syn region mdItalic matchgroup=mdItalic_ start="\w\@<!_\S\@=" end="\S\@<=_\w\@!" skip="\\_" contains=mdLineStart,@Spell' . s:concealends
exe 'syn region mdBold matchgroup=mdBold_ start="\S\@<=\*\*\|\*\*\S\@=" end="\S\@<=\*\*\|\*\*\S\@=" skip="\\\*" contains=mdLineStart,mdItalic,@Spell' . s:concealends
exe 'syn region mdBold matchgroup=mdBold_ start="\w\@<!__\S\@=" end="\S\@<=__\w\@!" skip="\\_" contains=mdLineStart,mdItalic,@Spell' . s:concealends
exe 'syn region mdBoldItalic matchgroup=mdBoldItalic_ start="\S\@<=\*\*\*\|\*\*\*\S\@=" end="\S\@<=\*\*\*\|\*\*\*\S\@=" skip="\\\*" contains=mdLineStart,@Spell' . s:concealends
exe 'syn region mdBoldItalic matchgroup=mdBoldItalic_ start="\w\@<!___\S\@=" end="\S\@<=___\w\@!" skip="\\_" contains=mdLineStart,@Spell' . s:concealends
exe 'syn region mdStrikeThrough matchgroup=mdStrikeThrough_ start="\S\@<=\~\~\|\~\~\S\@=" end="\S\@<=\~\~\|\~\~\S\@=" skip="\\\~" contains=mdLineStart,@Spell' .s:concealends

exe 'syn region mdCodeInline matchgroup=mdCodeInline_ start="`" end="`" keepend contains=mdLineStart' . s:concealends
exe 'syn region mdCodeInline matchgroup=mdCodeInline_ start="`` \=" end=" \=``" keepend contains=mdLineStart' . s:concealends
syn region mdCodeBlock matchgroup=mdCodeBlock_ start="^\s*\z(`\{3,\}\).*$" end="^\s*\z1\ze\s*$" keepend
syn region mdCodeBlock matchgroup=mdCodeBlock_ start="^\s*\z(\~\{3,\}\).*$" end="^\s*\z1\ze\s*$" keepend

syn match mdFootnote "\[^[^\]]\+\]"
syn match mdFootnoteDefinition "^\[^[^\]]\+\]:"

syn match mdEmoji ":[[:alnum:]_+-]\+:" display

" Frontmatter {{{2
" YAML frontmatter
syn include @YAML syntax/yaml.vim
unlet! b:current_syntax
syn region mdYAMLFrontmatter matchgroup=mdYAML_ start="\%^---$" end="^\(---\|\.\.\.\)$" contains=@YAML keepend
" }}}

" Math {{{2
syn include @TEX syntax/tex.vim
unlet! b:current_syntax
syn region mdMathInline start="\\\@<!\$" end="\$" skip="\\\$" contains=@TEX oneline keepend concealends
syn region mdMathBlock start="\\\@<!\$\$" end="\$\$" skip="\\\$" contains=@TEX keepend
" }}}

if main_syntax ==# 'markdown'
  let s:done_include = {}
  for s:type in s:highlight_langs
    if has_key(s:done_include, matchstr(s:type,'[^.]*'))
      continue
    endif
    exe 'syn region mdHighlight'.substitute(matchstr(s:type,'[^=]*$'),'\..*','','').' matchgroup=mdCodeBlock_ start="^\s*\z(`\{3,\}\)*\s*\%({.\{-}\.\)\='.matchstr(s:type,'[^=]*').'}\=\S\@!.*$" end="^\s*\z1\ze\s*$" keepend contains=@mdHighlight'.substitute(matchstr(s:type,'[^=]*$'),'\.','','g')
    exe 'syn region mdHighlight'.substitute(matchstr(s:type,'[^=]*$'),'\..*','','').' matchgroup=mdCodeBlock_ start="^\s*\z(\~\{3,\}\)*\s*\%({.\{-}\.\)\='.matchstr(s:type,'[^=]*').'}\=\S\@!.*$" end="^\s*\z1\ze\s*$" keepend contains=@mdHighlight'.substitute(matchstr(s:type,'[^=]*$'),'\.','','g')
    let s:done_include[matchstr(s:type,'[^.]*')] = 1
  endfor
  unlet! s:type
  unlet! s:done_include
endif

syn match mdEscape "\\[][\\`*_{}()<>#+.!-]"
syn match mdError "\w\@<=_\w\@="

hi def link mdH1                 htmlH1
hi def link mdH2                 htmlH2
hi def link mdH3                 htmlH3
hi def link mdH4                 htmlH4
hi def link mdH5                 htmlH5
hi def link mdH6                 htmlH6
hi def link mdHeadingRule        mdRule
hi def link mdH1_                mdHeading_
hi def link mdH2_                mdHeading_
hi def link mdH3_                mdHeading_
hi def link mdH4_                mdHeading_
hi def link mdH5_                mdHeading_
hi def link mdH6_                mdHeading_
hi def link mdHeading_           Delimiter
hi def link mdOrderedList_       mdList_
hi def link mdCheckboxList_      mdList_
hi def link mdEmptyCheckboxList_ mdList_
hi def link mdList_              htmlTagName
hi def link mdBlockquote         htmlItalic
hi def link mdBlockquote_        htmlTagName
hi def link mdRule               PreProc

hi def link mdFootnote           Typedef
hi def link mdFootnoteDefinition Typedef
hi def link mdEmoji              Type

hi def link mdLinkText           htmlLink
hi def link mdLinkDef            Typedef
hi def link mdID                 Type
hi def link mdAutomaticLink      mdURL
hi def link mdURL                Float
hi def link mdLinkDefTarget      mdURL
hi def link mdLinkTitle          String
hi def link mdLinkText_          Comment
hi def link mdID_                mdLinkText_
hi def link mdURL_               mdLinkText_
hi def link mdLinkDef_           mdLinkText_
hi def link mdLinkTitle_         mdLinkText_

hi def link mdItalic             htmlItalic
hi def link mdItalic_            mdItalic
hi def link mdBold               htmlBold
hi def link mdBold_              mdBold
hi def link mdBoldItalic         htmlBoldItalic
hi def link mdBoldItalic_        mdBoldItalic
hi def link mdStrikeThrough      htmlStrike
hi def link mdStrikeThrough_     Comment
hi def link mdCodeInline         Comment
hi def link mdCodeInline_        Comment
hi def link mdCodeBlock          Comment
hi def link mdCodeBlock_         Comment

hi def link mdEscape             Special
hi def link mdError              Error
hi def link mdHTMLComment        Comment
hi def link mdHTMLCommentStart   Comment
hi def link mdHTMLCommentEnd     Comment
hi def link mdYAML_              Comment

let b:current_syntax = "markdown"
if main_syntax ==# 'markdown'
  unlet main_syntax
endif

" vim:set sw=2 fdm=marker:
