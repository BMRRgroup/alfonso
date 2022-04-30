![](./@ALFONSO/alfonso_logo.png)

# ALFONSO - A versatiLe Formulation fOr N-dimensional Signal model fitting of MR spectroscopy data 

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) [![codecov](https://codecov.io/gh/BMRRgroup/alfonso/branch/main/graph/badge.svg?token=9GZUOO0B1K)](https://codecov.io/gh/BMRRgroup/alfonso)

ALFONSO is a simple class for processing and quantification of single-voxel magnetic resonance spectroscopy (MRS) measurements. 

The focus of ALFONSO is on the convenient definition of multi-dimensional constrained signal models. Therefore, the measured signal is considered to be decompose-able into a time-domain signal function and a sequence specific modulation term. Prior knowledge and physics-inspired constraints can be introduced by using the flexible variable mapping functionality. Signal models can conveniently be defined and shared using JSON files. 
As an example its application to the quantification of tissue properties in lipid-rich body MRS is also included in this repository.
For further details please see the `Quickstart.mlx` (MATLAB live script) and the publications given in the reference section below. 

Please note: The implementation allows convenient rapid prototyping and direct manipulation of the data and properties. However, this way one has to be careful to not break any logic and also the execution of the code my potentially become insecure. 

## Getting Started

### Requirements

- MATLAB 2020b or newer is recommended (older released might still work, but were not thoroughly tested)

### Supported file formats

Currently the following file formats are supported for data import. 

- Philips .data / .list 
- Philips .raw / .lab (available upon qualifying request, requires MRecon ([Gyrotools](http://www.gyrotools.com/gt/index.php/products/reconframe))
- GE .7
- Your custom data format - the implementation of custom data readers is trivial and outlined in the `Quickstart.mlx`. 

### Installing

Simply clone the repository including all submodules: 

```
git clone https://github.com/BMRRgroup/alfonso.git
cd alfonso
git submodule update --init --recursive
```

Test and example data can also be download from an alternative source (in case github's LFS quote is exceed): 

```
curl -o gitlfs.zip https://syncandshare.lrz.de/dl/fiFCroP6zFrn64MKkiWXkDpD/20220430_tests.zip
unzip tests.zip
```
### Quick start example

The following quick example adds ALFONSO to the MATLAB path and performs simple data processing followed by an exemplary quantification.

```
% add ALFONSO to MATLAB path
addALFONSO2path();

mrs = ALFONSO( './tests/data/philips/data/al_19042022_1501389_12_1_wip_te_steamV4_raw_012.data' );

mrs.read_data;
mrs.data_info;
mrs.coilcombination;
mrs.averaging;
mrs.phase_correction;
mrs.set_ref_freq('autoset-waterfat',1.3) % use methylene peak as reference

% visualize processing result
mrs.plot_dynSeries;

% perform example quantification 
mrs.set_model('./examples/example_waterfat_TAG10_cT2.json')
mrs.fit_model;

% visualize fitting result
mrs.plot_fit_model;
```

Please see also interactive MATLAB livescript `Quickstart.mlx` and the example scripts under `./examples/`.

<!--
## How to run unit tests

Unit testing can be performed in MATALB with the following call from the project's root directory: 

```
run('./tests/runAllALFONSOTests.m')
```

## How to generate the documentation

The documentation can be generated in MATALB calling from the project's root directory: 

```
addALFONSO2path();
generate_documentation()
```
-->
## Versioning

The project uses the [SemVer](http://semver.org/) convention for versioning. 
For available versions see the [tags on this repository](https://github.com/bmrrgroup/alfonso/tags). 

## Third party dependencies

* [chebfun](http://www.chebfun.org/) (optional)
* [INI config](https://www.mathworks.com/matlabcentral/fileexchange/24992-ini-config)
* [JSONlab](https://github.com/fangq/jsonlab)
* [matlab2tikz](https://github.com/matlab2tikz/matlab2tikz) (optional)
<!--* [m2docgen](https://github.com/matlab2tikz/matlab2tikz) (optional) -->
* [matlab-helper](https://github.com/stfnr/matlab-helper)
* [mexNL2SOL](https://github.com/stfnr/mexNL2SOL) (optional, see also [original implementation by Joep Vanlier](https://github.com/JoepVanlier/mexNL2SOL)) 

## Acknowledgments

* Carl Ganter kindly provided his least_squares_varpro_gss_cg implementation.

## References

Please consider citing the following publication if used:
- *Ruschke, S, Karampinos, D.C.. ALFONSO: A versatiLe Formulation fOr N-dimensional Signal mOdel fitting of MR spectroscopy data and its application in MRS of body lipids. Proceedings of the 31st Joint Annual Meeting of the International Society for Magnetic Resonance in Medicine and the European Society for Magnetic Resonance in Medicine and Biology; 2022:2776*. 

An earlier version of this code was also used in the following publications: 

- *[Ruschke, S., Karampinos, D.C., Single‐voxel short‐TR multi‐TI multi‐TE STEAM MRS for water–fat relaxometry. Magnetic Resonance in Medicine epub. (2022)](https://doi.org/10.1002/mrm.29157)*
- *[Ruschke, S., Syväri, J., Dieckmeyer, M., Junker, D., Makowksi, M.R., Baum, T., Karampinos, D.C., Physiological variation of the vertebral bone marrow water T2 relaxation time. NMR in Biomedicine 34, e4439. (2020)](https://doi.org/10.1002/nbm.4439)* 

## Authors

* **Stefan Ruschke** - [Body Magnetic Resonance Research Group, TUM](http://bmrr.de)

## Funding

The present work was supported by the European Research Council (grant agreement No 677661, ProFatMRI and grant agreement No 875488, FatVirtualBiopsy). This work reflects only the authors view and the EU is not responsible for any use that may be made of the information it contains. 

## License

This project is licensed as given in the [LICENSE](LICENSE) file. 
However, used submodules / projects - which can be found under ./lib/ - may be licensed differently. Please see the respective licenses. 
