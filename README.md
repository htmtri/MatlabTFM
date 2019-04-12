# MatlabTFM

Included are Traction Force Microscopy (TFM) analysis using PIV for to solve for displacement and ANSYS Boundary Finite Element analysis for solving traction stress.

# Usage

## Algorithm: 
	- Crop area of interest
	- Adjust loaded and null images to compensate for drifting effect
	- Compute cross correlation between null and loaded to get the displacement field u
	- Construct ECM model for BEM analysis (length,width,height and stiffness) and convert pixels to SI length
	- Perform BEM using ANSYS to get traction stress
	- Calulation of force, moment, energy from stress
 
	
## Module 1: Static TFM
- TFM_Prep(): 
Gathering all information necessary for analysis. No arg input is needed. Output: struct file containing images,gel,ansys information. This function asks for: 
	- the phase/bright field to crop ROI
	- a loaded image and a null image and attempt to dedrift 
	(ver2 included bpass filter - need to implement padarray for huge drift (>100px drift))
	- pixel to um ratio
	- gel information
	- ANSYS information
	- name of the save file

- TFM_disp(argin1): Get displacement. Input: struct file created from TFM_Prep(). output: add piv information to the struct file.
This function will call mpiv to perform cross correlation between loaded and null images. By the end of PIV it will ask for bogus displacement removal. Look at the overlay image between loaded and null to verify true/false displacement detected. 
	- ver2 included smoothing and recursive check call.
	- ver3 included auto remove displacement outside cell region and autosave result.

***Note: TFM_disp and TFM_disp2 will not autosave the resultant displacement in the struct file. Manually save using save('filename.mat','-struct','ans').

- TFM_solve(argin1): Get ANSYS model and solving command. input: name of the output file. Contruct ANSYS model file for the ECM and create nodes for FEM solving.
output: ANSYS model/solver/log files and ANSYS call cmd (.bat) file. Execute .bat file to call ANSYS to solve for traction stress.
	- ver2 align displacement field correctly with stress node to reduce the amount of interpolation
	- ver3 include option to solve only for nodes inside ROI rather than the whole map.

- TFM_Plot(argin1): Plot result input: name of the output file. Read ANSYS output. Plot result displacement and stressmap.
output: add stress, force result to struct file.
	- ver2 include more calculated data and more plots.
	- ver3 include reconstruction of displacement from stress and reaction force from contractile stress.

## Module 2: Timelapse TFM
- TFMTL_Trace(argin1)
- TFMTL_Prep(argin1)
- TFMTL_disp(argin1)
- TFMTL_solve(argin1)
- TFMTL_Note(argin1)
- TFMTL_Plot(argin1)

## Module 3: Paranoma TFM

PanoTFM
