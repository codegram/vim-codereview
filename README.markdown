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

If you use Vundle put this in your vimrc:

```
Bundle 'junkblocker/patchreview-vim'
Bundle 'codegram/vim-codereview'
```

If you use Pathogen, clone this repo in your `~/.vim/bundle` directory.

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
