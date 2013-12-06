if has('ruby')
  ruby $: << File.expand_path(File.join(Vim.evaluate('g:CODEREVIEW_INSTALL_PATH'), '..', 'lib'))
  ruby require 'code_review'

  fun! codereview#Review(url)
    ruby CodeReview.review Vim.evaluate("a:url")
  endfun

  fun! codereview#NewChangeComment()
    ruby CodeReview.current.new_change_comment
  endfun

  fun! codereview#NewComment()
    ruby CodeReview.current.new_comment
  endfun

  fun! codereview#ReloadComments()
    ruby CodeReview.current.reload_comments
  endfun
else
  fun! codereview#Review()
    echo "Sorry, codereview.vim requires vim to be built with Ruby support."
  endfun

  fun! codereview#Comment()
    echo "Sorry, codereview.vim requires vim to be built with Ruby support."
  endfun
endif
