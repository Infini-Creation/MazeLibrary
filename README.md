# MazeLibrary
Almost everything you would need to create mazes for your game.
This is a **GDscript** version of the [*GrowingTree algorithm*](https://weblog.jamisbuck.org/2011/1/27/maze-generation-growing-tree-algorithm) by *Jamis Buck*

## How to use it in your own project ?

Just copy the _Maze.gd_ script from this project into your own, for instance in a dedicated directory for libraries or external codes.
Then, your code can call any available functions to create a maze according to your game needs, see example below.

## Example

One of the most basic usage of the Maze Library is something like this:

Create a new _scene_, add ascript to it which is:

```
var maze : Maze

func _ready() -> void:
	maze = Maze.new()
	maze.init()
	maze.buildBazeMaze(10, 10)

	maze.GenerateTWMaze_GrowingTree()

	maze.dumpMaze()
```

It will simply generate a new maze of 10 cells wide and 10 cells high using default picking method (see below) and print it on console.

Maze data will looks like this:
```
 12 10 2 12 10 10 10 10 10 6
 9 6 12 3 12 6 12 6 12 7
 12 7 9 10 3 5 5 9 3 5
 5 1 12 10 10 3 5 8 6 5
 9 14 11 2 12 6 9 6 9 7
 4 1 12 10 3 9 6 9 6 5
 5 12 3 4 12 6 5 12 3 1
 9 3 12 7 5 9 3 5 12 6
 12 10 3 1 5 8 10 11 3 5
 9 10 10 10 11 10 10 10 10 3

```

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

### Kitt cycle

Picked cell are taken from 0 to max then in the opposite way.
Despite as original as it is, this picking method produce disappointing results.

### TODO

* Collapse - doesn't remember what I meant by this... need to dig from old code
* other funny methods like Fibonnaci, geometric, odd only, even only, ...
