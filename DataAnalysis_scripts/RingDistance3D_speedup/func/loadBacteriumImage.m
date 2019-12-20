function coorB = loadBacteriumImage(segment_dir_bacter,INDE,slice)


frame = INDE(1,INDE(3,:)==slice);
optical = INDE(2,INDE(3,:)==slice);
% load images
if frame < 10 
  counter = strcat('00',int2str(frame)); 
elseif frame < 100 
  counter = strcat('0',int2str(frame));   
else
  counter = int2str(frame);   
end
name = strcat('section_', counter);

mask_name = [segment_dir_bacter, name, '_', int2str(optical) ,'.pbm'];
MASK_bacter = imread(mask_name);

cc = bwconncomp(MASK_bacter,8);
s = regionprops(cc,'basic');

coorB = cat(1,s.Centroid);
end