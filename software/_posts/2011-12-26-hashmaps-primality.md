---
layout: post
title: Hash maps and primality—when & why?
tags: compsci puzzle interview
---

Recently I was posed an interesting question during an interview for a graduate software engineering position. It would be unfair to say which company this was and so I will cryptic-crossword-clue-ify the name by saying _finished novel before resounding characteristic of my stride_. Anyway(!), I thought I'd share my thoughts on a particular (perhaps bogus) question from that experience.

So we got talking about the inner guts of how a `HashMap` might work. We talked about a (deliberately) naïve approach to the hash function which would take the reference of the object--an integer, `r`&mdash;and put it in bucket number `n` where `n = abs(r) (mod N)` where `N` is the number of buckets in the implementation. The question posed was:

> What would be a suitable choice for `N`, the number of buckets in the `Map`?

We talked about it a bit and didn't get very far until I was led to the answer that choosing N such that it is prime would be the best choice. At this point the other interviewer pipes up and exclaims that this isn't useful or correct which got me thinking about whether choosing N prime makes any difference in minimising the number of collisions produced by our hash function. My gut was that I agreed with the objection to the question.

I went home and put my thinking hat on and came to a conclusion.<!-- more --> This conclusion is that choosing a prime number of buckets does not provide general gains of a non-prime when just using the naïve hash function described above. This may be still be incorrect but it appears to be supported by the argument presented in one of the answers to the following [stackoverflow post](http://stackoverflow.com/questions/1145217/why-should-hash-functions-use-a-prime-number-modulus "Why should hash functions use a prime number modulus?").

The reason for this is because although `N`, the number of buckets, may be prime it can still be a factor in infinitely many composite integers. Because of this, in a range of integers 0..R, there are more multiples of 3 than there are multiples of 4 and as such more of the numbers within the given range will divide exactly by 3 than by 4 and so produce more collisions with 3 buckets than with 4. This would be expected behaviour however since 3 < 4 and so the number of possible buckets is less. So by extension it seems like (with a naïve modulo based hash function) the largest possible `N` will produce the fewest collisions and will be independent of the primality of the number. I suppose a good choice (if available) would be to have many more buckets than things you were planning to store.

Since the collisions occur from common factors I knew primes must give some gains, somewhere... but where?! After much thought I think that if a hash function takes a number `r` to one of `N` buckets by `(k*r) % N` then to minimise collisions it would be good to make sure that `k` and `N` are co-prime&mdash;the `gcd(N,k)=1`. Since we implicitly chose `k=1` for our hash function then all values of `N` are co-prime with `k` since all numbers are co-prime with 1. If the hash function&mdash;and therefore `k`&mdash;was unknown then it would be ideal to _maximise the probability of `k` and `N` being co-prime_ and so I guess choosing `N` to be prime would help in that respect.

Having thought about this I looked into the Java implementation of `HashMap` and noticed that it uses values for `N`, the number of buckets, that are all powers of 2 which will, therefore, all be non-prime. The default starting number is 16 and as the utilisation of the map reaches the load factor (0.75 by default) it doubles its number of buckets and redistributes the data.

I know that primes are important in the hash function itself to provide good spacing but I'm still unconvinced that the number of buckets makes a difference. It is the purpose of the hashing to distribute the data evenly over an arbitrary number of buckets.

As I said previously, my instincts here may still be wrong but since there was a hint of doubt I thought I would attempt to clarify the matter; if only for myself.

Have a good Christmas everyone!
