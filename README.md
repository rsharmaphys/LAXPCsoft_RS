# LAXPCsoft_RS

LAXPCsoft_RS is a lightweight analysis package for **AstroSat/LAXPC** data.  
It provides scripts to extract **LAXPC spectra**, **energy-resolved light curves**, and to apply **barycentric correction** to light curves.

The package is intended for users familiar with AstroSat data analysis and HEASOFT-based workflows.

---

## Features

- Extraction of LAXPC spectra  
- Generation of energy-resolved light curves  
- Barycentric correction of light curves  
- Supports LAXPC10 and LAXPC20  

---

## Requirements

- Linux / Unix-based system  
- **HEASOFT** (must be initialized before installation and usage)  
- Standard AstroSat/LAXPC Level-2 data products  

---

## Download

Clone the repository:

```bash
git clone https://github.com/rsharmaphys/LAXPCsoft_RS.git
cd LAXPCsoft_RS
```
Response Matrix Files (RMFs) for LAXPC10 and LAXPC20 must be downloaded separately.

Official LAXPC software page: https://www.tifr.res.in/~astrosat_laxpc/LaxpcSoft.html

Direct download links:
LAXPC10: https://www.tifr.res.in/~astrosat_laxpc/LaxpcSoft_v1.0/lx10resp.tar.gz
LAXPC20: https://www.tifr.res.in/~astrosat_laxpc/LaxpcSoft_v1.0/lx20resp.tar.gz

After downloading, place the *.tar.gz RMF files either in the LAXPCsoft_RS directory, or in the directory containing the downloaded LAXPC packages

Example Directory Structure

    LAXPCsoft_RS/
        ├── install-lxp.sh
        ├── laxpc_prod.sh
        ├── lx10resp.tar.gz
        ├── lx20resp.tar.gz
        ├── *.tar.gz

## Installation

Before installation, please make sure that HEASOFT is correctly initialized in your shell environment.

Then run:
```bash
bash install-lxp.sh
```

## Usage

To extract spectra and energy-resolved light curves, execute:
```bash
bash laxpc_prod.sh
```
Before running the script, make sure the following parameters are correctly set inside laxpc_prod.sh:

    obsid : Observation ID (the last 4-5 digit, e.g., for obs-ID = 9000005318 give obsid=5318)

    indir : Input directory containing LAXPC data (full path upto level 1 data)
    ├── data/
    │   └── <obsid>/

    outdir : Output directory (full path)

    ra : Right Ascension of the source (in decimal degrees)

    dec : Declination of the source (in decimal degrees)

The script produces background-subtracted products and applies barycentric correction where required.


**Notes**

    This package is provided for scientific and academic use.
    No warranty is implied. Users should verify the extracted products before scientific analysis.

