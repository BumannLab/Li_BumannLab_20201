function [INDE,param] = DistanceAnalysisAroundPoint(segment_dir_bacter,segment_dir_nuetrophil,options)

% need Mosaic file in the data dir
OBJECT=returnSystemSpecificClass;
param = OBJECT.readMosaicMetaData(getTiledAcquisitionParamFile);
param.method = options.method;

param.RadiusSphere = options.RadiusSphere;
if strcmp(param.method,'Ring')
    param.RadiusSphere2 = options.RadiusSphere2;
end



Zratio = param.xres/param.zres;
% make table of indeces
INDE = [reshape(repmat(1:param.sections,param.layers,1),1,param.sections*param.layers);...
    repmat(1:param.layers,1,param.sections);...
    1:param.sections*param.layers];
INDE = [INDE;repmat(param.RadiusSphere,1,param.sections* param.layers)];
INDE(5,:) = zeros(1,param.sections* param.layers );
Ntotal = cell(1,param.sections* param.layers);

Zpixels = floor(param.RadiusSphere*Zratio);
if strcmp(param.method,'Ring')
    Zpixels2 = floor(param.RadiusSphere2*Zratio);
end


% load needed amount of images
for i=1:param.sections
    for j=1:param.layers
        % get the names we need to load
        z = find(INDE(1,:)==i & INDE(2,:)==j);
        % check if there are any bacteria
        BExt = ckeckBacteriumExist(segment_dir_bacter,i,j);

        if BExt==1
            [slices, num, cnt] = get3DsphereParam(z,Zpixels,param);
            param.num = num;
             param.cnt = cnt;
            if strcmp(param.method,'Ring')
               [slices2, num2, cnt2] = get3DsphereParam(z,Zpixels2,param);
               param.num2 = num2;
               param.cnt2 = cnt2;
            end
            
            coorB = loadBacteriumImage(segment_dir_bacter,INDE,slices(cnt));
            INDE(5,z) = size(coorB,1);
            % calculate distances for several slices
            param.coeff = SphereParameters(param.RadiusSphere,param.num,length(slices));
            if strcmp(param.method,'Ring')
                param.coeff2 = SphereParameters(param.RadiusSphere2,param.num2,length(slices2));
%                 N2 = zeros(size(coorB,1),length(slices2));
            end
            N = zeros(size(coorB,1),length(slices));
%             j
%             i
            frames = INDE(1,slices);
            opticals = INDE(2,slices);
            fprintf('Load %i slices\n', length(slices));
            fprintf('Frames %i\n',frames) ;   
            parfor sl = 1:length(slices)% check parfor
                frame = frames(sl);
                optical = opticals(sl);
                % load images
                if frame < 10 
                  counter = strcat('00',int2str(frame)); 
                elseif frame < 100 
                  counter = strcat('0',int2str(frame));   
                else
                  counter = int2str(frame);   
                end
                name = strcat('section_', counter);
%                 fprintf('Loading frame %i opt %i and calculating number of neutrophils...\n',frame, optical);
                mask_name = [segment_dir_nuetrophil, name, '_', int2str(optical) ,'.pbm'];
                MASK_neutriphil = imread(mask_name);
                
                % for several bacteria
                N(:,sl)= NumberNeutrophilSlice(MASK_neutriphil,coorB,sl,param);

            end
            

            Ntotal{z} = sum(N,2);
            save([segment_dir_bacter 'Distance_tmp.mat'], 'Ntotal');
        end
    end
   fprintf('**********Section %i is finished out of %i**********\n',i,param.sections);

end

A = NaN(max(INDE(5,:)),param.sections* param.layers);
for n = 1:param.sections* param.layers
    sums = Ntotal{n};
    if ~isempty(sums)
        A(1:length(sums),n) = sums;
    end
end

INDE = [INDE;A];
names = {'Frame','Optical','Z', 'Radius','Num_bacter', 'Num_neuttr'};
Q = array2table(INDE');
Q.Properties.VariableNames(1:6) = names;
filename = [segment_dir_bacter sprintf('Neutrophils_distribution_radius_%i.txt',RadiusSphere)];
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
