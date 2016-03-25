---
layout: post
title: 'Type-safe C bindings: Using ocaml-ctypes and stub generation'
keywords: [ocaml, ocaml-ctypes, bindings, ffi, type-safe, flock, ocaml-flock]
image:
  path: /images/ctypes/maze.jpg
  credit: Kenners
  credit_link: https://www.flickr.com/photos/kenrickturner/11083895853
---

There's sometimes you just don't want to reinvent the wheel. Working day-to-day
in OCaml, you start to enjoy the fruits of a statically, strongly typed
language. For example, it's reassuring to know that, whilst your code might be
full of bugs, it ain't gonna segfault on you. But then you find yourself
needing to use an existing C library and boom. Tread carefully in this
minefield because one false step and you blow your foot off.

![one does not simply call a c function](/images/ctypes/gondor_meme.jpg)

There are a lot of things that can go wrong when writing your FFI bindings and
that's mainly because you have to write a lot of C code. The [OCaml manual][0]
has a large section full of rules that you'll need to follow: for example, you
need to make sure you handle the translation from OCaml values to C types and
back again; you must rigorously follow a set of rules to stop the OCaml garbage
collector moving your 🧀 cheese; not to mention if you want to handle callbacks
or multithreading correctly.

#### Enter OCaml Ctypes

You didn't get into OCaml to write C code. And with the OCaml's [Ctypes
library][1] you don't have to. With Ctypes, you can  define the C interface in
pure OCaml, and the library then takes care of loading the C symbols and
invoking the foreign function call.

## The old and busted (hand-rolled bindings)

Here's an example: suppose you wanted to bind [`flock(2)`][3], the declaration
of which is in `<sys/file.h>`:

```c
extern int flock (int __fd, int __operation) __THROW;
```

If we were to bind this function without any help from Ctypes we'd end up with
something like this (as found in Jane Street's [Core][4]):

```c
#define FLOCK_BUF_LENGTH 80

CAMLprim value core_unix_flock(value v_fd, value v_lock_type)
{
  CAMLparam2(v_fd, v_lock_type);
  int fd = Int_val(v_fd);
  int lock_type = Int_val(v_lock_type);
  int operation;
  int res;
  char error[FLOCK_BUF_LENGTH];

  /* The [lock_type] values are defined in core_unix.ml. */
  switch(lock_type) {
    case 0:
      operation = LOCK_SH;
      break;
    case 1:
      operation = LOCK_EX;
      break;
    case 2:
      operation = LOCK_UN;
      break;
    default:
      snprintf(error, FLOCK_BUF_LENGTH,
               "bug in flock C stub: unknown lock type: %d", lock_type);
      caml_invalid_argument(error);
  };

  /* always try a non-blocking lock */
  operation = operation | LOCK_NB;

  caml_enter_blocking_section();
  res = flock(fd, operation);
  caml_leave_blocking_section();

  if (res) {
    switch(errno) {
      case EWOULDBLOCK:
        CAMLreturn(Val_false);
      default:
        unix_error(errno, "core_unix_flock", Nothing);
    };
  };

  CAMLreturn(Val_true);
}
```

This could then be used from OCaml with the following external primitive
declaration:

```ocaml
module Flock_command : sig
  type t

  val lock_shared : t
  val lock_exclusive : t
  val unlock : t
end = struct
  type t = int

  (* The constants are used in the [core_unix_flock] C code. *)
  let lock_shared = 0
  let lock_exclusive = 1
  let unlock = 2
end

external flock : File_descr.t -> Flock_command.t -> bool = "core_unix_flock"
```

Now, in this simple, single function, there are a number of sharp edges:

0. All local variables or parameters to the function of type `value` need to be
   wrapped in one of the `CAMLparam` macros. If you have more than 5 values you
   need to make multiple macro calls;
0. `flock` takes an integer argument to specify the kind of lock operation you
   would like and these values need to be correctly transcribed from the header
   file **in both** the C stub and the OCaml wrapper;
0. Manual calls to release and re-aquire the OCaml global interpreter lock:
   `caml_enter_blocking_section` and `caml_leave_blocking_section`.

## The new and shiny (using Ctypes)

Using the `Foreign` module from Ctypes, we can replace all of the C code above
with the following single line of OCaml:

```ocaml
open Ctypes
let flock = Foreign.foreign "flock" ~check_errno:true (int @-> int @-> returning int)
```

It's then readily available for calling:

```ocaml
# flock 1 1;;
- : int = 0
```

Now we have wrapped our entire C call and it even comes with error checking.
It's a type-safe declaration (with respect to the C types). The `~check_errno`
argument is quite handy as it will check for errors when the return code of the
function is non-zero and translate the contents of `errno` to an OCaml
`Unix_error`:

```ocaml
# flock 15 1;;
Exception: Unix.Unix_error (Unix.EBADF, "flock", "").
```

As we can see, the type-safety is only with respect to the C types. The
function takes two integers but both of which should really be wrapped to stop
these kinds of errors. For example, the first of these is a file descriptor so
we could create a wrapper in OCaml that took a `Unix.file_descr` and converted
that to its underlying `int` value before calling. We could do a similar trick
by wrapping the second parameter up in a type (as we saw in the Core example)
to only allow valid values for the `__operation` parameter. This will avoid any
`EINVAL`s like the following:

```ocaml
# flock 1 10;;
Exception: Unix.Unix_error (Unix.EINVAL, "flock", "").
```

## The newer and even more shiny (stub generation)

The above approach solves some of the pain-points of hand-rolling your own
C bindings but there's still a couple of places you can stub your toes.

If I were to try and bind a function that doesn't exist, the library would fail
with a linking error but there's nothing stopping me creating a bogus
definition to `flock`, for example by declaring it as `void @-> returning
string`. This would obviously not work as expected.

Fortunately, Ctypes has another way of binding to C: **stub-generation**. Here,
we can declare what we think the function is and we will find out, at
compile-time, if we made any mistakes.

We can define a functor that specifies the signature of the foreign call as
follows:

```ocaml
module Bindings (F : Cstubs.FOREIGN) = struct
  let flock = F.foreign "flock" (int @-> int @-> returning int)
end
```

And we can then pass this as a first-class functor to the Cstubs functions to
generate the ML code:

```ocaml
Cstubs.write_ml Format.std_formatter ~prefix:"flock_stub" (module Ffi_bindings.Bindings)
```

and the C code:

```ocaml
print_endline "#include <sys/file.h>";
Cstubs.write_c Format.std_formatter ~prefix:"flock_stub" (module Ffi_bindings.Bindings)
```

Now this doesn't solve all of the issues but it solves quite a few. With a bit
of build voodoo, we can generate all the C (and the ML) that we'll be needing.
We can then wrap this and expose this function in our OCaml library.

```ocaml
let flock ?(nonblocking=false) fd operation =
  let op_flag = flag_of_lock_operation operation in
  let flags = op_flag :: if nonblocking then [ nonblocking_flag ] else [] in
  B.flock (Obj.magic fd) (crush_flags flags) |> ignore
```

With stub-generation you are even able to get access to the constants defined
in the C library using `#define`. This uses a different interface from Ctypes.
For example, if you wanted to bind the constants used as flags to `flock(2)`
then you can do this as follows:

```ocaml
module Types (F: Cstubs.Types.TYPE) = struct
  module Lock_operation = struct
    let lock_shared = F.constant "LOCK_SH" F.int
    let lock_exclusive = F.constant "LOCK_EX" F.int
    let lock_unlock = F.constant "LOCK_UN" F.int
    let lock_nonblocking = F.constant "LOCK_NB" F.int
  end
end
```

Now we can use the generated ML to instantiate our functor and access these
values:

```ocaml
module T = Ffi_bindings.Types(Ffi_generated_types)

let flag_of_lock_operation = function
  | `LOCK_SH -> T.Lock_operation.lock_shared
  | `LOCK_EX -> T.Lock_operation.lock_exclusive
  | `LOCK_UN -> T.Lock_operation.lock_unlock
```

## What's next?

This is a dramatic improvement and removes a lot of the opportunity for error.
It's a bit of a pain to automate the build process since the stub-generation
code needs to be compiled and run to produce a C program, which in turn needs
to be compiled and run to output the generated ML. This is, of course,
necessary since we need the C compiler to tell us about our incorrect use of
symbols.

This can be done using Oasis with some custom ocamlbuild rules. An example of
this, and all of the above, can be found on [Github][5].

Now, the purist in you might always want to reimplement the functionality
natively in OCaml, but **when you just can't be arsed**, go forth and bind with
confidence!

[0]: http://caml.inria.fr/pub/docs/manual-ocaml-4.00/manual033.html
[1]: https://github.com/ocamllabs/ocaml-ctypes
[3]: http://linux.die.net/man/2/flock
[4]: https://github.com/janestreet/core/blob/master/src/unix_stubs.c#L489-L534
[5]: https://github.com/simonjbeaumont/ocaml-flock
