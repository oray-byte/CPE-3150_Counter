# CPE-3150_Counter

## Introduction
This was a project for CPE 3150 Introduction to Micro Embedded Systems at Missouri University of Science and Technology. Our goal was to make a functional counter with sound and blinking lights using the Atmega32u4 Circuit Playground board. The Atmega32u4 is a 8-bit RISC-based microcontroller with 32 KB of programming flash memory, 2.5KB of SRAM, and 1 KB EEPROM. This project was done with a team of four people, including myself. 

## Description
The idea of the project is to accept user input with the two buttons on the Atmega32u4 circuit board. The left button is to change modes between incrementing and decrementing. While the right button is used to either increment or decrement the count based on the count. Meanwhile, a LED and sound were to signifiy the current condition of the state. If the `COUNT = 0`, the LED would be off. If the `COUNT = 24`, the LED would be constantly on. Otherwise, the LED would flash according to the count. With that being said, our range is 0 - 24 for count, so our edge cases were 0 and 24. If the count was decremented from 0, then a 1 kHz soundwave will play and the count will be set to 24. Likewise, if the count is incremented from 24, a 1.5 kHz soundwave will play and the count will be set to 0.

We had four main objects:
- Keep track of the state (the count)
- Handle user input
- Blink a LED based on the current state
- Play a sound when the state reached predetermined edge cases

### Keeping Track of the State
To accomplish this, we simply used the `.DEF` directive to assign `COUNT` to `R16` and `COUNT_MODE` to `R17`. This allowed us to easily recogonize what register our states were being stored in. The `COUNT` register would keep track of the current state while the `COUNT_MODE` register would keep track of if we are incrementing or decrementing. 

### Handling User Input
First, we use `SBI DDRD, 4`, `SBI PORTD, 4`, `SBI DDRF, 4`, and `SBI PORTF, 6` to set bit 4 and 6 of ports D and F respectfully to inputs and set the pull-up resistors. The left button, as previously mentioned, is used for changing modes between incrementing and decrementing. In our `main` loop, we call the `changeMode` subroutine if the left button is pressed, and call the `counter` subroutine if the right button is pressed.

The `changeMode` subroutine compares the current `COUNT_MODE` against 0 (0 to increment, 1 to decrement). If the current value of `COUNT_MODE` was 0, then we branch to `negative` and make the `COUNT_MODE` equal to 1. However, if `COUNT_MODE` was 1, we then make it equal to 0. 

The `counter` subroutine either increments or decrements `COUNT` based on the value of `COUNT_MODE` while also checking for the aforementioned edge cases. First, `counter` branches to `increment` if `COUNT_MODE` is equal to 0. If the `COUNT` is incremented, then we check to see if it is greater than or equal to 25 (since if it was 24 and we added one, it would be 25). If so, we call `maxValue` which in turn calls `maxValueSound` that creates the 1.5 kHz square soundwave. Alternatively, if the `COUNT` is decremented, we fall through the `increment` branch and decrement `COUNT`. After decrementing, we check to see if `COUNT` is negative since if we decremented from 0, it should be negative. If so, then we branch to `minValue` which calls `minValueSound` that creates the 1 kHz square soundwave. 

### Blinking a LED Based on the Current State
The `LED` subroutine handles the LED blinking based on the current state. In the `LED` subroutine, we blink LED 13 based on the value of `COUNT`. Additionally, we turn the LED off if the value of `COUNT` is 0 and turn the LED on constantly if the value of `COUNT` is 24. The `LED` subroutine is an infinite loop until the user pressed a button. When a button is pressed, we return from the `LED` subroutine and carry out the respective functions for the buttons. The `LED` subroutine is an infinite loop because we need the lights to constantly blink.

### Play a Sound when the State Reaches Predetermined Edge Cases
This required a couple of calculations to determine how long the square wave needed to be. The Atmega32u4 has a crystal frequency of 8Mhz. Additionally, one clock cycle coresponds to 1 machine cycle in the Atmega32u4. If we take [1/(2 * *desired frequency*)] we get the amount of time required required delay. To find the number of machine cycles required to delay for that time, we take [x / *crystal frequency*] = *time required* and solve for x. Finally, we create a function that takes x machine cycles. After creating such a delay function, we use the instruction `SBI PORTC, 6` to set the 6th bit of port C (the speaker) to output sound, call the delay function, and then clear the 6th bit of port C using `CBI PORTC, 6`; we loop through this y amount of times. Larger y = more time the sound is played.
