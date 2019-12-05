# BaSiC

This is a fork of the [BaSiC backgound correction pipeline](https://github.com/QSCD/BaSiC). To run the pipeline for 2 photon microscopy Tissue Vision data, you need to clone [this repository](https://github.com/Fouga/BaSiC) and [StitchIt](https://github.com/Fouga/StitchIt). 

# Example
```Matlab
source_dir = '/DATA_NAME/'; % here you need to have rawData directory with all your data and a Mosaic.txt

addpath(genpath('FULL_PATH/StitchIt/code/')); % add path to the StitchIt(https://github.com/BaselLaserMouse/StitchIt).

addpath(genpath('FULL_PATH/BaSiC/')); % add path to the BaSiC (https://github.com/Fouga/BaSiC) 

cd (source_dir);

% maKE INI FILE
if ~exist('stitchitConf.ini')
	makeLocalStitchItConf
end

% read info from Mosaic.txt 
M=readMetaData2Stitchit;

%check for and fix missing tiles if this was a TissueCyte acquisition
if strcmp(M.System.type,'TissueCyte')
    writeBlacktile = 0;
    missingTiles=identifyMissingTilesInDir('rawData',0,0,[],writeBlacktile);
else
    missingTiles = -1;
end

% correct background illumination with cidre
alternativeIlluminationCorrection('basic')


% stitch all the data
stitchAllChannels
```


**A BaSiC Tool for Background and Shading Correction of Optical Microscopy Images**

by Tingying Peng, Kurt Thorn, Timm Schroeder, Lichao Wang, Fabian J Theis, Carsten Marr\*, Nassir Navab\*, Nature Communication 8:14836 (2017). [doi: 10.1038/ncomms14836](http://www.nature.com/articles/ncomms14836).

BaSiC is licensed under 

[Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International Public License](https://creativecommons.org/licenses/by-nc-nd/4.0/legalcode)

It is free for academic use and please contact us for any commercial use.

## Demo

Download demo data examples from [Dropbox](https://www.dropbox.com/s/plznvzdjglrse3h/Demoexamples.zip?dl=0) and run matlab files under example folder.

## ImageJ/Fiji Plugin
BaSiC is also available as a ImageJ/Fiji Plugin. Plugin and installation instruction can be found in [BaSiC Software Website](https://www.helmholtz-muenchen.de/icb/research/groups/quantitative-single-cell-dynamics/software/basic/index.html).


Acknowledgements
============

- Rob Campbell for [Stichit](https://github.com/BaselLaserMouse/StitchIt) algorithm.
- Tingying Peng for [BaSiC](https://github.com/QSCD/BaSiC). 
- And Gus Brown for recurcive directory listing [rdir](https://uk.mathworks.com/matlabcentral/fileexchange/19550-recursive-directory-listing).




