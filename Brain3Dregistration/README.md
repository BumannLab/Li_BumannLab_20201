# Brain3Dregistration
It alignes 3D sample data with the [Allen API documentation](http://help.brain-map.org/display/mouseconnectivity/API).

# Example
```Matlab

addpath(genpath('~/StitchIt/'));
addpath(genpath('/~Brain3Dregistration/'));


data_dir = '/media/natasha/0C81DABC57F3AF06/Data/brain/20171013_brain_MT_2wka/';

volumeRegistrationToxo(data_dir,180,0);
```
