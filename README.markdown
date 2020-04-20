# vim-codereview

## GitHub Pull Request-based Code Reviews

WARNING: A bit rough on the edges. I'm polishing it as I use it more.

With *codereview* you can review Pull Requests on GitHub right from Vim, as
well as comment on specific lines of the pull request or in the general PR
comments.

Since it builds upon the great *patchreview* and adds some GitHub-related
convenience, it needs the *patchreview* Vim plug-in to be installed.

## Install

Make sure you have compiled Vim with Ruby support and the Ruby you compiled it
with is 1.9+ compatible.

Also, you'll need `curl` installed.

If you use [Vundle](https://github.com/gmarik/Vundle.vim) put this in your `vimrc`:

```
Plugin 'junkblocker/patchreview-vim'
Plugin 'codegram/vim-codereview'
```

If you use Pathogen, clone this repo in your `~/.vim/bundle` directory.

## Screencast

For a quick live demo, check out this screencast:

[![screencast](http://img.youtube.com/vi/1KaTY9AA48w/0.jpg)](http://youtu.be/1KaTY9AA48w)

## Usage

Make sure you're in the correct folder for the Git repository you want to
review the PR on.

To start a code review for a specific pull request:

```
:CodeReview https://github.com/myorganization/myrepo/pulls/1328
```

*codereview* will now download the Pull Request patch, *stash your
current changes* and *checkout the PR's base SHA*. Then it'll open every
changed file in a new tab.

The first time, it'll ask you for a GitHub authorization token. You can
generate those from your Applications settings in your GitHub account page. 
More information available on [Github help](https://help.github.com/articles/creating-an-access-token-for-command-line-use/)

If you need to change the token later on, you can find it under `~/.codereview`,
or you can remove the file and be prompted for a token again. Please note 
this file is stored in plaintext. Contributions to store the key in the local
keychain or encrypt it with GPG are very welcome.

You'll be now on the Overview tab. Keep reading.

### The Overview tab

Here you'll see a list of comments on the Pull Request itself (**not on the
diff**). If you want to add a comment to this list, see "Commenting on the
whole Pull Request" below.

But for now you probably want to review some code. Switch through the different
tabs to see all the changes. Once you see a specific change on the diff that
you want to give your feedback on, you'll want to leave a constructive comment,
right? Keep reading to learn how to do it.

### Commenting on a specific line

When reviewing code in the diff tabs, you can go to any line and comment on any
addition or deletion by issuing the `:CodeReviewCommentChange` command (you can
map it to whatever you'd like). You can only comment on additions or deletions,
not context lines.

A new split will appear where you can write your comment, and when you're done,
just press `<leader>c` to post your comment.

### Commenting on the whole Pull Request

When you're done nitpicking on your colleague's diff, you can comment on the
whole Pull Request to give them a +1 or a :ship: :it: or whatever by issuing
`:CodeReviewComment` command (you can map it to whatever you'd like).

A new split will appear where you can write your comment, and when you're done,
just press `<leader>c` to post your comment.

### Reloading the comments

If you want to fetch the newest comments for the PR you're reviewing, just
issue `:CodeReviewReloadComments`! You'll be taken to the Overview tab with a,
new, fresh list of comments.
