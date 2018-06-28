=== ADROIT Simulator 0.72 === 

RESOURCES:--

1) schema.txt		: Schema of the Model file. Use this file as a reference for building your environment.
2) Adroit.xml 		: Modle of the environment/ hand. Make your changes here.
3) Mujoco(v0.72).exe: This is the simulator in c++. It loads your model files and provides visualization.
4) wxhelp.html 		: Help on using mpc_studio.exe
5) mj.mexw64 		: mex interface to the simmulator
6) mjplot.m 		: visualizer for mex interface
7) mjsim.m 			: passive simmulator for mex. Load the model and press 'space bar' to start passive simmulation
8) AdroitSim.m 		: Simulator that we will use. Read this file to understand the instruction flow.


How to use:- 
1) Open Mujoco(v0.72).exe and drag drop Adroit.xml to load the model. Hit 'space' for passive simmulation
2) Open AdroitSim.m and follow the instruction flow.

Questions?? write to vikash@cs.washington.edu
