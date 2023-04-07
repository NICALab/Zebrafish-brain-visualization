<h3 align="center">Imaging whole-brain of larval zebrafish in vivo using three-dimensional fluorescence microscopy</h3>

<p align="center">
<img src="JoVE_Figure1.jpg" width="80%"/>
</p>


## Abstract

As a vertebrate model animal, larval zebrafish are widely used in neuroscience and provide a unique opportunity to monitor the whole-brain activity at cellular resolution. Here we provide an optimized protocol for performing whole-brain imaging of larval zebrafish using three-dimensional fluorescence microscopy that includes sample preparation and immobilization, sample embedding, image acquisition, and visualization after imaging. Our protocol enables in vivo imaging of the structure and neuronal activity of a larval zebrafish brain at cellular resolution over an hour using confocal microscopy and custom-designed fluorescence microscopy. We discuss the critical steps in the protocol, including sample mounting and positioning, preventing bubble formation and dust in the agarose gel, and avoiding motion in images caused by incomplete solidification of the agarose gel and paralyzation of the fish. The protocol has been validated and confirmed in multiple settings. This protocol can be easily adapted for imaging other organs of a larval zebrafish. 


This repository contains the source code we used for creating visualizations with Napari in Protocol Steps 5-7.


## Installation

The installation time may depend on your network speed, but it generally takes less than 20 minutes.

1. Clone the repository
```
git clone git@github.com:NICALab/Zebrafish-brain-visualization.git
```

2. Navigate into the cloned folder
```
cd ./Zebrafish-brain-visualization
```

3. Create the conda environment
```
conda env create -f env.yml
```

4. Activate the conda environment
```
conda activate Zebrafish-brain-visualization
```


## Getting Started
**1. Download demo data**

Demo data can be downloaded from [Google Drive Link](https://drive.google.com/drive/folders/1FsS3j9OhjLcKGmC3T7B8LkRuj2mXH8DW?usp=share_link)

**2. (Optional) Decompose background and activity from data using BEAR**

Run BEAR_v2_JoVE.m in the “BEAR_MATLAB_v2” folder.

**3. Run demo notebook**

Run `Visualizing_structure.ipynb` or `Visualizing_neuronal_activity.ipynb`.


## Data availability
Demo data can be downloaded from [Google Drive Link](https://drive.google.com/drive/folders/1FsS3j9OhjLcKGmC3T7B8LkRuj2mXH8DW?usp=share_link )

## Contributors
We are happy to help with any questions or requests. 
Please contact the following authors to get in touch!
* Seungjae Han (jay0118@kaist.ac.kr)
* Eun-Seo Cho (eunseo.cho@kaist.ac.kr)

## Citation
Cho, E.-S. et al. Imaging whole-brain of larval zebrafish in vivo using three-dimensional fluorescence microscopy. in revision (2023).
```
@article {Cho2023,
	author = {Cho, Eun-Seo and Han, Seungjae and Kim, Gyuri and Eom, Minho and Lee, Kang-Han and Kim, Cheol-Hee and Yoon, Young-Gyu},
	title = {Imaging whole-brain of larval zebrafish in vivo using three-dimensional fluorescence microscopy},
	elocation-id = {TBD},
	year = {2023},
	doi = {TBD},
	publisher = {TBD},
	URL = {TBD},
	eprint = {TBD},
	journal = {TBD}
}
```
