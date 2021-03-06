# MatlabTFM

Included are Traction Force Microscopy (TFM) analysis using PIV for to solve for displacement and ANSYS Finite Element analysis for solving traction stress.

# Overview:

How does cells move, sense, adapt to the surrounding environment? By applying force to the environment (called extracellular matrix ECM). Cellular force, generated by interaction of actomyosin inside cell body, is transmitted through a network of cytoskeleton structure and deposited to the underlying/surrounding substrate via an assembly of integrin-ligand proteins (called focal adhesions). Can we quantify this amount of force to study the mechanical reponse to the different environment of different types of cell, different phenotypes in order to investigate their biological role or impairment in the biological function? Welcome to traction force microscopy! Here we try to quatify these cellular forces by capturing the deformation of the elastic substrate cause by cells and apply the theory of linear elastostatics to reconstruct the force applied from the map of deformation and elastic properties of substrate.

 - Schematic of procedure: preparation of TFM substrate => Culturing cells (w/wo treatment) on substrate => Captureing cell state (cell img - preferably fluorescence) => Captureing substrate deformation (loaded img) => Releasing cell from substrate (null img) => quantify deformation => Force reconstruction => Traction stress/force analysis.

 - Good review paper of the technique: Ulrich S.Schwarz Jérôme R.D.Soiné. Traction force microscopy on soft elastic substrates: A guide to recent computational advances. Molecular Cell Research, 2015.

 - Mathematical Framework: Richard Michel, Valentina Peschetola, Guido Vitale, Jocelyn Etienne, Alain Duperray, et al.. Mathematical
framework for Traction Force Microscopy. ESAIM: Proceedings, EDP Sciences, 2013

 - Experimental Framework: Sergey V. Plotnikov, Benedikt Sabass, Ulrich S. Schwarz, Clare M. Waterman, High resolution
traction force microscopy. Methods in Cell Biology, volume 123, 2014

 - Solving analytically: 
 	+ Boussinesq solution to Green's function in Fourier space (FTTC): U. S. Schwarz et al., Calculation of forces at focal adhesions from elastic substrate data: The effect of localized force and the need for regularization, Biophys. J, 83 (2002)
 	+ Improvement using regularization: B. Sabass, M.L. Gardel, C.M. Waterman, U.S. Schwarz, High resolution traction force microscopy based on experimental and computational advances, Biophys. J. 94 (2008)

 - Solving by discretization : 
 	+ Boundary Element Method (BEM): Micah Dembo, Yu-Li Wang, Stresses at the cell-to-substrate interface during locomotion of fibroblasts, Biophys. J. 76 (1999) 2307–2316.
 	+ Finite Element Method (FEM): D. Ambrosi, Cellular traction as an inverse problem, SIAM J. Appl. Math. 66 (2006)

# Usage

## Requirement
Matlab 2014b or above (including Image Processing, Curve Fitting, Signal Processing, Parallel Computing and Bioinformatics toolboxes) 

ANSYS Mechanical APDL 13.0 or above 

mpiv toobox for PIV analysis - http://www.oceanwave.jp/softwares/mpiv/

DACE (Matlab Kriging Toolbox) for advanced interpolations - http://www2.imm.dtu.dk/~hbn/dace/

## Algorithm: 
	- Crop area of interest
	- Adjust loaded and null images to compensate for drifting effect
	- Compute cross correlation between null and loaded to get the displacement field u
	- Construct ECM model for FEM analysis (length,width,height and stiffness) and convert pixels to SI length
	- Perform FEM using ANSYS to get traction stress
	- Calulation of force, moment, energy from stress
 
	
## Module 1: Static TFM

 - TFM_Prep(): Gathering all information necessary for analysis including filtering image (bpass) and stage dedriftting (im_shift).
Requires no input parameters. This function asks for: 
	- the phase/bright field to crop ROI
	- a loaded image and a null image and attempt to dedrift 
	(ver2 included bpass filter - need to implement padarray for huge drift (>100px drift))
	- pixel to um ratio
	- gel information
	- ANSYS information
	- name of the save file
output: struct file containing images,gel,ansys information.
 - TFM_Prep2(): Removed redundant images writeout, added bandpass filter for beads imgs, added several addition information to the output struct file.
 
 - TFM_disp(in1): using PIV to compare loaded and null force beads imgs to get the displacement field.
input: struct file created from TFM_Prep(). This function will call mpiv to perform cross correlation between loaded and null images.
By the end of PIV it will ask for bogus displacement removal. Look at the overlay image between loaded and null to verify true/false displacement detected.
(ver2-TFM_disp2(in1) included smoothing).
output: add piv information to the struct file.
***Note: TFM_disp and TFM_disp2 will not autosave the resultant displacement in the struct file. Manually save using save('filename.mat','-struct','ans').

 - TFM_disp3(in1): added auto/manual boundary expand for noise calculation of regions surrounding cells. Autosave result and ouput an overlay beads image with raw displacement, dedrifted displacement and filtered displacement.If the number of filtered nodes is smaller than the 10% of the number of nodes inside the cell, the code will print a warning.

 - TFM_solve(in1): Get ANSYS model and solving command
input: name of the output file. Contruct ANSYS model file for the ECM and create nodes for FEM solving.
output: ANSYS model/solver/log files and ANSYS call cmd (.bat) file. Execute .bat file to call ANSYS to solve for traction stress.
(ver2 include option to solve only for nodes inside ROI rather than the whole map).

 - TFM_solve3(in1,varargin): included varargin for boundary condition, added noise filter for boundary solving method; optimized variables/indexes for parallel run. If the number of filtered nodes is smaller than the a threshold number of nodes inside the cell, the code will print a warning and output the error file detailing number of filtered nodes and inner nodes. 

 - TFM_Plot(in1): Plot result
input: name of the output file. Read ANSYS output. Plot result displacement and stressmap.
output: add stress, force result to struct file.
(ver2 include more calculated data and more plots. ver3 include reconstruction of displacement from stress and reaction force from contractile stress. ver4 add a switch for debugging by comparing displacement output of ANSYS and PIV) 
***Note: readnode() in TFM_plot does not handle empty cell well (which is somtimes spitted out by Ansys solving for 'close to nulled' displacement field)  

## Module 2: Timelapse TFM

- TFMTL_Trace3(argin1)

- TFMTL_Trace4(argin1)

- FTFMTL_Trace(argin1)

- TFMTL_Prep3(argin1)

- TFMTL_Prep4(argin1) - parallel

- TFMTL_disp(argin1)

- TFMTL_disp2(argin1) - parallel

- TFMTL_solve(argin1) - 
***Note: ANSYS is instructed to used upto 24 cores for solving a single cell's mesh (cannot parallel run multiple cells)

- TFMTL_Note(argin1)

- TFMTL_Plot(argin1)

- TFMTL_Plot2(argin1) - parallel


## Module 3: Paranoma TFM

PanoTFM

*** Problem: Analysing images pre and post stitching does not yield similar result near edges

# Acknowledgement

Special thanks to:
 - Professor Qi Wen - the original author of static TFM code https://www.wpi.edu/people/faculty/qwen
 - Nobuhito Mori and Kuang-An Chang for MPIV module (especially for the implementation of MQD) http://www.oceanwave.jp/softwares/mpiv_doc/index.html
 - Daniel Blair and Eric Dufresne for implementation of PT_IDL code with image filter in Matlab http://site.physics.georgetown.edu/matlab/
