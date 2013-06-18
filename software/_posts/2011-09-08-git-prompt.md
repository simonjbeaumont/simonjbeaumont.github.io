---
layout: post
title: Git Branch and Status in Bash prompt
tags: bash git prompt
---
Over these last few weeks I've really started getting into Git. Everyone has
their favourite VCS but for me, what I've seen of Git so far makes me think
it's gotta be one of the best and most flexible.

So if you love Git then maybe you'll appreciate this. A bit of Googling and I
stumbled upon a way to have your Bash PS1 prompt tell you what branch of a
repository you're on (if applicable) and give a dirty flag as well...

![](http://static.tumblr.com/tsta8sv/kbJlr585o/gitps1.png "Git in Bash PS1")

It involves a couple of functions in your `.bashrc` and here they are:

```bash
git_dirty_flag() {
  git status 2> /dev/null | grep -c : | awk '{if ($1 > 0) print "*"}'
}

parse_git_branch() {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ \1/'
}
```

Just call these within your PS1. I like to know if the branch I'm working on is
clean or not so I get it to append the branch name with a `*` if there are
uncommitted changes. Actually, I use a lightning bolt as you can see in the
pictures but this doesn't render for the post.

