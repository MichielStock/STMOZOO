# Assignments

This file gives a detailed overview what you have to do for this project. 

## Getting started

- [ ] pick a project (take a lood in `project ideas.md` or discuss with Michiel)
- [ ] [fork](https://docs.github.com/en/enterprise-server@2.20/github/getting-started-with-github/fork-a-repo) this repo
- [ ] create a new branch with a short indicative name, e.g. `GeneticProgramming`. **Don't use spaces in the name!**
- [ ] make a local clone of the repository 
- [ ] open a [pull request](https://docs.github.com/en/free-pro-team@latest/desktop/contributing-and-collaborating-using-github-desktop/creating-an-issue-or-pull-request) to the **master** branch of this repo. This makes it clear you are starting the project!

## Source code

Every project needs to have some source code, at least one function! You have to decide yourself which parts belong in the source code (and can hence be readily loaded by other users) and which parts of your project will be in the notebook where people can see and interact with your code.

Developping code can be done in any text editor, though we highly recommend [Visual Studio Code](https://code.visualstudio.com/), with Juno the environment for Julia. [Atom](https://atom.io/) is an alternative, but is not supported any more. When developping, you have to activate your project. Assuming that the location of the REPL is the project folder, open the Pkg manager (typing `]`) and type `activate .`. The dot indicated the current directory. If you use external packages in your project, for example Zygote or LinearAlgebra, you have to add them using `add PACKAGE` in the package manager. This will create a dependency and update the `Project.toml` file.

Importantly, all your code should be in a [module](https://docs.julialang.org/en/v1/manual/modules/), where you export only the functions that are useful for the user.

- [ ] In the `src` folder, add a new julia file with your source code, for example `geneticprogramming.jl`. Don't use spaces or capitals in the file name.
- [ ] Link your file in `STMOZOO.jl` using `include(filename)`. This will run the code.
- [ ] Create a module environment in your file for all your code. Use [camel case](https://en.wikipedia.org/wiki/Camel_case) for the name.
  - use `module GeneticProgramming begin ... end` to wrap your code;
  - import everything you need from external packages: `using LinearAlgebra: norm`;
  - export your functions using `export`
- [ ] write awesome code!
- [ ] take a look at your code regarding the [Julia style guide](https://docs.julialang.org/en/v1/manual/style-guide/)
- [ ] check the [Julia performance tips](https://docs.julialang.org/en/v1/manual/performance-tips/)
- [ ] document *every* function! Make sure that an external user can understand everything! Be liberal with comments in your code. Take a look at the [guidelines](https://docs.julialang.org/en/v1/manual/documentation/)

## Unit tests

Great, we have written some code. The question is, does it work? Likely you have experimented in the REPL. For a larger project, we would like to have guaranties that it works though. Luckily, this is very easy in Julia, where we can readily use [Unit testing](https://docs.julialang.org/en/v1/stdlib/Test/).

You will have to write a file with some unit tests, ideally testing every function you have written! The fraction of functions that are tested is called [code coverage](https://en.wikipedia.org/wiki/Code_coverage). For this project, it is monitored automatically using Travis (check the button at the readme page!). Currently coverage is 100%, so help keeping this high!

Tests can be done using the `@test` macro. You evaluate some functions and check their results. The result should evaluate to `true`. For example: `@test 1+1 == 2` or `@test √(9) ≈ 3.0`. 

It makes sense to group several tests, which can be done using `@testset "names of tests" begin ... end`.

Your assignments:
- [ ] add a source file to the `test/` folder, same name as you source code file.
- [ ] add an `include(...)` with the filename in `runtests.jl`
- [ ] in your file, add a block `@testset "MyModule" begin ... end` with a series of sensible unit tests. Use subblocks of `@testset` if needed.
- [ ] run your tests, in the package manager, type `test`. It will run all tests and generate a report.

Travis will automatically run your unit tests online when you push to the origin repo.

## Documentation

Hopefully, you have already documented all your functions, so this should be a breeze! We will generate a documentation page using the Documenter package.

## Notebook

## Code review