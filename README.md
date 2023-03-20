# Material-Discrimination-in-Nanoparticle-Hetero-Aggregates-by-Analysis-of-STEM-images

This repositor contains experimental and simulated data as well as evaluation manuscripts for results as shown in 'Material Discrimination in Nanoparticle Hetero-Aggregates by Analysis of Scanning Transmission Electron Microscopy Images' submitted to Particle & Particle Systems Characterization

Evaluations were done with MATLAB R2020a or newer.

The evaluation consists of the following steps:

Step 1:

Normalization of the STEM-image by calculation of minimum and maximum detector intensity levels (see. Ref. 1 and 2) in the self-written MATLAB program 'ImageEval' (Ref. 3). ImageEval is not part of the manuscript and therefore not included in this repository. The resulting normalized images are located in the 'RawData' folder and are .mat-files for MATLAB, named like a timestamp, e.g. '11.47.17.mat'.

Step 2:

Manual marking of the primary particles in the STEM-image with the MATLAB program 'ParticleSuit_LT' programmed by Tim Grieb. The script starts with a manual. The resulting centers and radii of the primary particles for aggregates investigated in the present work are saved in the 'RawData' folder and are MATLAB .mat-files, named like a timestamp followed by '_PARTICLE_DATA', e.g. '11.47.17_PARTICLE_DATA.mat'.

Step 3:

The MATLAB script 'intensities_paper.m' calculates the projected thickness of the aggregate in each pixel from the geometric model and writes a list of intensity-values, which belong to primary particles (PPs) and excludes overlapping regions. These values are saved in a .mat file, named like a timestamp followed by '_1.0_intensities', e.g. '11.47.17_1.0_intensities.mat'. If the 'PARTICLE_DATA'-STRUCT remains unchanged, this step can be omitted and it can be proceeded with the script 'histograms_paper.m', as this takes some time. In the future, one could optimize the script to speed it up.

Step 4:

The MATLAB script 'histograms_paper.m' shows histograms and calculates fit functions of multiple images of aggregates. It needs an 'intensities.mat'-file as created by the script 'intensities_paper.m'. You can change the variable 'show_plots' to 0, if you are overwhelmed by plots. You can change the variable 'radii' to change the maximum distance of pixels to center of a PP, which are to be examined. This is a ratio to the radius of the PP. 0.4 means only pixels with a maximum distance of 0.4*radius of the particle, they belong to, are considered for the histogram and therefore used for the calculation of a fit function. You can also change the variable 'n_components', which is the number of components for the Gaussian mixture model, but for more components, the pairing of material to components might not work reliably.
The resulting fit functions and other variables are saved in MATLAB .mat-files, named like a timestamp followed by the radius, which you have chosen, and '_fit_functions' and followed by the number of components, you have chosen, e.g. '11.47.17_0.4_fit_functions_3Komp.mat'.

Step 5:

The script 'visualize_paper.m' visualizes the threshold calculated in 'histograms_paper'. You can change the variables 'max_radius_fit_liste' and 'n_components', depending on which fitfunctions should be used. However they have to be created first by the script 'histograms_paper.m'. It saves values of discrepancy to EDXS for calculation of an average discrepancy by appending these values to the .mat-file of the utilized fit functions.

Step 6:

The script 'summary_paper.m' creates summarizing plots and saves median values for the comparison to simulations in 'comparison_simulation_med_values.mat'. You can change the variables 'radius' and 'n_components', depending on the fit functions, you want to use.

Step 7: 

Simulations of the HAADF-STEM intensity for TiO2 and WO3 in various phases and orientations were done with the STEMsim code (Ref. 4). Results are stored in the 'RawData'-folder and named after each material and phase, e.g. 'TiO2_anatase.json'. Each file contains the HAADF-STEM intensity as a function of material, thickness, orientation and scattering-angle. Fields in the .json files are explained in the MATLAB script 'get_orientation_thickness_matrix_paper.m'. This script applies the detector sensitivity as stored in 'RawData/HAADF_Spektra_91mm_R50_v2.txt' to the simulation and calculates the HAADF-STEM intensities as shown in Figure 1 of the manuscript. This calculation is documented within the script.Finally, the script adds experimental values, saved in 'RawData/comparison_simulation_med_values.mat' in Step 6, to the simulation as shown in Figure 6 of the main manuscript.

References:
[1] J. M. LeBeau, S. Stemmer, Ultramicroscopy 2008, 108, 12 1653.

[2] A. Rosenauer, K. Gries, K. Müller, A. Pretorius, M. Schowalter, A. Avramescu, K. Engl, S. Lutgen, Ultramicroscopy 2009, 109, 9 1171.

[3] K. Müller-Caspary, T. Mehrtens, M. Schowalter, T. Grieb, A. Rosenauer, F. F. Krause, C. Mahr, P. Potapov, The 16th European Microscopy Congress, Lyon, France. 10.1002/9783527808465.EMC2016.6143.

[4] A. Rosenauer, M. Schowalter, In A. Cullis, P. Midgley, editors, Microscopy of Semiconducting Materials 2007, volume 120 of Springer Proceedings in Physics, 170–172. Springer Netherlands, ISBN 978-1-4020-8614-4, 2008.
