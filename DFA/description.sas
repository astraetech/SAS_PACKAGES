/* This is the description file for the package.         */
/* The collon (:) is a field separator and is restricted */
/* in lines of the header part.                          */

/* **HEADER** */
Type: Package                                             :/*required, not null, constant value*/
Package: DFA                                              :/*required, not null*/
Title: Dynamic function arrays and other data structures  :/*required, not null*/
Version: 0.1                                              :/*required, not null*/
Author: Bartosz Jablonski (yabwon@gmail.com)              :/*required, not null*/
Maintainer: Bartosz Jablonski (yabwon@gmail.com)          :/*required, not null*/
License: MIT
Encoding: UTF8                                            :/*required, not null*/

Required: "Base SAS Software"                             :/*optional*/

/* **DESCRIPTION** */
/* All the text below will be used in help */
DESCRIPTION START:

The DFA (a.k.a. Dynamic Function Array) package implements:
 - dynamic numeric and character arrays,
 - dyncamic stacks,
 - dynamic queues (fifo),
 - dynamic ordered stacks,
 - priority queues.

The set of macros, which allow to generate 
call routines simulating data structures
mentioned above, is provided.

Example functions are also generated.

DESCRIPTION END:
