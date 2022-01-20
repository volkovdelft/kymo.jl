# kymo.jl
Julia scripts to analyze diffusion of single particles in kymographs. Improvement of the previous <a href="https://github.com/volkovdelft/kymo">Matlab script</a>. Originally used for analysis of 1D diffusion of recombinant kinetochore proteins on microtubules *in vitro* using TIRF microscopy.<br>

# Contents<br>
`kymo` is a script that fits 1D diffusion of a particle using a gaussian at each line to determine the particle position and brightness.<br>
`kymo_2channels` additionally monitors the brightness of another channel using the coordinates fitted in the primary channel - useful to detect events of recruitment of another protein imaged in a separate fluorescent channel.



# Requirements
1. A kymograph in tiff format (example ImageJ macro script for 2- and 3-channel images is provided)
2. `IJulia` with `Jupyter notebooks` and the following packages:<br>
`Images`
`PyPlot`
`Statistics`
`LsqFit`
`DelimitedFiles`
