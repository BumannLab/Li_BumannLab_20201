function vol_atlas_crop = cut_half_volume(col,vol_resh)


%%%%%%%%%%%%%%%%%%%%%%%%% adjust template to the new volume, cut half of it
% load the template
templateFile = getARAfnames;
templateFile_original = [templateFile(1:end-12) 'original_data' templateFile(end-12:end)];
headerInfo_at=mhd_read_header(templateFile_original); 
vol_atlas = mhd_read(headerInfo_at);
% figure, imshow(vol_atlas(:,:,70),[])

% [row col Z] = size(vol_resh);

% make a crop of a 2D image
vol_atlas_crop = uint16(zeros(headerInfo_at.Dimensions(2),col,headerInfo_at.Dimensions(3)));
for i = 1: headerInfo_at.Dimensions(3)
    im = vol_atlas(:,:,i);
    im_crop = imcrop(im,[1 1 col-1 headerInfo_at.Dimensions(1)]);
    vol_atlas_crop (:,:,i) = uint16(im_crop);
    
    if mod(i,100)==0
       figure, subplot(1,2,1), imshow(vol_atlas_crop(:,:,i),[])
            title(sprintf('Atlas slice %i',i))
            subplot(1,2,2), imshow(imadjust(vol_resh(:,:,i)),[])
            title(sprintf('Sample slice %i',i))
    end
    
end

mhd_write(vol_atlas_crop, [templateFile(1:end-4) '.raw'],[1,1,1])