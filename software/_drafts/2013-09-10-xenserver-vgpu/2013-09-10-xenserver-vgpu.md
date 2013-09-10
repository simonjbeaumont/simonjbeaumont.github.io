---
layout: post
title: Instrumenting XenServer for NVIDIA VGX (vGPU)
---

Following the [recent announcement][1] of XenServer's upcoming virtual GPU
support, we thought it might be nice to share some of the internals that
make it work.

Having worked on the toolstack side of this project, I hope to explore a little
of the underlying architecture, the extensions to the XenAPI and how you can
configure your XenServer to use vGPU.

XenServer has supported passthrough for PCI devices since XenServer 6.0 and
this has been the defacto method for providing a GPU to a guest. With the
advent of NVIDIA's vGPU-capable GRID K1/K2 cards it will now be possible to
carve up a GPU into smaller pieces yielding a more scalable solution to
boosting graphics performance within virtual machines. To quote from the press
release:

> The most notable is that with the combined solution applications interact
directly with NVIDIA drivers, not hypervisor drivers.  This means greater
application compatibility, and greater performance with large 3D models.  Plus
it doesn’t hurt that we’re able to natively support the latest versions of both
DirectX and OpenGL out of the box. This will be true hardware vGPU with
professional graphics performance benefits differentiating it from software
vGPU and API intercept technologies such as Remote FX and vSGA which address
less demanding 3D use cases like Aero effects and PowerPoint slide transitions.

## The architecture

## Xapi's API and datamodel

## Driving the CLI

## The source (get involved)
We're open source now, so why not get involved in the action. All the code for
the toolstack can be found on the [Xapi project's Github][2] with this project
having it's own [feature branch][3].

The code for the display emulator that the device model interacts with is also
open source and can be found ...

[1]: http://blogs.citrix.com/2013/08/26/preparing-for-true-hardware-gpu-sharing-for-vdi-with-xenserver-xendesktop-and-nvidia-grid/
[2]: http://github.com/xapi-project
[3]: http://github.com/xapi-project/xen-api/tree/pr-1061
