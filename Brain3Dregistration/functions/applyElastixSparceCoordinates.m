function point_coor=applyElastixSparceCoordinates(coordinates_name,A)


% pointsInMovingSpace = A;%[rows, cols ,z]
pointsInMovingSpace = [A(:,2) A(:,1) A(:,3)];

% try
% 	REG=transformix(pointsInMovingSpace,inverted);
% 
% catch
% 	disp('Continue');
% end
load('./downsampled/sample2ARA/inverted.mat');
REG=transformix(pointsInMovingSpace,inverted);
point_coor = REG.OutputPoint;%[cols, rows ,z]
