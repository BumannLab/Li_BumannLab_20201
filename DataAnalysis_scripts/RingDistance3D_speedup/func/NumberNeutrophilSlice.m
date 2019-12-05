function  Nbacter =  NumberNeutrophilSlice(MASK_neutriphil,coorB,sl,param)

% in 3D
RadiusSphere = param.RadiusSphere;
coeff = param.coeff(sl);
Nbacter = zeros(1,size(coorB,1));

switch param.method
    case 'Sphere' 
    % loop through all the bacteria

    parfor b = 1:size(coorB,1)
        % Get 3d distribution of nutrophils around
        coor = round(coorB(b,:));
        circlePixels = buildMask(RadiusSphere,coeff,coor,MASK_neutriphil);
    %         figure, imshow(circlePixels)  
    %         pause
            % crop nuetrophils around
            Neutrophils = MASK_neutriphil.*circlePixels;

    %       figure, imshow(Neutrophils)  
    %         pause
        Nbacter(b) = sum(Neutrophils(:));

    end

    case 'Ring'
        Shift = RingShift(param,sl); % index for the smaller circle
        
        if Shift <= 0 || Shift > length(param.coeff2)
           for b = 1:size(coorB,1)
                % Get 3d distribution of nutrophils around
                coor = round(coorB(b,:));
                circlePixels = buildMask(RadiusSphere,coeff,coor,MASK_neutriphil);
%                     figure, imshow(circlePixels)  
            %         pause
                    % crop nuetrophils around
                    Neutrophils = MASK_neutriphil.*circlePixels;

            %       figure, imshow(Neutrophils)  
            %         pause
                Nbacter(b) = sum(Neutrophils(:));

            end
        else     
            coeff2 = param.coeff2(Shift);
            RadiusSphere2 = param.RadiusSphere2;
            for b = 1:size(coorB,1)
                % Get 3d distribution of nutrophils around
                coor = round(coorB(b,:));
                circlePixels1 = buildMask(RadiusSphere,coeff,coor,MASK_neutriphil);
                circlePixels2 = buildMask(RadiusSphere2,coeff2,coor,MASK_neutriphil);
                Ring = circlePixels1-circlePixels2;
                Ring = Ring>0;
                Neutrophils = MASK_neutriphil.*Ring;
%                 figure, imshow(Ring)  
%                     pause
%                     sl
%                     Shift
                Nbacter(b) = sum(Neutrophils(:));

            end
        end
        
        
end
        
function circlePixels = buildMask(RadiusSphere,coeff,coor, SliceNeut)

r = RadiusSphere.^2 - coeff.^2;
if r==0
   circlePixels = zeros(size(SliceNeut));
   circlePixels(coor(1),coor(2)) = 1;
else
    [columnsInImage rowsInImage] = meshgrid(1:size(SliceNeut,2), 1:size(SliceNeut,1));
    circlePixels = (rowsInImage - coor(2)).^2 ...
                    + (columnsInImage - coor(1)).^2 <= r;
end



function sl2 = RingShift(param,sl)


Lnum = []; 
Bnum = max(param.num);% number of slices supposed to be in a sphere
if length(param.num)>1
   [Lnum,indL] = min(param.num);
end

Lnum2 = []; 
Bnum2 = max(param.num2);% number of slices supposed to be in a sphere
if length(param.num2)>1
   [Lnum2,indL2] = min(param.num2);
end

if ~isempty(Lnum) && indL==1 % from start
     sl2 = sl - (Lnum-Lnum2);  
% elseif ~isempty(Lnum) && indL==1 && sl > param.cnt % from start
%      sl2 = sl - (Bnum-Bnum2);       
elseif ~isempty(Lnum) && indL==2    % end of the data
     sl2 = sl - (Bnum-Bnum2);  
% elseif ~isempty(Lnum) && indL==2 && sl > param.cnt   % end of the data
%      sl2 = sl - (Lnum-Lnum2);      
     
elseif isempty(Lnum) && isempty(Lnum2)
    sl2 = sl -(Bnum - Bnum2);
    
end




        