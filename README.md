# Field Papers

**NOTE**: this has moved to the [Field Papers organization](https://github.com/fieldpapers)

---

Field Papers is the codebase behind http://fieldpapers.org.

See [INSTALL.md](https://github.com/stamen/fieldpapers/blob/master/INSTALL.md) for a guide to installing Field Papers.

If you are handy with [Vagrant](), you can start with the [Vagrant Install Instructions](https://github.com/stamen/fieldpapers/blob/master/VAGRANT.md)

## About Field Papers

Field Papers allows you to print a multipage paper atlas of anywhere in 
the world and take it outside, offline, in the field. You can scribble 
on it, draw things, make notes. 

When you upload a snapshot of your print to Field Papers, we'll do some 
magic on the server to put it back in the right spot on the map. You can 
transcribe your notes into digital form and share the result with your 
friends or download the notes for later analysis.

You don't need a [GPS](http://en.wikipedia.org/wiki/Global_Positioning_System) 
to make a map or learn complicated desktop [GIS](http://en.wikipedia.org/wiki/Geographic_information_system) 
software to use Field Papers. It's as easy as print, mark, scan.

This project is a continuation of [Walking Papers](http://walkingpapers.org), 
which was built for the OpenStreetMap (OSM) editing community. Field Papers 
allows you to print multiple-page atlases using several map styles (including 
satellite imagery and black and white cartography to save ink) and has built 
in note annotation tools with GIS format downloads. Field Papers also 
supports user accounts so you can save “your stuff” for later, or use the 
service anonymously. Maps from the two systems work together if you want OSM editing (see below).

Curious about [OpenStreetMap](http://openstreetmap.org)? It's a wiki-style 
map of the world that anyone can edit and it needs your help to add content. 
Field Papers and Walking Papers both provide tools to “round trip” map data 
through paper, to make it easier to perform the kinds of eyes-on-the-street 
edits, as well as distributing the load by making it possible for legible, 
easy notes to be shared and turned into real geographical data. Don't see 
your street on OpenStreetMap? Please add it! 

## Technical bits

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program; if not, write to the Free Software Foundation, Inc., 51 Franklin
Street, Fifth Floor, Boston, MA 02110-1301 USA.

###There are two main components here:###

1. **Site** - The user-facing website is written in PHP and MySQL, and has been developed
to work adequately well in a commodity shared hosting environment, such as
the Pair.com "webmaster" account I use to host Walking Papers.

2. **Decoder** - The ugly math bits are done in an offline process that consumes a queue
of freshly-scanned images from the main site, runs them through the
image-recognition algorithm, and posts back georectified image tiles
for editing. You can run a bunch of these in parallel to make jobs go
faster, and they should be perfectly fine on small EC2 instances or
a box plugged into plain old residential DSL.

It's worth mentioning that the image recognition part of the work relies
on a patented algorithm called SIFT:
    http://en.wikipedia.org/wiki/Scale-invariant_feature_transform
