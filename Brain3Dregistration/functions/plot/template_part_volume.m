%save images of specific area 
addpath(genpath('/home/natasha/Programming/Matlab_wd/Projects_Biozentrum/Registration/'));
templateFile = getARAfnames;
templateFile_annotated = [templateFile(1:end-12) 'atlas_smooth1_corrected.mhd'];
headerInfo=mhd_read_header(templateFile_annotated); 
vol_atlas_annotated = mhd_read(headerInfo);
List = getAllenStructureList;
for i = 1:size(vol,3)
   
    im = vol_atlas_annotated(:,:,i);
    im2 = zeros(size(im));
    im2(im==795)=1000;
%     vol(:,:,i) = im2;
    name = sprintf('pag_slice_%i.tiff',i)
    imwrite(uint16(im2),['pag_volume/' name]);
    if ~isempty(find(im==795))
        figure, imshow(im2,[])
    end
end% 795 - > 907 PAG

for i = 1:size(vol,3)
   
    im = vol_atlas_annotated(:,:,i);
%     im2 = zeros(size(im));
%     im2(im==907)=1000;
%     vol(:,:,i) = im2;
    name = sprintf('atlas_slice_%i.tiff',i)
    imwrite(uint16(im),['atlas/' name]);
%     if ~isempty(find(im==907))
%         figure, imshow(vol(:,:,i),[])
%     end
end
% liast.id
for i = 1:size(vol_atlas_annotated,3)
   
    im = vol_atlas_annotated(:,:,i);
    im2 = zeros(size(im));
    im2(im==672)=1000;
%     vol(:,:,i) = im2;
    name = sprintf('pag_slice_%i.tiff',i)
    imwrite(uint16(im2),['pag_volume_automat/' name]);
    if ~isempty(find(im==672))%% || ~isempty(find(im==240))
        figure, imshow(imadjust(im2),[])
    end
end% 672-> 1017 Caudoputamen
