# vmk124
Velleman MK124 rolling message alternative firmware (More text, nonvolatile storage)

In 2007 I started writing alternative firmware for Velleman mini-kit 124 "rolling message" because 17-year old me then wanted to use more then 16 characters and keep the text even when the battery got removed. Meanwhile I learned how to code. Somewhere 2012 I succeeded. Basicly, this is my first somewhat usefull piece of software. I know it is used in a geocache puzzle somewhere in Belgium by a person I never personally met. I like it when my hobby projects help others and I like hearing from them. So I decided (in 2021) to put it on GitHub with a MIT license.

the .bas file is the source code. The .hex file can be programmed in a PIC16F628A and put in the mini-kit, replacing the original mcu. Use the 16F628_A_, since the 16F628 withouth the A has a different clock circuit and can only be used with a few hardware and software modifications as described (in Dutch) on my old hobby website linked below.

https://www.youtube.com/watch?v=7qthfG8z8Z0 shows functionality.

More information on my old website, in Dutch: https://home.deds.nl/~elektronica/index.html?/~elektronica/vmk124hck.html&1
