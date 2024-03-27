---
layout: post
title: Instrumenting XenServer for NVIDIA GRID (vGPU)
keywords: [XenServer, vGPU, NVIDIA, GRID, virtual GPU, virtualisation, virt]
image:
  path: /images/xenserver-vgpu/engine.jpg
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

With NVIDIA's current offering the GRID K1 and K2 cards can be configured in
the following ways:

![Possible VGX configurations](/images/xenserver-vgpu/vgx-configs.png)

Currently each physical GPU (PGPU) only supports homogeneous vGPU
configurations but different configurations are supported on different PGPUs
across a single K1/K2 card. This means that, with 2 K1 cards, we can run up to
**64 VMs per host** with vGPU support which is fantastic for VDI workloads.

The more powerful K2 cards boast better performance, reducing the cost of
GPU-enabled virtualisation for users of more demaning 3D software. Due to
Citrix's close partnership with **NVIDIA**, **IBM** and **PTC**, the XenServer
platform provides powerful new functionality for users of graphic design and
[CAD applications][4].

## XenServer's vGPU architecture
A new display type has been added to the device model:

```udiff
@@ -4519,6 +4522,7 @@ static const QEMUOption qemu_options[] =

     /* Xen tree options: */
     { "std-vga", 0, QEMU_OPTION_std_vga },
+    { "vgpu", 0, QEMU_OPTION_vgpu },
     { "videoram", HAS_ARG, QEMU_OPTION_videoram },
     { "d", HAS_ARG, QEMU_OPTION_domid }, /* deprecated; for xend compatibility */
     { "domid", HAS_ARG, QEMU_OPTION_domid },
```

With this in place, `qemu` can now be started using a new option that will
enable it to communicate with a new display emulator, `vgpu` to expose the
graphics device to the guest. The `vgpu` binary is responsible for handling the
VGX-capable GPU and, once it has been successfully passed through, the in-guest
drivers can be installed in the same way as when it detects new hardware.

The diagram below shows the relevant parts of the architecture for this
project.

![XenServer's vGPU architecture](/images/xenserver-vgpu/arch.png)

## Xapi's API and data model

A lot of work has gone into the toolstack to handle the creation and management
of VMs with vGPUs. We revised our data model, introducing a semantic link
between `VGPU` and `PGPU` objects to help with utilisation tracking; we
maintained the `GPU_group` concept as a pool-wide abstraction of PGPUs
available for VMs; and we added **`VGPU_types`** which are configurations for
`VGPU` objects.

![Xapi's vGPU datamodel](/images/xenserver-vgpu/datamodel.png)

<div class="aside">
<b>Aside:</b> The VGPU type in Xapi's data model predates this feature and was
synonymous with GPU-passthrough. A VGPU is simply a display device assigned to
a VM which may be a vGPU (this feature) or a whole GPU (a VGPU of type
<i>passthrough</i>).
</div>

**`VGPU_types`** can be enabled/disabled on a **per-PGPU basis** allowing for
reservation of particular PGPUs for certain workloads. VGPUs are allocated on
PGPUs within their GPU group in either a _depth-first_ or _breadth-first_
manner, which is configurable on a per-group basis.

## Installation and usage
<div class="aside">
<b>TODO:</b> Need to wait for hotfix creation before completing this section
</div>
The tech-preview is available as a hotfix for XenServer 6.2 and can be
downloaded from [vGPU Tech-Preview page][5]. Once you have installed this and
the necessary RPMs from NVIDIA, then you can get yourself up and running using
the XE command line interface.

To create a VGPU of a given type you can use `vgpu-create`:

```bash
$ xe vgpu-create vm-uuid=... gpu-group-uuid=... vgpu-type-uuid=...
```

To see a list of VGPU types available for use on your XenServer, run the
following command. Note: these will only be populated if you have installed the
relevant NVIDIA RPMs and if there is hardware installed on that host supported
each type. Using `params=all` will display more information such as the maximum
number of heads supported by that VGPU type and which PGPUs have this type
enabled and supported.

```bash
$ xe vgpu-type-list [params=all]
```

To access the new and relevant parameters on a PGPU (i.e.
`supported_VGPU_types`, `enabled_VGPU_types`, `resident_VGPUs`) you can use
`pgpu-param-get` with `param-name=supported-vgpu-types`
`param-name=enabled-vgpu-types` and `param-name=resident-vgpus` respectively.
Or, alternatively, you can use the following command to list all the parameters
for the PGPU.  You can get the types supported or enabled for a given PGPU:

```bash
$ xe pgpu-list uuid=... params=all
```

## The source (get involved)
We're open source now, so why not get involved in the action. All the code for
the toolstack can be found on the [Xapi project's Github][2] with this project
having its own [feature branch][3].

[1]: https://blogs.citrix.com/2013/08/26/preparing-for-true-hardware-gpu-sharing-for-vdi-with-xenserver-xendesktop-and-nvidia-grid/
[2]: https://github.com/xapi-project
[3]: https://github.com/xapi-project/xen-api/tree/pr-1061
[4]: https://investor.ptc.com/releasedetail.cfm?ReleaseID=770282
[5]: https://www.citrix.com/go/vgpu
