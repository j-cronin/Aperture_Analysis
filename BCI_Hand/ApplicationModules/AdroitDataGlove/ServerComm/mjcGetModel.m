%MJGETMODEL Get Model from Mujoco
%
%  Model = mjGetModel(so)
%
%  so: socket object returned by mjConnect
%
%  Model: structure with fields from mjModel
%
%  Model can be changed by the user, and then passed to mjSetModel to
%  implement the model changes in Mujoco

function Model = mjcGetModel(so)
nModel	= mjcGetField(so, 'nModel',	[41 1]);
Model 	= expandModel(nModel, []);
Model.jnt_range = mjcGetField(so, 'jnt_range',	[Model.njnt 2]);
Model.qpos0		= mjcGetField(so, 'qpos0',		[Model.nq	1]);


%% Fetch field from Mujoco
function field_data = mjcGetField(so, field_name, size)

if(strcmp(field_name,'nModel'))
	id = 3; type='int';
elseif(strcmp(field_name,'jnt_range'))
	id = 4; type='mjtNum';
elseif(strcmp(field_name,'qpos0'))
	id = 5; type='mjtNum';
end

field_data = mjcGet(so, id, size(1)*size(2), type);
field_data = reshape(field_data, size(2), size(1))';


%% Expand the sizes into Model
function Model = expandModel(data, Model)
Model.nq   		 	= data(1);
Model.nv	   		= data(2);
Model.nu	   		= data(3);
Model.na	   		= data(4);
Model.nbody	   		= data(5);
Model.njnt	   		= data(6);
Model.ngeom	   		= data(7);
Model.nsite		   	= data(8);
Model.ncam	   		= data(9);
Model.nmesh    		= data(10);
Model.nmeshvert    	= data(11);
Model.nmeshface    	= data(12);
Model.nmeshgraph   	= data(13);
Model.nhfield    	= data(14);
Model.nhfielddata   = data(15);
Model.ncpair    	= data(16);
Model.neq    		= data(17);
Model.ntendon    	= data(18);
Model.nwrap    		= data(19);
Model.ncustom    	= data(20);
Model.ncustomdata   = data(21);
Model.ntext    		= data(22);
Model.ntextdata    	= data(23);
Model.nbody_user    = data(24);
Model.njnt_user    	= data(25);
Model.ngeom_user    = data(26);
Model.nsite_user    = data(27);
Model.ncam_user    	= data(28);
Model.neq_user    	= data(29);
Model.ntendon_user 	= data(30);
Model.nactuator_user= data(31);
Model.nnames    	= data(32);
Model.nM    		= data(33);
Model.nemax    	 	= data(34);
Model.nlmax    	 	= data(35);
Model.ncmax    	 	= data(36);
Model.njmax    	 	= data(37);
Model.nctotmax  	= data(38);
Model.nstack    	= data(39);
Model.nuserdata     = data(40);
Model.nbuffer    	= data(41);
