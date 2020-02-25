
%% 1. Go to the folder you want to analsys; 2. Change the SampleAddress; Run


prefix = 'section_';
SampleAddress = '20170704_D5_M2_NoOxyAgar2';
ResultAddress = 'G:/Jiagui/01_ABX_project/20170704_distribusion_Timer/';
Resultfolder = '/SalmTextPic';
mkdir(strcat(ResultAddress,SampleAddress,Resultfolder));
%%mkdir('G:\Jiagui\01_ABX_project\20170403_distribusion_theshold\1/SalmTextPic');

for frame = 1:100
  if frame < 10 
      counter = strcat('00',int2str(frame)); 
  elseif frame < 100 
      counter = strcat('0',int2str(frame));   
  else
      counter = int2str(frame);   
  end
  name = strcat(prefix, counter)
   
 parfor optical = 1:5
    section = int2str(optical);
    z_pos = frame * 50 + optical * 10;
    
    fileID = fopen(strcat('G:\Jiagui\01_ABX_project\20170403_distribusion_theshold\',SampleAddress,'/SalmTextPic/positions',counter, '_0', section, '.txt'),'w');
    red = imread(strcat('./1/', name, '_0', section, '.tif'));
    info = imfinfo(strcat('./1/', name, '_0', section, '.tif'));
    green = imread(strcat('./2/', name, '_0', section, '.tif'));
    blue = imread(strcat('./3/', name, '_0', section, '.tif'));
    
    bright1 = red + green;
    bright2 = red + blue;
    buffer = red - red;
    buffer (bright1 > 10000 | bright2 > 10000) = 1;  %%??
    red_raw = red;
    
  
    red_blur = ordfilt2( red, 1, true(1));
    green_blur = ordfilt2( green, 1, true(1));
    blue_blur = ordfilt2( blue, 1, true(1));
  
    red = medfilt2(red);
    green = medfilt2(green);
    blue = medfilt2(blue);
    bright1 = red + green;
  
    redC = red;
    greenC = green;
    blueC = blue;
  
    salm = green;
    backgr = (red + green + blue);
    backgr2 = backgr;
  
    salm( greenC < 400 | blueC > greenC * 0.95 | blueC < greenC * 0.5 |red > 4000 )  = 0; %|redC > greenC * 3
    %%salm( greenC < 300 | blueC > greenC * 0.95 | blueC < greenC * 0.5 |red > 4000 |redC > greenC * 3)  = 0; %%This is for GFP filter with PE, without red threshold
    %%salm( greenC < 400 | blueC > greenC * 0.95 | blueC < greenC * 0.5 | redC > greenC *1 |red > 6000)  = 0; %%This is for GFP filter with PE
    %%salm( blueC > 4000 | redC > 4000 | greenC < 400 | blueC > greenC*0.4 | blueC < greenC * 0.18)  = 0; %%for IFNy-salm GFP
    %%salm( greenC < 500 | blueC > greenC * 0.6 | blueC < greenC * 0.1 |redC > 5000 | redC > greenC * 0.5)  = 0;  %% for brain gfp
    %%salm( redC < 300 | blueC > redC * 0.5 | greenC > 2000 | blueC >2000 | greenC > redC * 0.5)  = 0;  %% for brain mCherry
    %%salm( greenC > 3000 | blueC > greenC*0.1 |greenC < 60)  = 0; %%for IFNy-YFP
    %%salm( greenC < 500 | blueC > greenC * 0.6 | blueC < greenC * 0.15 |redC > 5000 | redC > greenC * 0.5)  = 0;  %% for brain gfp
    
    
    backgr( salm > 0 ) = 0;

    buffer = medfilt2(backgr2);
    small = imresize(buffer, [info.Height/10 info.Width/10]);
    h = fspecial('disk', 20);
    small_blur = imfilter(small, h);
    small_corr = small - small_blur / 10;
      
    BW = small_corr < 160;
    BW2 = BW - BW;
    CC = bwconncomp(BW);
    numPixels = cellfun(@numel,CC.PixelIdxList);
    for component=1:length(numPixels)
      if numPixels(component) < 10 || numPixels(component) > 100000  %%
        BW(CC.PixelIdxList{component}) = 0;
      end
      if numPixels(component)  > 100000
        BW2(CC.PixelIdxList{component}) = 1;
      end 
    end
      
    buffer = medfilt2(salm);
    
    bw = buffer > 10;
    cc = bwconncomp(bw);
    s = regionprops(cc,'all'); %output the parameter of images. 'MajorAxisLength' and 'MinorAxisLength'
    c = struct2cell(s);
    stats_greenC = regionprops( cc, greenC, 'MeanIntensity');  %% for mCherry need to change
    MeanIntens_greenC = [stats_greenC.MeanIntensity];
    stats_red = regionprops( cc, red, 'MeanIntensity');
    MeanIntens_red = [stats_red.MeanIntensity];
    stats_green = regionprops( cc, green, 'MeanIntensity');
    MeanIntens_green = [stats_green.MeanIntensity];
    stats_blue = regionprops( cc, blue, 'MeanIntensity');
    MeanIntens_blue = [stats_blue.MeanIntensity];
    stats_eccen = regionprops( cc, greenC, 'Eccentricity');
    Eccentricity = [stats_eccen.Eccentricity];
    stats_eccen = regionprops( cc, greenC, 'MajorAxisLength');
    MajorAxisLength = [stats_eccen.MajorAxisLength];
    stats_eccen = regionprops( cc, greenC, 'MinorAxisLength');
    MinorAxisLength = [stats_eccen.MinorAxisLength];
    
    buffer = salm - salm;
    small = imresize(buffer, 0.25);
    smaller = imresize(small, 0.2);
  
    salmonella( optical)= 0;
    for component=1:cc.NumObjects
      area = cell2mat(c(1,component));
      no = int2str(component);
      if area > 5
         pos = c(2,component);
         xy = cell2mat(pos(1));
         x = xy(1);
         y = xy(2);
         
         go = 1;   
         if x>800 && y>800 && x<(info.Width-800) && y<(info.Height-800)  %% crop bigger
           RC = imcrop(red,[x-800 y-800 1600 1600]);
           GC = imcrop(green,[x-800 y-800 1600 1600]);
           BC = imcrop(blue,[x-800 y-800 1600 1600]);
           PE = RC;  %% remove yellow dots
%            PE (GC > 0.04*RC | RC < 50) = 0; %% remove yellow dots
           PE( 1, 1) = 1800; GC( 1, 1) = 2600; BC( 1,1) = 2200;
           rgbImage = cat(3, PE,GC,BC);%% PE : remove yellow dots
           imwrite(rgbImage,strcat('G:\Jiagui\01_ABX_project\20170403_distribusion_theshold\',SampleAddress,'/SalmTextPic/',counter, '_', section, '-', no,'.tif'));
           
           for i = -10: 10
              for j = -10: 10
                 b1 = bright1(uint16(y+i),uint16(x+j));
                 r = red(uint16(y+i),uint16(x+j));
                 g = green(uint16(y+i),uint16(x+j));
                 if g > 13000 ||  r > 8000  %%To decide whether to write into the txt file. if with filter, g should > 8000
                    go = 0;
                 end
              end
           end
           
         elseif x>200 && y>200 && x<(info.Width-200) && y<(info.Height-200)  %% crop bigger
           RC = imcrop(red,[x-200 y-200 400 400]);
           GC = imcrop(green,[x-200 y-200 400 400]);
           BC = imcrop(blue,[x-200 y-200 400 400]);
           PE = RC;  %% remove yellow dots
%            PE (GC > 0.05*RC) = 0; %% remove yellow dots
           PE( 1, 1) = 1800; GC( 1, 1) = 2600; BC( 1,1) = 2200;
           rgbImage = cat(3, PE,GC,BC);
           imwrite(rgbImage,strcat('G:\Jiagui\01_ABX_project\20170403_distribusion_theshold\',SampleAddress,'/SalmTextPic/',counter, '_', section, '-', no,'.tif'));
         
           for i = -10: 10
              for j = -10: 10
                 b1 = bright1(uint16(y+i),uint16(x+j));
                 r = red(uint16(y+i),uint16(x+j));
                 g = green(uint16(y+i),uint16(x+j));
                 if g > 13000 ||  r > 8000  %%To decide whether to write into the txt file.  if with filter, g should > 8000
                    go = 0;
                 end
              end
           end
         
         else
           go = 0;
         end
         
         fprintf( '%10d %10d %10d\n', optical, component, go);
         if go>0
             x_pos = x * 0.435;
             y_pos = y * 0.435;
             fprintf(fileID,'%10d %10d %10d %10.1f %10.1f %10.1f %4d %10.1f %10.1f %10.1f %10.1f %10.2f %10.1f %10.1f\n', frame, optical, component, x_pos, y_pos, z_pos, area, MeanIntens_green( component), MeanIntens_red( component), MeanIntens_green( component), MeanIntens_blue( component), MajorAxisLength( component) ,MinorAxisLength( component), Eccentricity( component));
             
             salmonella( optical) = salmonella( optical) + 1;
         end
      end
    end
       
  fclose(fileID);
 end

 end

clear;

