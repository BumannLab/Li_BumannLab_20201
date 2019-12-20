function ObjectIntenDistribution(read_dir)

A = readtable(fullfile(read_dir,'Allpositions_filter3D.txt'));
Intensities = log(A.SumGreen);
figure, subplot(2,2,1), hist(Intensities,500)
title('Histogram of total object green intens')
xlabel('Log of Green Intensity')
ylabel('Number of objects')

Intensities = log(A.SumBlue);
subplot(2,2,2), hist(Intensities,500)
title('Histogram of total object blue intens')
xlabel('Log of Blue Intensity')
ylabel('Number of objects')

ratioOb = log(A.SumGreen./A.area);
subplot(2,2,3), hist(ratioOb,500)
title('Normalized Green by area')
xlabel('Log TotalGr/area')
ylabel('Number of objects')

ratioOb = log(A.SumBlue./A.area);
subplot(2,2,4), hist(ratioOb,500)
title('Normalized Blue by area')
xlabel('Log TotalBl/area')
ylabel('Number of objects')