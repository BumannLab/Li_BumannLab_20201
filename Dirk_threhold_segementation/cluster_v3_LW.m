fileID = fopen('./salmonella.txt','r');
fileID2 = fopen('cluster.txt','w');

formatSpec = '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f';  %'%10d %10d %10d %10.1f %10.1f %10.1f %10.1f %10.1f %10.1f %10d %10.1f %10.1f %10.1f %10.1f\n'
sizePOS = [16 inf];
[ POS, number] = fscanf( fileID, formatSpec, sizePOS);


XYZ = POS( 4:6, :)';
cherry = POS( 8, :)';
Compartment = POS( 16, :)';
number = number / 16;

fclose( fileID);

Dist = pdist(XYZ,'euclid'); 
Link = linkage(Dist,'single'); 
T = cluster(Link,'cutoff',200,'criterion','distance'); %%cut off?
clusterNumber = max( T);
Size = hist counts( T, clusterNumber);

for i = 1:number
    joined_cherry = cherry( i);
    for j = 1:number
        if i ~= j  &&  T( i) == T( j)
            joined_cherry = joined_cherry + cherry( j);
        end
    end
    
    fprintf(fileID2,'%10.1f %10.1f %10.1f %10d %10d  %10.1f  %10.1f %10.1f\n', XYZ(i,1), XYZ(i,2), XYZ(i,3), T(i), Size( T(i)), cherry( i), joined_cherry, Compartment (i));
end

fclose( fileID2);
