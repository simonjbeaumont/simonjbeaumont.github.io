---
layout: post
title: Penultimate term review
tags: compsci student life
---


Well thus ends my final Michaelmas term. I think that in future years I may
come to miss October's sudden onslaught of _Freshers' Flu_ but not much else.
It's been a manically busy period this time round with project proposals,
dissertation work and careers fairs to boot! Not to mention the following
plethora of lecture courses which, whilst academically interesting, have
questionable value to what I'll probably end up doing for a job. Can't really
see myself knee-deep in qubits anytime soon which renders my _Quantum
Computing_ course a bit suspect and _Denotational Semantics_ (next term) are
just a little too ivory-tower for my liking—Although I did quite quite enjoy
all the lovely greek that came with the polymorphic lambda calculus in this
term's _Type Theory_ course:

![type-derivation](http://static.tumblr.com/tsta8sv/p6Glvn3xm/types.png)

So, on the subject of jobs. It really has come to that point. The point where,
as a soon-to-be-graduate, I hope and pray that my hard work and well-earned
debt will actually get me some employment in what is a pretty tough economic
climate. Applications have already gone off—yikes—and I'm just gonna leave it
up to God.

However, as many of my peers have been attending interviews I have come across
some <strike>fun</strike> ridiculously pointless technical exercises that they
have been set at interview. I honestly question how they can tell how fit you
are for a role based on really anal puzzles such as the following:

> Observe the following failed attempt to print Hello 20 times:

```c
int n = 20;
int i;
for (i = 0; i < n; i--) {
    printf("Hello");
}
```

> The above code can be modified to produce the required output by changing a
> single character (adding, removing or substituting). Find _three different_
> ways to do this.

Now I need to be fair and actually say that correctly providing the solutions
to this does show an ability to quickly debug, and knowledge of C (particularly
for one of the solutions). For those of you who want to know, the solutions all
involve modifying a character on line 3 and any of the following will do the
trick:

<blockquote>
<code>3  for (i = 0;  i &lt; n; n--)</code><br><br>
<code>3  for (i = 0; -i &lt; n; i--)</code><br><br>
<code>3  for (i = 0;  i + n; i--)</code>
</blockquote>

No doubt that when I have had my interviews I'll be able to share some equally
dull programming puzzles. Bet you can't wait, right?

Anyway, just got to really break the back of my disseration over the Christmas
period, endure two more terms of lectures, drudge through the summer exams and
then it will all be over! I'll finally be Si Beaumont B.A.

P.S. It's not worth asking why my Computer Science degree is a B.A.
