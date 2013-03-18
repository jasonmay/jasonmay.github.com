---
layout: post
title: "Projects in Progress"
date: 2013-03-17 19:47
comments: true
categories: 
---

I have been learning plenty of new stuff lately, so I thought I'd write about the things in the works, the concepts grasped, and the ideas acquired in the process.

Moe
---

A few weeks ago I started contributing to
[Moe](http://github.com/MoeOrganization/moe),  an ultra-modern Perl interpreter
written in [Scala](http://scala-lang.org).

This has been extremely fun, since it is [-Ofun](http://ofun.pm). I fleshed out
the AST quite a bit and helped make the class-instance model more functional.

I did **not** need to know the ins and outs of perl5's interpreter. As far as I
know, Moe is nothing like
[perl5's interpreter](http://perldoc.perl.org/perlinterp.html). Moe is built using
[AST](http://en.wikipedia.org/wiki/Abstract_syntax_tree)s from the ground up.
It may not be the most efficient route to design a programming language, but it
is the quickest route to a working implementation and is incredibly easy to
grasp once you get your feet wet.

By no means am I an expert in Scala either. The Scala School was more than
enough to get me started. I took my time, and when I wanted to explore deeper,
I jumped into [The Tour of Scala](http://www.scala-lang.org/node/104) and
revisited old code to fix things up.

Neptune
-------

The past few weeks I accidentally deflated my "Moe"mentum with a new project:
[Neptune](https://github.com/jasonmay/neptune).

The point of this project isn't to benefit other people, but to benefit my
knowledge of Scala and other tools in general. I have no professional
experience in distributed systems beyond deploying code to Linode and Heroku. I
want to get my feet wet in having multiple services communicate in a way that
scales, and at the same time is not massively over-engineered. This project
also houses my first-ever
[python script](https://github.com/jasonmay/neptune/blob/9404f5b/util/massage.py)!

At this point it publically faces to a TCP port that users connect to (via
telnet or some-such), though it does not communicate with the internal universe
at all. The universe is managed and scheduled using an [Akka](http://akka.io)
scheduler; and will a) receive commands, and b) send updates using Thrift. I
haven't yet decided on a persistent store for the universe data. For now, I am
currently importing everything from a flat JSON script and loading everything
into [Redis](http://redis.io). And honestly, I haven't finally decided on
Thrift either. I have heard just as many good things about Google's
[protobuf](https://code.google.com/p/protobuf/).

In two different execution contexts (one for the "nature" scheduler, and one
for redis IO work), I implement the dynamic of the universe through fluid,
[event-based timing](http://git.io/BD_i6Q).
When I glue the services together with Thrift, I will
probably create a third execution context for its own blocking needs.

I am caching the universe data like there is no tomorrow. Nearly everything you
can think of is in a set. Mobiles (NPCs) are in a
[set](http://redis.io/commands#set) per location, and reciprocally, mobiles own
a "location" property. My aim is to keep property lookup work to a minimum to
mitigate unnecessary blocking. Besides, frequent updating is Redis' specialty!
I also hope to abstract away all the extra update work as much as possible to
avoid bugs.

Details pending
---------------

This is just a preface to all the different topics I hope to share in upcoming
posts. Stay tuned!
