---
layout: post
title: My day job just got open sourced
keywords: [open source, OSS, XenServer, citrix, xapi project, xen project, linux foundation]
image:
  path: /images/open-xenserver/door.jpg
---

I haven't really ever blogged about my work but that all might change beacause
this week saw the [announcement][citrix-announcement] that one of the best
virtualisation and cloud platforms, **XenServer** has moved to **_open
source_**. Open source has always been at the heart of the foundations of
XenServer and the [_Xen Hypervisor_][xen-project].

## What's Xen
Xen is one of the leading open-source hypervisor that span out work done in the
Cambridge University Computer Lab.

"Wait,", I hear some ask, "what's a hypervisor?!". Well allow me to explain
using the analog of operating systems. A program running on your computer needs
to be able to access resources. To make it possible to write programs that run
anywhere, an operating system will present a process with a consistent and
isolated view. A running process knows nothing of other processes. It thinks it
is the only thing running with exclusive use of a set of resources. These
resources are actually brokered by the OS. For example, a program may ask for a
box into which it can put things. The OS will broker the process a box and keep
track of where it is. Then the process can just ask for the contents of it's
box and it needn't know where the box is or anything about any other boxes in
use by other processes. In order to broker the resources of the hardware with
integrity it needs to be the head-honcho: the one in charge, so it is in
control.

Now, let's take this layer model and add another layer. Suppose I would like to
run multiple operating systems on my server. Suddenly we have a problem, who's
going to be in charge? How can any of these guys co-exist with the others and
keep track of the state of the machine without this exclusive control of
hardware. Well, it would be a real pain in the arse. So we don't do it that
way. We use a similar model to how an OS brokers resources on behalf of
processes, completely opaquely. Bring on **the hypervisor**. The hypervisor is
a _thin layer_ of software which is the new head-honcho. It's the one in
exclusive control of the hardware and provides the ability for **virtual
operating systems** (called _**guests**_) to execute on one machine. _The
hypervisor is to operating systems what an operating system is to processes_.
As such, it presents a **virtual machine** (termed a _**domain**_ when running)
on which the operating system can run and be the head-honcho it wants to be, in
isolation and ignorance of other guests.

Now then, _not all guests are creatd equal_. One of the guests is more
privileged than all the others and has transparent access to the hardware
through the hypervisor (cf. the opaque view provided to the other guests). This
is called dom0 since it runs in domain 0. This is also sometimes called the
_control domain_ since it is used to control and configure the hardware.

That's probably enough to go on, but for the curious, I suggest you check out
the [hypervisor][wikipedia] article on our faviourite online encyclopedia. This
is also how I'd explain this to my mother so, for the technical scrutinier, I
make no apologies for the deliberate massaging of details with an attempt to
not lose too much truth.

The Xen hypervisor has been and will always be open source.

## What's XenServer
XenServer is a server virtualisation and cloud platform which comprises Xen, a
custom Dom0 (a modified version of CentOS), a toolstack including the XenAPI
and Storage Manager backends.

Historically this has been sold as enterprise software with it's main use in
the server virtualisation market (powering such products as Citrix XenDesktop).
Parts of it over the years have been open sourced, most notably the
[XenAPI][xen-api], a primarily OCaml codebase.

## So, what's up for grabs?
We've gone all-out on this one, so **the kitchen sink**. Eveything, including
the Windows PV drivers, the [XenCenter][xencenter] UI and various
other packages (see the [XenServer Github page][xenserver-github]).

## Who cares?
Well, hopfully, you! You can join the XenServer community over at
[XenServer.org][xenserver.org] and see how you can get involved. There's a
whole bunch of guys who are happy to help you get your hands dirty with
development:

- The mailing list: [`xs-devel@lists.xenserver.org`][mailing-list];
- The IRC channel: `#xen-api` on Freenode.

So do me out of a job, learn some OCaml and write some code for the XenServer
project.

[citrix-announcement]: http://www.citrix.com/news/announcements/jun-2013/citrix-launches-open-source-xenserver.html
[xen-project]: http://www.xen.org
[xen-api]: http://github.com/xapi-project/xen-api
[xencenter]: http://github.com/xenserver/xenadmin
[xenserver-github]: http://github.com/xenserver/
[xenserver.org]: http://xenserver.org
[mailing-list]: mailto:xs-devel@lists.xenserver.org
