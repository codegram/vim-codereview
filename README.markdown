# vim-codereview

## GitHub Pull Request-based Code Reviews

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

### Commenting on a specific line

TBD.

### Commenting on the whole Pull Request

TBD.