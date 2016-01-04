" Highlight Class and Function names
syn match    cCustomParen    "?=(" contains=cParen,cCppParen
syn match    cCustomFunc     "\w\+\s*(\@=" contains=cCustomParen
syn match    cCustomScope    "::"
syn match    cCustomClass    "\w\+\s*::" contains=cCustomScope

hi def link cCustomFunc  Function
hi cCustomClass ctermfg = 219

syn match cParenMatch "[\(\)\{\}]"
hi cParenMatch ctermfg=231

" Template functions
if exists('g:cpp_experimental_template_highlight') && g:cpp_experimental_template_highlight
    syn region  cCustomAngleBrackets matchgroup=AngleBracketContents start="\v%(<operator\_s*)@<!%(%(\_i|template\_s*)@<=\<[<=]@!|\<@<!\<[[:space:]<=]@!)" end='>' contains=@cppSTLgroup,cppStructure,cType,cCustomClass,cCustomAngleBrackets,cNumbers
    syn match   cCustomBrack    "<\|>" contains=cCustomAngleBrackets
    syn match   cCustomTemplateFunc "\w\+\s*<.*>(\@=" contains=cCustomBrack,cCustomAngleBrackets
    hi def link cCustomTemplateFunc  Function
endif


