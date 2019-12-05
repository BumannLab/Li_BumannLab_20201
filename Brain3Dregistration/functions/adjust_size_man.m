function vol_resh_siz = adjust_size_man(vol_resh,vol_atlas_crop)

[M N P] = size(vol_resh);
[Q R T] = size(vol_atlas_crop);

if P < T
    vol_resh = cat(3, vol_resh, zeros(M, N,T-P));
else
    vol_resh = vol_resh(:,:,1:T);
end
% rows
vol_resh_siz = vol_resh(M-Q+1:end,:,:);
for slice = 1:floor(T/10):T
    figure, imshow(imadjust(vol_resh_siz(:,:,slice)),[])
end
% colomns
vol_resh_siz = vol_resh_siz(:,1:R,:);
for slice = 1:floor(T/10):T
    figure, imshow(imadjust(vol_resh_siz(:,:,slice)),[])
end

for slice = 1:floor(T/10):T
    figure, subplot(1,2,1), imshow(vol_atlas_crop(:,:,slice),[])
        title(sprintf('Atlas slice %i',slice))
        subplot(1,2,2), imshow(imadjust(vol_resh_siz(:,:,slice)),[])
        title(sprintf('Sample slice %i',slice))

end

[M N P] = size(vol_resh_siz);
[Q R T] = size(vol_atlas_crop);
if M~=Q || N~=R || P~=T
    error('the size is not equal');
end