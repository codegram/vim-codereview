if !exists('g:CODEREVIEW_INSTALL_PATH')
  let g:CODEREVIEW_INSTALL_PATH = fnamemodify(expand("<sfile>"), ":p:h")
end

command! -nargs=1 CodeReview call codereview#Review(<f-args>)
command! CodeReviewComment call codereview#Comment()