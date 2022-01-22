# STMO-ZOO : Color transfer using Optimal transportation done right

### Student name : Ju Hyung Lee

![alt text](https://github.com/juhlee/ColorTransfer.jl/blob/master/figs/choosing-color-scheme-368x246.png)

<h2> Welcome to the "ColorTransfer" repository in STMO zoo! </h2>

This final project is categorized as a 'tool', in which I will implement a color transportation in a different way from the one we implemented in the course (Chapter 6: Optimal Transport)!

By saying **"a different way"**, you will see:

- **No sub-sampling** of the input images
- **Clustering** of the color schemes of the original images (K-means clustering)
- **Different** formulas to calculate **color difference** between two images
- Optimal transport between the clustered color schemes **rather than** for all pixels
- Thus, **much faster execution** of the codes!

All the necessary codes are in **notebook/colortransfer.jl** (Stand-alone pluto notebook)

![alt text](https://github.com/juhlee/ColorTransfer.jl/blob/master/figs/nutshell.png)

[![Build Status](https://travis-ci.org/MichielStock/STMOZOO.svg?branch=master)](https://travis-ci.org/MichielStock/STMOZOO)[![Coverage Status](https://coveralls.io/repos/github/MichielStock/STMOZOO/badge.svg?branch=master)](https://coveralls.io/github/MichielStock/STMOZOO?branch=master) 
