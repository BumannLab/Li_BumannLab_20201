function vol_resh_crop = crop_bottom_up(vol_resh,vol_atlas_crop)

% % load atlas data
% templateFile = getARAfnames;
% headerInfo_at=mhd_read_header(templateFile); 
% vol_atlas = mhd_read(headerInfo_at);

% check if the size is the same
if size(vol_atlas_crop)~=size(vol_resh)
    error('Volume size should the equal')
end

vol_resh_crop = uint16(zeros(size(vol_resh)));
[X Y Z] = size(vol_atlas_crop);
cont =1;
while cont==1
    vol_resh_crop = uint16(zeros(size(vol_resh)));
    prompt = 'For how many slices you want to shift down? ';
    slice_cut = input(prompt);
    
    vol_resh_crop(:,:,1:Z-slice_cut+1) = vol_resh(:,:,slice_cut:Z);

    for slice = 1:floor(Z/10):Z
        figure, subplot(1,2,1), imshow(vol_atlas_crop(:,:,slice),[])
            title(sprintf('Atlas_slice_%i',slice))
            subplot(1,2,2), imshow(imadjust(vol_resh(:,:,slice)),[])
            title(sprintf('Sample_slice_%i',slice))

    end
    
    % Construct a questdlg with three options
    questTitle='Image Contrast'; 
    start(timer('StartDelay',1,'TimerFcn',@(o,e)set(findall(0,'Tag',questTitle),'WindowStyle','normal')));
    choice = questdlg('Are you happy with the shift?', questTitle, 'Yes','No','Yes');
    switch choice
        case 'Yes'
            cont = 0;
        case 'No'
            cont = 1;
    end
end