---
title: Tiny C program to compute largest known prime
layout: post
archive: true
---
Having recently discovered **the awesome** [in-browser Javascript Linux
kernel](http://bellard.org/jslinux/), I looked a bit further into the
work of Fabrice Bellard and unearthed this gem. I know this is a little old now
but I think it's worth a mention.

The following code is just 438 bytes and computes the largest known prime
number, 2<sup>43112609</sup>-1, a number with about 13 million digits! So I
thought I'd also give it a test run and – who knew – it works. It ran on my
machine---2.53 GHz Intel Core 2 Duo---in just under 2 minutes and printed out
the largest (known) prime in all of its ~13M digits of glory!

```c
int m=167772161,N=1,t[1<<25]={2},a,*p,i,e=34893349,s,c,U=1;g(d,h){
for(i=s;i<1<<24;i*=2)d=d*1LL*d%m;for(p=t;p<t+N;p+=s)for(i=s,c=1;i;
i--)a=p[s]*(h?c:1LL)%m,p[s]=(m+*p-a)*(h?1LL:c)%m,a+=*p,*p++=a%m,c=
c*1LL*d%m;}main(){while(e/=2){N*=2;U=U*1LL*(m+1)/2%m;for(s=N;s/=2;
)g(17,0);for(p=t;p<t+N;p++)*p=*p*1LL**p%m*U%m;for(s=1;s<N;s*=2)
g(29606852,1);for(a=0,p=t;p<t+N;)a+=*p<<(e&amp;1),*p++=a%10,a/=10;
}while(!*--p);for(t[0]--;p>=t;)putchar(48+*p--);}
```

Turns out this guy is a bit of a machine --- here are some other projects that
he has authored. They are a bit old now but certainly not dated:

* [_Tiny CC_](http://bellard.org/tcc/): at just __100kB__ this C compiler
  is even __9x faster__ than GCC
* [_TCCBOOT_](http://bellard.org/tcc/tccboot.html): __138kB__ (uncompressed code)
  capable of compiling and running a Linux kernel in __less than 15
  seconds__---probably even faster today!
