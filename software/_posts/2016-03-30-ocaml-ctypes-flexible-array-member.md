---
layout: post
title: 'Type-safe C bindings #2: Handling flexible array members with ocaml-ctypes'
keywords: [ocaml, ocaml-ctypes, bindings, ffi, type-safe, array, flexible, sanlock, ocaml-sanlock]
image:
  path: /images/ctypes-flexible-array/rope.jpg
---

Recently [I blogged][0] about how we've been using [ocaml-ctypes][1] to
generate type-safe bindings to some C libraries that we want to use within our
OCaml software stack.

Over the last few months we've added bindings for a few things including:

* [`libpci`][2]: for for accessing PCI devices;
* [`flock(2)`][3]: for applying or removing an advisory lock on an open file; and
* [`libsanlock`][4]: for shared locks on distributed storage.

The last of these did, however, cause a small headache. Like many C libraries,
libsanlock makes use of **flexible array members**.

## What are flexible array members?
The term _flexible member_ may counjour up any number of images but here we're
talking about a feature introduced in the C99 standard.

As of C99, it is possible to define a struct whose final member is an array
without specifying its size. These can then be used to store an arbitrary
amount of data as part of this struct when the required amound may only be
determined at runtime. It is also possible to achieve this with the GCC
compiler by declaring an [array of zero length][5].

There is an example of such a struct in Sanlock library:

```c
struct sanlk_resource {
    char lockspace_name[SANLK_NAME_LEN]; /* terminating \0 not required */
    char name[SANLK_NAME_LEN]; /* terminating \0 not required */

    /* ... */

    uint32_t num_disks;
    /* followed by num_disks sanlk_disk structs */
    struct sanlk_disk disks[0];
};
```

As is often the case, there is an accompanying member that specifies the size
of the array which you'll need when handling one of these structs.

The `sizeof` operator on this struct is also required to obtain the offset to
this field and when allocating memory for a struct of this kind. For example,
to allocate a `sanlk_resource` with `n` disks:

```c
struct sanlk_resource *res = malloc(sizeof *res + n * sizeof (struct sanlk_disk));
```

## Bending Ctypes around flexible array members
When wrapping C structs in OCaml types using ocaml-ctypes, you define a new
`structure` parameterised by a new OCaml type.  This creates an "unsealed"
structure which enables us to handle values of this types (perhaps as returned
by a C library) but we cannot create values of this type until it is "sealed".
We first need to declare all of the fields in the struct so that the size and
offsets of the struct and its members can be handled safely by the OCaml code.

The Ctypes library provides the [primitive][6] and [POSIX][7] types that you'll
need to build up your wrapper for a C struct.

As a concrete example, consider the following C struct:

```c
struct series {
  int length;
  char contents [];
};
```

We would create an OCaml representation for this as follows:

```ocaml
module Line = struct
  open Ctypes

  type internal
  let internal : internal structure typ = structure "line"
  let length = field internal "length" int
  let contents = field internal "contents" (array 0 char)
  let () = seal internal
end
```

The problem comes when wrapping the flexible array member. The constructor for
the Ctypes array `typ` is paramertised by the size to allow for bounds-checked
modification and access.  This means that you can only create an OCaml type
representation of arrays that you know the size of in advance.

What value should we choose? Well this is going to inform how much memory is
allocated for the OCaml values of this type and if we receive convert a C value
with more elements in the flexible array member than we have declared then they
are truncated.

Ctypes helpfully provides an `allocate` function which takes a value of type
`typ` and returns an uninitialized value of the right size and shape. It also
provides us with functions to dereference pointers (perhaps returned from the C
library) to these values. Unfortunately neither of these will _just do the
right thing_ any more. Working out out how large these values should be at
compile-time is like asking **how long is a piece of string?**

The only sensible workaround is to try and copy the design pattern used in C in
OCaml. We have declared it to be of zero size and we will have to handle the
allocation and array bounds checking by hand.

### Handling values returned from C
We can no longer rely on the native Ctypes support to convert this type for us
since the array would always have length zero (despite being backed by a larger
array allocated by the C). Now we must cast our array to and from a pointer to
have it appear like an array of the correct size:

```ocaml
module Line = struct
  ...

  type t = {
    length   : int;
    contents : char list; 
  }

  let of_internal_ptr (p : internal ptr) : t =
    let arr_len = getf !@p length in
    let contents_list =
      let arr_start = getf !@p contents |> CArray.start in
      CArray.from_ptr arr_start arr_len |> CArray.to_list in
    { length = arr_length; contents = contents_list; }
end
```

### Creating values to pass to C
Normally we would simply call `allocate` to create a pointer to a fresh value
of our given type and then set each of the fields before passing this value to
a C function. However, we need to now make sure we create a value of the
correct size.

A slight quirk is that you cannot use the `allocate` function to allocate
arbitrary memory but Ctypes does provide an `allocate_n` variant which allows
the use of an "abstract" `typ`:

```ocaml
val allocate_n : ?finalise:('a ptr -> unit) -> 'a typ -> count:int -> 'a ptr

(** allocate_n t ~count:n allocates a fresh array with element type t and
length n, and returns its address. The argument ?finalise, if present, will be
called just before the memory is freed. The array will be automatically freed
after no references to the pointer remain within the calling OCaml program. The
memory is allocated with libc's calloc and is guaranteed to be zero-filled. *)
```

So if we have a value of our OCaml type we can construct a pointer which we can
use with our C bindings by coercing from one of these abstract values via the
`void` type and then using the unchecked setters for the array field:

```ocaml
module Line = struct
  ...

  let to_internal_ptr t =
    let size = (sizeof internal + t.length * sizeof char) in
    let internal =
      allocate_n (abstract ~name:"" ~size ~alignment:1) 1
      |> to_voidp |> from_voidp internal |> (!@) in
    setf internal length t.length;
    List.iteri (CArray.unsafe_set contents) t.contents;
    addr internal
end
```

### Using a view to make conversion implicit
Finally we can also [create a view][8] which creates a new Ctypes `typ` from
another with some implicit conversion rules. This allows us to use this new
value when binding C functions.

Suppose we had a C function that operated on a `struct line`, for example:

```c
int length(struct line *l);
```

Then we could add a binding for this function by declaring a view using our
`to_internal_ptr` and `from_internal_ptr` functions. This allows us to call
this function with values of our OCaml type, `Line.t`:

```ocaml
module Line = struct
  ...

  let t = view ~read:of_internal_ptr ~write:to_internal_ptr (ptr internal)
end

let length = foreign "length" (Line.t @-> returning int)
```

## Conclusion
I've spent a bit of time using Ctypes now and, even though I hadn't been
exposed to too much of the pain before it, I'm not sure I'd want to be without
it. You do have to jump through some hoops but I don't resent them because I
feel they add value. The extra effort of the required boiler-plate is worth it
for the confidence it brings. Sure, if you stray from straight-forward C
patterns to more idiomatic use (like this example) then you have to stray a bit
from the ideal model in Ctypes too but hey, the rules were made to be broken!
Also, Ctypes is very actively maintained and the small usuability niggle
addressed in this post [has been noted][9].

[0]: http://simonjbeaumont.com/posts/ocaml-ctypes
[1]: https://github.com/ocaml/ocaml-ctypes
[2]: https://github.com/simonjbeaumont/ocaml-pci
[3]: https://github.com/simonjbeaumont/ocaml-flock
[4]: https://github.com/simonjbeaumont/ocaml-sanlock
[5]: https://gcc.gnu.org/onlinedocs/gcc/Zero-Length.html
[6]: http://ocamllabs.github.io/ocaml-ctypes/Ctypes_types.TYPE.html
[7]: http://ocamllabs.github.io/ocaml-ctypes/PosixTypes.html
[8]: https://github.com/ocamllabs/ocaml-ctypes/wiki/ctypes-tutorial#views
[9]: https://github.com/ocamllabs/ocaml-ctypes/issues/353
