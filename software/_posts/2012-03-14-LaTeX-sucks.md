---
layout: post
title: Annoying gotcha—LaTeX AMS Matrix
tags: latex gotcha error matrix
---

Wow... I couldn't really be more cheesed off :|

I've just spent the _best part of an hour_ trying (and failing) to typeset a
16x16 matrix using the `matrix` environment—well, `pmatrix` but whatever.

I constantly got the following error message:

    ! Extra alignment tab has been changed to \cr.

There was me searching for this elusive _'extra'_ alignment character (it's an
`&` by the way). I Vim'd my ass off with macros and eventually came to the
conclusion that **I was right and the compiler was wrong!** This is _very_
rarely the case but this is one of those rare occurances.

Take a look at the AMS
documentation[\[1\]](ftp://ftp.ams.org/ams/doc/amsmath/amsldoc.pdf) and what's
that, a footnote to §4.1?! :

> The maximum number of columns in a matrix is determined by the counter
> `MaxMatrixCols` (normal value = 10), which you can change if necessary using
> LATEX’s `\setcounter` or `\addtocounter` commands.

That's right: some numpty thought it would be helpful(?!) to set a maximum
matrix dimension. So why couldn't I typeset my 16x16 matrix? Simply because you
can't... (by default).

One word to you Mr. AMS man: Lame.

\[1\] : [User's Guide for the amsmath Package (Version
2.0)](ftp://ftp.ams.org/ams/doc/amsmath/amsldoc.pdf)
