# MazeLibrary
Almost everything you would need to create mazes for your game.
This is a **GDscript** version of the [*GrowingTree algorithm*](https://weblog.jamisbuck.org/2011/1/27/maze-generation-growing-tree-algorithm) by *Jamis Buck*

## How to use it in your own project ?

Just copy the _Maze.gd_ script from this project into your own, for instance in a dedicated directory for libraries or external codes.
Then, your code can call any available functions to create a maze according to your game needs, see example below.

## Example


## Various pick methods generate different kind of maze which can be usefull according to your needs:

### Newest
![maze-30x30-newest](https://github.com/user-attachments/assets/b2a80936-ee86-42f4-ac54-556aa879b6e2)

Create pretty standard mazes

### Oldest
![maze-30x30-oldest](https://github.com/user-attachments/assets/da458e6f-2dfa-499a-9468-5e5eca161a64)

Create weird parking spots like grid

### Random
![maze-30x30-random](https://github.com/user-attachments/assets/9ee57c3a-28cf-4f9f-b6de-9edc74b94d05)

Create... quite like a mix of the two above

### Cyclic
![maze-30x30-cyclic](https://github.com/user-attachments/assets/d19abda5-8878-46af-908c-241ad7a07a5b)

Currently it only cycle from 0 to max and so on until there is no cell to pick, generate maze similar to the Random method

### TODO

* Cyclic _Kitt_ like method (from 0 to max then goes in opposite way)
* Collapse - doesn't remember what I meant by this... need to dig from old code
* other funny methods like Fibonnaci, geometric, odd only, even only, ...
