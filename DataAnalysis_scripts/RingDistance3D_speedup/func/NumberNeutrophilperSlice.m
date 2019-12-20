function  N  = NumberNeutrophilperSlice(NeutrMask, MASK_DATA_slice)
%[currect slice z coordinate, XYZcenter, object_index, radius_object_inAspecificSlice]
N = zeros( size(MASK_DATA_slice,1),7);
% N = cell(size(MASK_DATA_slice,1),1);
ObjectNUM = MASK_DATA_slice(:,5);
RadiusSPHERE =  MASK_DATA_slice(:,6);
COOR = MASK_DATA_slice(:,2:3);
Central_Z = MASK_DATA_slice(:,4);
tic;
fprintf('Total number of objects %i\n',size(MASK_DATA_slice,1));
parfor i =1:size(MASK_DATA_slice,1)
    NMask=NeutrMask;
    Objectnum = ObjectNUM(i);
    RadiusSphere =RadiusSPHERE(i);
    coor =COOR(i,:);
    circlePixels = buildMask(RadiusSphere,coor,NeutrMask);
    if coor(1)-sqrt(RadiusSphere)-1>0 && coor(2)-sqrt(RadiusSphere)-1>0  && RadiusSphere~=0
       NMask = imcrop(NeutrMask,...
        [coor(1)-sqrt(RadiusSphere)-1 coor(2)-sqrt(RadiusSphere)-1 ...
        2*sqrt(RadiusSphere)+1 2*sqrt(RadiusSphere)+1]);
    end
    Volume = pi*RadiusSphere^2;
    if RadiusSphere==0
        NumNeutroph = NMask(coor(1),coor(2));
        Volume = 1;
    else
        NumNeutroph = sum(sum(NMask.*circlePixels));
    end
    slice = MASK_DATA_slice(i,1);
%     coor_xyz = [coor,Central_Z(i)];
    % mask volume for bordering cases
    
    N(i,:) = [slice,Objectnum, NumNeutroph,coor,Central_Z(i),Volume];
%         figure, imshow(circlePixels) 
%         pause
%          figure, imshow(NMask.*circlePixels) 
%     fprintf('Object %i out of %i\n',i,size(MASK_DATA_slice,1));
end
fprintf('Time per slice %i min\n',round(toc/60))


function circlePixels = buildMask(r,coor, NeutrMask)

if r==0
   circlePixels = zeros(size(NeutrMask));
   circlePixels(coor(1),coor(2)) = 1;
%    circlePixels = imcrop(circlePixels,[coor(1)-30 , coor(2)-30 30 30]);
else
    [columnsInImage rowsInImage] = meshgrid(1:size(NeutrMask,2), 1:size(NeutrMask,1));
    circlePixels = (rowsInImage - coor(2)).^2 ...
                    + (columnsInImage - coor(1)).^2 <= r;
    if coor(1)-sqrt(r)-1>0 && coor(2)-sqrt(r)-1>0            
        circlePixels = imcrop(circlePixels,[coor(1)-sqrt(r)-1 coor(2)-sqrt(r)-1 2*sqrt(r)+1 2*sqrt(r)+1]);
    end
end

