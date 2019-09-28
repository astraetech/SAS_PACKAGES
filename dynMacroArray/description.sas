/* This is the description file for the package.         */
/* The collon (:) is a field separator and is restricted */
/* in lines of the header part.                          */

/* **HEADER** */
Type: Package                                    :/*required, not null, constant value*/
Package: dynMacroArray                           :/*required, not null*/
Title: Macro wrapper for hashtable emulating dynamic-size array.  :/*required, not null*/
Version: 0.1                                     :/*required, not null*/
Author: Bartosz Jablonski (yabwon@gmail.com)     :/*required, not null*/
Maintainer: Bartosz Jablonski (yabwon@gmail.com) :/*required, not null*/
License: MIT                                     :/*required, not null*/
Encoding: UTF8                                   :/*required, not null*/

/* **DESCRIPTION** */
/* All the text below will be used in help */
DESCRIPTION START:

The dynMacroArray package is a macro wraper for 
hash table. It emulates behviour of array but 
under the hood it is based on hash table.
The difference is that it behaves like a dynamically
allocated array.

An integer indexing variable _I_ and a data portion 
variable _<arrayName>cell_ are stearing elements.

It is not a speed deamon for big (>1MLN elements) size 
arrays. It works with hash table speed/efficiency.

Provided macros are:
 - %dynArray()
 - %appendTo()
 - %appendBefore()
 - %loopOver()
 - %loopEnd
 - %getVal()
 - %putVal()
 - %rangeOf()

See help for examples and details.

DESCRIPTION END:
