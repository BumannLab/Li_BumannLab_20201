function coeff = SphereParameters(RadiusSphere,num,slices)


 % slices = actual number of slices

% number of additional slices for making elipse
Lnum = []; 
Bnum = max(num);% number of slices supposed to be in a sphere
if length(num)>1
   [Lnum,indL] = min(num);
end

    % build masks according to the changing radius
    if ~isempty(Lnum) && indL==1 
        coeff =abs(linspace(-RadiusSphere,RadiusSphere,2*Bnum+1));
        coeff(1:(2*Bnum+1-slices)) = [];
    elseif ~isempty(Lnum) && indL==2
        coeff =abs(linspace(-RadiusSphere,RadiusSphere,2*Bnum+1));
        coeff = coeff(1:slices);
    else        
        coeff =abs(linspace(-RadiusSphere,RadiusSphere,2*Bnum+1));
    end
    
  
    
    
% end