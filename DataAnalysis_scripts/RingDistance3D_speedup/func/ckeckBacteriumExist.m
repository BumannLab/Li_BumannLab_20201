function       BExt=  ckeckBacteriumExist(sl,NAMES)

BExt = 0;
% load images
% if frame < 10 
%   counter = strcat('00',int2str(frame)); 
% elseif frame < 100 
%   counter = strcat('0',int2str(frame));   
% else
%   counter = int2str(frame);   
% end
% name = strcat('section_', counter);
% txt_name = [segment_dir_bacter 'positions_', name, '_', int2str(optical),  '.txt'];   
txt_name = NAMES{sl};

% fileID = fopen(txt_name,'r');  
% A = fscanf(fileID,'%12s %12s %12s %6s %6s %12s %15s %15s %15s %15s %15s %15s %15s %15s',[1 14]);
% % fgets(fileID); 
% num_bact = fscanf(fileID,'%12.0f %12.0f %12.0f %6.0f %6.0f %12.3f %15.1f %15.4f %15.1f %15.1f %15.1f %15.1f %15.1f %15.1f',[14 Inf]);
% 
% fclose(fileID);

A = readtable(txt_name);
if ~isempty(A) 
    BExt = 1;
end
