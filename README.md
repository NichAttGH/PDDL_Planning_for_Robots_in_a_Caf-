# PDDL Planning for Robots in a Café
This is a project done for the undergraduate course “Artificial Intelligence for Robotics” at the University of Genova.

## Description
This project sets out to analyze the efficiency of a PDDL planning model for managing the movements and actions of a waiter robot and a barista robot in a coffee shop. The goal is to optimize the coffee shop's operations, like drink preparation, table service, and cleaning, using automated planning. [Report](https://github.com/NichAttGH/PDDL_Planning_for_Robots_in_a_Cafe/blob/main/Report.pdf) for more details.

## Tasks
- Defined the coffee shop environment, including tables, the bar, and robot locations.
- Defined operational constraints like drink preparation times, tray capacity, and cleaning times.
- Used PDDL to model robot actions like making drinks, serving customers, and cleaning tables.
- Defined various problem scenarios with different customer orders and cleaning requirements.
- Executed the planning model using ENHSP with various planner configurations.
- Evaluated the efficiency of the model based on planning execution time and total action execution time.

## Tools used
- [ENHSP (version 20)](https://sites.google.com/view/enhsp/)  (Expressive Numeric Heuristic Search Planner): A PDDL automated planning system that was used to generate plans for the robots.
- [PDDL](https://planning.wiki/guide/whatis/pddl) (Planning Domain Definition Language): A standard language for representing planning problems, used to model the coffee shop environment, the robots, and their actions.

## Results
- The PDDL model proved effective for planning robot actions for various scenarios.
- Different configurations of the ENHSP planner showed variable performance regarding planning time and the number of nodes expanded.
- Action execution time varied depending on the problem’s complexity.

## How to test

*Remember to install ENHSP20 before running!*

To execute planning run the script:
```bash
java -jar ENHSP/enhsp.jar -o <domain> -f <problem> -planner <configuration>

# " opt-blind " configuration for the first 3 problems and " sat-hmrph " for the last problem
```

### Dependencies

The only dependency needed is Java (15 possibly, otherwise also 17 and 18 should work):
```bash
sudo apt install openjdk-17-jdk
```

*Note*: if you choose to install Java 15, you'll have to install it manually.

## Collaborators
Thanks to [Claudio Tomaiuolo](https://github.com/ClousTom), [Teodoro Lima](https://github.com/teolima99) and [Baris Aker](https://github.com/barisakerr) for working with me on this project!
