
# SingleCellNMF

This project implements coupled non-negative matrix factorization(NMF) for multiomics single-cell data analysis.

## What are the challenges of multiomics data?

Single-cell technologies allow studying cellular heterogeneity at unprecedented resolution thousands of cells. It is possible to sequence transcriptome, epigenome, proteome, and other -omes of single cells, and the price is constantly dropping. As it is possible to profile both epigenetic features and transcriptome, we can try to connect these features to uncover the mechanisms of regulatory heterogeneity. However, integrating the data from multiple experiments and modalities can be quite challenging due to technical and biological variability. Single-cell data analysis is full of challenges and most tools are relatively new. For example, chromatin accessibility measurements at the single-cell level are extremely sparse, and it is not always possible to reliably recover all the cell types from such measurements.
 
## What is matrix factorization?

Matrix factorization(MF) has been been used to solve the challenges of single-cell data intergration. The main idea is to jointly factorize data matrices from multiple modalities to infer "latent space" - shared low-dimensional representation of all modalities. Several authors proposed methods based on MF:

- [Coupled NMF](https://doi.org/10.1073/pnas.1805681115)
- [LIGER](https://doi.org/10.1016/j.cell.2019.05.006)
- [MOFA and MOFA+](https://doi.org/10.1186/s13059-020-02015-1)
- [scAI](https://doi.org/10.1186/s13059-020-1932-8)
- [DC3](https://doi.org/10.1038/s41467-019-12547-1)

More formally, given an input matrix `X`, we seek such matrices `W` and `H` that minimize `X - WH`. The product WH approximates X in a low-dimensional space and captures relevant features of the data. NMF introduces additional constraint such what W and H have to be component-wise non-negative:

$\underset{W\geq0, H\geq0}{min} \Vert{X-WH}\rVert_{F}^{2}$

Additionaly, NMF has an inherent clustering property, which is useful since clustering is part of typical single-cell analysis. 

scAI authors proposed additional constraints which allow aggregating sparse epigenetic signal over the cells, which improves the clustering and infers more meaningful latent factors. The optimization objective is formulated as:


## Solving NMF 

NMF is NP-hard problem and no method guarantees the optimal solution. 
