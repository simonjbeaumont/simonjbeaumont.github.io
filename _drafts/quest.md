---
layout: post
title: Quest for coverage
keywords: ocaml,ocaml-pci,coverage,coveralls,travis,metrics,unit-tests,testing
hero: /images/ctypes/mines.jpg
---


```bash
$ make coverage
...
Summary:
 - 'binding' points: 157/157 (100.00%)
 - 'sequence' points: 70/72 (97.22%)
 - 'for' points: 4/4 (100.00%)
 - 'if/then' points: 2/2 (100.00%)
 - 'try' points: 2/2 (100.00%)
 - 'while' points: none
 - 'match/function' points: 47/51 (92.16%)
 - 'class expression' points: none
 - 'class initializer' points: none
 - 'class method' points: none
 - 'class value' points: none
 - 'toplevel expression' points: 1/1 (100.00%)
 - 'lazy operator' points: none
 - total: 283/289 (97.92%)
/local/work/code/ocaml-pci
```

Card bus stuff...

https://bugzilla.kernel.org/show_bug.cgi?id=5057
https://bugzilla.kernel.org/attachment.cgi?id=5625

```bash
$ make coverage
[snip]
Summary:
 - 'binding' points: 157/157 (100.00%)
 - 'sequence' points: 72/72 (100.00%)
 - 'for' points: 4/4 (100.00%)
 - 'if/then' points: 2/2 (100.00%)
 - 'try' points: 2/2 (100.00%)
 - 'while' points: none
 - 'match/function' points: 49/51 (96.08%)
 - 'class expression' points: none
 - 'class initializer' points: none
 - 'class method' points: none
 - 'class value' points: none
 - 'toplevel expression' points: 1/1 (100.00%)
 - 'lazy operator' points: none
 - total: 287/289 (99.31%)
/local/work/code/ocaml-pci
```

The final .69%...




