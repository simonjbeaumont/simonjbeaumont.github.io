---
layout: post
title: Acoustic (Mercury) Delay Lines—Mmmmercury...
---
Some impressive engineering in the early stored program computers...

Now I know that this sounded like it was going to be a sound/music related post
but sorry to disappoint... This is about some of the early techniques used for
computer memory in EDSAC (quite impressive and worth a read)! 

Just drudging through the depths of revision for my <em>Computer
Design</em> course for my exams and I still can't get over the fact that they
used huge baths of mercury which they sent a pulse through as a memory device.
Pretty impressive engineering. Here's the extract from Wikipedia.

## Mercury delay lines (except from Wikipedia)
> After the war Eckert turned his attention to computer development, which was a
> topic of some interest at the time. One problem with practical development was
> the lack of a suitable memory device, and Eckert's work on the radar delays
> meant he had a major advantage over other researchers in this regard.

> For a computer application the timing was still critical, but for a different
> reason. Conventional computers have a natural "cycle time" needed to complete
> an operation, the start and end of which typically consist of reading or
> writing memory. Thus the delay lines had to be timed such that the pulses would
> arrive at the receiver just as the computer was ready to read it. Typically
> many pulses would be "in flight" through the delay, and the computer would
> count the pulses by comparing to a master clock to find the particular bit it
> was looking for.

> <a title="Mercury (element)"
> href="http://en.wikipedia.org/wiki/Mercury_(element)">Mercury</a> was used
> because the <a href="http://en.wikipedia.org/wiki/Acoustic_impedance">acoustic
> impedance</a> of mercury is almost exactly the same as that of the
> piezoelectric quartz crystals; this minimized the energy loss and the echoes
> when the signal was transmitted from crystal to medium and back again. The
> high <a href="http://en.wikipedia.org/wiki/Speed_of_sound">speed of
> sound</a> in mercury (1450 m/s) meant that the time needed to wait for a pulse
> to arrive at the receiving end was less than it would have been with a slower
> medium, such as air, but it also meant that the total number of pulses that
> could be stored in any reasonably sized column of mercury was limited. Other
> technical drawbacks of mercury included its weight, its cost, and its toxicity.
> Moreover, to get the acoustic impedances to match as closely as possible, the
> mercury had to be kept at a constant temperature. The system heated the mercury
> to a uniform above-room temperature setting of 40 °C (100 °F), which made
> servicing the tubes hot and uncomfortable work. (<a
> href="http://en.wikipedia.org/wiki/Alan_Turing">Alan Turing</a> proposed the
> use of <a href="http://en.wikipedia.org/wiki/Gin">gin</a> as an ultrasonic
> delay medium, claiming that it had the necessary acoustic properties.<sup
> class="reference plainlinks nourlexpansion" id="ref_wilkes"><a
> href="http://en.wikipedia.org/wiki/Delay_line_memory#endnote_wilkes">[1]</a></sup>)

> A considerable amount of engineering was needed to maintain a "clean" signal
> inside the tube. Large transducers were used to generate a very tight "beam" of
> sound that would not touch the walls of the tube, and care had to be taken to
> eliminate reflections off the far end of the tubes. The tightness of the beam
> then required considerable tuning to make sure the two piezos were pointed
> directly at each other. Since the speed of sound changes with temperature
> (because of the change in density with temperature) the tubes were heated in
> large ovens to keep them at a precise temperature. Other systems instead
> adjusted the computer clock rate according to the ambient temperature to
> achieve the same effect.

> <a title="EDSAC" href="http://en.wikipedia.org/wiki/EDSAC">EDSAC</a>, designed
> to be the first <a title="Stored-program"
> href="http://en.wikipedia.org/wiki/Stored-program">stored-program</a> <a
> title="Digital computer"
> href="http://en.wikipedia.org/wiki/Digital_computer">digital computer</a>,
> began operation with 512 35-bit <a title="Word (computing)"
> href="http://en.wikipedia.org/wiki/Word_(computing)">words</a> of memory,
> stored in 32 delay lines holding 576 bits each (a 36th bit was added to every
> word as a start/stop indicator). In the <a
> href="http://en.wikipedia.org/wiki/UNIVAC_I">UNIVAC I</a> this was reduced
> somewhat, each column stored 120 <a title="Bit"
> href="http://en.wikipedia.org/wiki/Bit">bits</a> (although the term "bit" was
> not in popular use at the time), requiring seven large memory units with 18
> columns each to make up a 1000-word store. Combined with their support
> circuitry and <a title="Amplifier"
> href="http://en.wikipedia.org/wiki/Amplifier">amplifiers</a>, the memory
> subsystem formed its own walk-in<a title="Room (architecture)"
> href="http://en.wikipedia.org/wiki/Room_(architecture)">room</a>. The average
> access time was about 222 <a title="Microsecond"
> href="http://en.wikipedia.org/wiki/Microsecond">microseconds</a>, which was
> considerably faster than the mechanical systems used on earlier computers.

> <a href="http://en.wikipedia.org/wiki/CSIRAC">CSIRAC</a>, completed in November
> 1949, also used delay line memory.
>  
