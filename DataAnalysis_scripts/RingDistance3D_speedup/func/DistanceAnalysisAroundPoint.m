function [INDE,param] = DistanceAnalysisAroundPoint(segment_dir_bacter,segment_dir_nuetrophil,options)

% need Mosaic file in the data dir
OBJECT=returnSystemSpecificClass;
param = OBJECT.readMosaicMetaData(getTiledAcquisitionParamFile);
param.method = options.method;

param.RadiusSphere = options.RadiusSphere;
if strcmp(param.method,'Ring')
    param.RadiusSphere2 = options.RadiusSphere2;
end



Zratio = param.xres/(2*param.zres);
% make table of indeces
INDE = [reshape(repmat(1:param.sections,param.layers,1),1,param.sections*param.layers);...
    repmat(1:param.layers,1,param.sections);...
    1:param.sections*param.layers];
INDE = [INDE;repmat(param.RadiusSphere,1,param.sections* param.layers)];
INDE(5,:) = zeros(1,param.sections* param.layers );
% Ntotal = cell(1,param.sections* param.layers);

Zpixels = floor(param.RadiusSphere*Zratio);
if strcmp(param.method,'Ring')
    Zpixels2 = floor(param.RadiusSphere2*Zratio);
end

% load al the neutrophil slices
d = dir(fullfile(segment_dir_nuetrophil, '*pbm'));
NAMESn = cell(numel(d),1);
for i = 1:numel(d)
    NAMESn{i} = fullfile(d(i).folder,d(i).name);
end
NeutrMask = cell(numel(d),1);
parfor j = 1:numel(d)
    NeutrMask{j} = imread(NAMESn{j});
end
dp = dir(fullfile(segment_dir_nuetrophil, 'positions_*txt'));
NAMESp = cell(numel(dp),1);
for i = 1:numel(dp)
    NAMESp{i} = fullfile(dp(i).folder,dp(i).name);
end

MASK_DATA= cell(numel(d),1);
% build a table with all the slices included
Objnum = 1;
for z = 1:numel(d)

    BExt = ckeckBacteriumExist( z,NAMESp);
    if BExt==1
        [slices, num, cnt] = get3DsphereParam(z,Zpixels,param);
%         param.num = num;
%         param.cnt = cnt;
        if strcmp(param.method,'Ring')
           [slices2, num2, cnt2] = get3DsphereParam(z,Zpixels2,param);
           param.num2 = num2;
           param.cnt2 = cnt2;
        end
        % coordinates fo the bacterium center
        Object_coor_center = round(loadBacteriumImage(segment_dir_bacter,INDE,slices(cnt)));
        object_number = Objnum:Objnum+length(Object_coor_center)-1;

        % sphere parameters for a specific radious
        coeff = SphereParameters(param.RadiusSphere,num,length(slices));
        Rtouching = repmat(param.RadiusSphere,1, length(coeff)).^2 - coeff.^2;
  
        % all touchin slices and their correcponding radiouses
        for t =1:length(slices)
            sl = slices(t);
             % [currect slice z coordinate, XYZcenter, object_index, radius_object_inAspecificSlice]
            MASK_touching = [repmat(sl,length(Object_coor_center),1), ...
                [Object_coor_center,repmat(slices(cnt),length(Object_coor_center),1)],...
                object_number', repmat(Rtouching(t),length(Object_coor_center),1)];
            MASK_DATA{sl} = [MASK_DATA{sl};MASK_touching];
        end
        Objnum = Objnum+length(Object_coor_center); 
    end
    fprintf('Building mask parameters for slice %i\n',z);
end
        
        
% run the script ones per slices
N = cell(numel(d),1);
for z=1:numel(d)
    N{z}= NumberNeutrophilperSlice(NeutrMask{z}, MASK_DATA{z});
end
N_stack = [];
for z=1:numel(d)
    N_stack = [N_stack;N{z}];
end

Nobj = zeros(1,Objnum-1);
Volume = zeros(1,Objnum-1);
COOR = zeros(Objnum-1,3);
for ob=1:Objnum-1
   OBJ = N_stack(N_stack(:,2)==ob,:); 
   Volume(ob) = sum(OBJ(:,7));
   Nobj(ob) = sum(OBJ(:,3))./Volume(ob);
   if sum(OBJ(1,4:6)-OBJ(2,4:6))~=0
       disp('error with coordinates')
   else
       COOR(ob,:) = OBJ(1,4:6);
   end
end

Object_num = (1:Objnum-1)';
Num_neutroph = Nobj';
CenterX = COOR(:,1);
CenterY = COOR(:,2);
CenterZ = COOR(:,3);
Volume_Sphere = Volume';
Q = table(Object_num,Num_neutroph,CenterX,CenterY,CenterZ,Volume_Sphere);
filename = fullfile(segment_dir_bacter, sprintf('Neutrophils_distribution_radius_%ipix.txt',round(param.RadiusSphere)));
% filename = sprintf('Neutrophils_distribution_radius_%ipix.txt',round(param.RadiusSphere));
writetable(Q,filename) 


function [slices, num, cnt] = get3DsphereParam(z,Zpixels,param )

if z <= Zpixels
   slices = 1:z+Zpixels; 
   num = [z-1;Zpixels]; 
   cnt = z;
elseif (param.sections*param.layers-z)<Zpixels
   slices = z-Zpixels:param.sections*param.layers; 
   num = [Zpixels;param.sections*param.layers-z];
   cnt = Zpixels+1;
else
    % midles case
    num = Zpixels;
    slices = z-Zpixels:z+Zpixels;
    cnt = Zpixels+1;
end
