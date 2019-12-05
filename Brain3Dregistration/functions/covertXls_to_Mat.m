% trun xls table to mat file

read_dir = '/media/natasha/0C81DABC57F3AF06/Data/Splin_data/20170123_brainshort2/';
tabl = xlsread([read_dir 'salmonella.xls']);
A = tabl(:, [1:2,9]);
A(:,1:2) = A(:,1:2)./0.435;
save([read_dir 'toxo_coordinate.mat'],'A');
% A1 = col A2 = row
%% show images

image_read_dir = '/media/natasha/0C81DABC57F3AF06/Data/Splin_data/20170123_brainshort2/stitchedImages_100/1/';
I = imread([image_read_dir sprintf('section_002_01.tif')]);
figure, imshow(I,[])
hold on
plot(A(1,1),A(1,2),'g*')
hold off
imcontrast

%% show on downsampled images

filename = './downsampled/dstest_25_25_02.mhd';
headerInfo=mhd_read_header(filename); 
vol_data = mhd_read(headerInfo);
vol_data(vol_data>500)=0;
figure,vol3d('CData',vol_data)

hold on
plot(resampleCoor(1,1),resampleCoor(1,2),'g*')
hold off

imZ = vol_data(:,:,round(resampleCoor(1,3)));
figure, imshow(imadjust(imZ),[])
hold on
plot(resampleCoor(1,1),resampleCoor(1,2),'g*')
hold off