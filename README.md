viperre
=======

Viperre (Viper REmap) is a remapping of the Viper keyboard layout (Viper is a Vi mode for Emacs).

# Goals

1. Minimize chording (i heard chording is bad for the hands)
2. Minimize number of keystrokes and hand movement
3. Maximize speed


# Setup

To use it, put the .el files in your .emacs.d directionr, then add the following to your .emacs (not .viper) file after the point where viper is loaded (after "(require 'viper)"):

   
   (load "viperre")
   (viper-remap-qwerty)
   (define-key viper-vi-global-user-map (kbd "<SPC>") 'viper-insert)

If you are using the Colemak keyboard layout, replace (viperre-qwerty) with (viperre-colemak).

The relevant section of my .emacs file looks like this:

    (setq viper-mode t)
    (setq viper-ex-style-editing nil)  ; can backspace past start of insert / line
    (require 'viper)
    ;;(setq vimpulse-experimental nil)   ; don't load bleeding edge code (see 6. installation instruction)
    (require 'vimpulse)                ; load Vimpulse
    (setq woman-use-own-frame nil)     ; don't create new frame for manpages
    (setq woman-use-topic-at-point t)  ; don't prompt upon K key (manpage display)
    (define-key viper-vi-global-user-map (kbd "<SPC>") 'viper-insert)
    (load "viperre")
    (viper-remap-colemak)
    (setq viper-insert-after-replace nil)


# Tutorial

Viperre is meant to be used with your fingers resting in 'home position' on the 'home row'; that is, your left pinky thru pointer finger should rest on asdf, your thumbs should rest on the spacebar, and your right pointer finger thru pinky on jkl;.

Viperre is a package that builds on top of 'viper'. If you don't already know what viper is, it's a package that causes emacs to have two 'modes', one ('insert mode') for wysiwyg editing of text, and one ('vi mode') for moving around (and other things) using single-key shortcuts (and some multi-key sequences). What emacs usually does (if you don't use viper) is similar to viper's 'insert mode'.

In this tutorial, we assume a qwerty keyboard layout. However, viperre also comes with a colemak keyboard layout, which has a different remapping of commands-to-letters in order to achieve the same commands-to-physical finger/key positions.

## Beginner

### Switching modes

To switch from vi mode to insert mode, type SPC (the spacebar). To switch from insert mode to vi mode, type ESC (the escape key). 

### Moving

Note that the primary movement commands lie on the home positions, that is, the places where your fingers rest on the keyboard:

| command           |key| finger |
| ---               |---| --- |
| up                | f | left pointer/index finger |
| down              | j | right pointer/index finger |
| left by words     | d | left middle finger |
| right by words    | k | right middle finger |
| left              | s | left ring finger |
| right             | l | right ring finger |
| beginning of line | a | left pinky finger |
| end of line       | ; | right pinky finger |
| beginning of buffer | A | left pinky finger |
| end of buffer | ; | right pinky finger |


### Undo / redo


| command           |key| finger |
| ---               |---| --- |
| undo | z | (left pinky finger, reaching down) |
| redo | Z | |


### Loading, saving, switching buffers, windows

| command           |key| finger |
| ---               |---| --- |
| switch buffer (requires ido) | ww | (left ring finger, reaching up) |
| load file | wf | |
| save buffer | ws | |
| close buffer | C-w | |
| switch to other window | wo | |
| close other windows | w1 | |


## Intermediate

### Intermediate movement and searching commands

| command           |key| finger |
| ---               |---| --- |
| search backwards                      | r | left pointer/index finger, reaching up |
| search forwards                       | u | right pointer/index finger, reaching up |
| up by paragraphs                      | e | left middle finger, reaching up |
| down by paragraphs                    | u | right middle finger, reaching up |



### Intermediate Deleting

| command           |key| finger |
| ---               |---| --- |
| delete left word  | t | (left pointer/index finger, reaching up right) |
| delete right word | y | (right pointer/index finger, reaching up left) |
| delete left letter| b | (left pointer/index finger, reaching down right) |
| delete right letter| n | (right pointer/index finger, reaching down left) |


### Intermediate Cutting and pasting

| command           |key| finger |
| ---               |---| --- |
| cut line  | xx | (left ring finger, reaching down ) |
| copy line  | cc | (left pointer/index finger, reaching down left) |
| paste | v | (left pointer/index finger, reaching down ) |
| cut selected | xt | |
| copy selected  | ct | |


## Advanced

I recommend mastering the 'beginner' and 'intermediate' stuff, above, first.

### Advanced moving
| command           |key| 
| ---               |---| 
| search backwards for single character | g | left pointer/index finger, reaching left |
| search forwards for single character  | h | right pointer/index finger, reaching right |
| move to matching parens | ` | |


### Advanced saving locations

There are three different types of locations to which cursor locations can be saved (and restored from): registers, bookmarks, and the mark ring. The top item in the mark ring is called the 'mark'. Each register, each bookmark, and each item in the mark ring holds one location. The mark ring is like a circular stack.

Registers are identified by single alphabetic letters. Bookmarks are identified by words. I think bookmarks persist across emacs sessions (e.g. when you quit and restart emacs), but registers don't, not sure though.

| command           |key| 
| ---               |---| 
| save current cursor location into register R     | m SPC R, where r is a single alphabetic letter | 
| goto register R                                  | m R, where r is a single alphabetic letter | 
| save current cursor location into bookmark | w B | 
| goto bookmark                        | w b | 
| push current cursor location onto emacs 'mark ring' | m, | 
| push current cursor location onto emacs 'mark ring', and start selecting text | C-SPC | 
| cycle thru emacs 'mark ring' | mt | 
| exchange the cursor position and the emacs 'mark' | m. | 
| exchange the cursor position and the emacs 'mark', and select everything in between | C-x C-x | 

### Advanced editing

| command           |key| 
| ---               |---| 
| capital/lowercase   | ~ | 



There are other key sequences not yet described in this tutorial.




# The map

Here is a picture of a qwerty keyboard layout. 

    ` qwer ty uiop []  BACK
      asdf gh jkl; '
      zcxv bn m,./
                       \
      SPACEBAR
 

Below is the remapping. Each key K' has been labeled with the name of the key K that, in standard Viper, did what K' does now. For example, the spacebar is labeled "i", because in the remap, the spacebar is used to enter insert mode, which is what the "i" key does in standard Viper. Another example is that the "z" key is labeled "u", because it is used to undo in the remap, which is what the "u" key did in standard Viper. Some keys are labeled with numbers; except for 0 (which indicates the BOL function), these are footnotes used to refer to functions which are not assigned to keys (or at least not keys with single-letter names) in standard viper.


    % Og{2 ?/ 1}co 56   v 
      0jbh Tt kwl$ e
      udyp 34 s`".
                       \
         i

    1 c-D (half page dwn)
    2 c-U (half page up)
    3 backsp
    4 delete (like the x key in std viper)
    5 delete word backwards
    6 delete word forwards

In insert mode, the keys are not remapped.

Many of the capital and control keys have not yet been remapped (i.e. they retain their standard bindings as of now). Those that have are:

    Z -> redo
    shift-t, shift-T -> f,F
    shift-x,c,v -> D, Y, P

Other changes:
* If you hit a and ; (the t and T "till" functions), or A and : (f and F "find"), or t and y (? and / "search" functions), consecutively, the repeated hits act like the "repeat search" keys do in standard viper (n and N or ; and ,)
* If you activate the s "substitute" function (now bound to the m key), when you move outside s area, viper remap switches to command mode, not insert mode as in standard viper
* The Yank command (now bound to the V key) is y$, not yy as in standard viper
* the functions of q and z have been consolidated under g
* the functions of m are consolidated under ` (which is now bound to the , key)

List of functions which have been removed:

    m (consolidated under `)
    q, z (consolidated under g)
    r
    |



# Code so far
The code consists of two files which may be downloaded from http://bitbucket.org/bshanks/viperre/src/

----

# todo
* vimpulse needs to be remapped too
* Vi or Vim or Viper equivalent of http://xahlee.org/emacs/command-frequency.html

### not happy with/will probably change
* backspace -> v: i find myself trying to hit backspace when in command mode. but is that just habit, or does it mean it is useful?
* half page dwn/half page up: seems i usually use { and }, and only use those when i'm not using { and }. should map those keys to something else, and maybe make a mode to specify whether e,i are behaving as {} or c-u, c-d
* [,]: seems wrong somehow. also, should work like db, de.
* 0: should remap
* -,=: should remap
* maybe \ (escape-to-emacs-for-one-command) should be somewhere more prominent (mb r,u, or 0?)
* maybe cb, ce should be bound to a key?
* maybe bind ":"? or is this unnecessary in emacs?
* maybe swap v and V (functions p and P)?



### way future, probably won't get to
"d2t)" should delete text until the second closing parenthese


# about

Viperre is written by Bayle Shanks, and is no longer actively developed, although i use it everyday. Much of the actual code was copied-and-pasted and tweaked from other (open-source) projects.
