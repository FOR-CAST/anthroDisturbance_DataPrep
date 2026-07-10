anthroDisturbance_DataPrep Manual
================
Last updated: 2026-07-10

- [anthroDisturbance_DataPrep
  Module](#anthrodisturbance_dataprep-module)
  - [Authors:](#authors)
  - [Module Overview](#module-overview)
    - [Module summary](#module-summary)
    - [Module inputs and parameters](#module-inputs-and-parameters)
    - [Events](#events)
    - [Plotting](#plotting)
    - [Saving](#saving)
    - [Module outputs](#module-outputs)
    - [Links to other modules](#links-to-other-modules)
    - [Getting help](#getting-help)

# anthroDisturbance_DataPrep Module

[![made-with-Markdown](figures/markdownBadge.png)](https://commonmark.org)

#### Authors:

Tati Micheletti <tati.micheletti@gmail.com> \[aut, cre\]

## Module Overview

### Module summary

This is a data-preparation module that harmonizes different
anthropogenic disturbance datasets into the list-of-lists structure
needed to generate disturbance layers downstream. All the module needs
is the metadata supplied in the `disturbanceDT` object (a `data.table`);
from it, the module downloads, loads, reprojects, crops, and harmonizes
each dataset, returning the `disturbanceList` object.

The module was originally developed for the Northwest Territories (its
built-in default sample data is the union of BCR6 and NT1), but the
structure is general. This is the FOR-CAST fork used in the Yukon
Northern Mountain Caribou project, where the pipeline supplies Yukon
inputs.

### Module inputs and parameters

The primary input is the `disturbanceDT` `data.table`, whose columns
describe where each dataset comes from and how to process it:

- `dataName`: groups the data by sector (e.g., Energy, Settlements,
  OilGas, Mining, Forestry, Roads);
- `URL`: download link for the specific dataset;
- `classToSearch`: exact polygon type/class to search for when picking
  from a dataset with multiple types. Even if a shapefile already holds
  only the needed data, specify a unique value here so each entry has a
  distinct name;
- `fieldToSearch`: the field in which `classToSearch` is found; if
  given, the spatial object is subset to `classToSearch`. Provide only
  if needed;
- `dataClass`: further details the data type (e.g., Settlements,
  potentialSettlements, otherPolygons, otherLines, windTurbines,
  potentialWindTurbines, hydroStations, oilFacilities, pipelines). A
  common class used to harmonize different datasets. Potential data
  classes (always prefixed `potential`) fall into three general types,
  later consumed by `anthroDisturbance_Generator`:
  1.  Enlarging (e.g., potentialSettlements, potentialSeismicLines): the
      potential layer equals the current layer and is only buffered over
      time;
  2.  Generating (e.g., potentialWind, potentialOilGas,
      potentialMineral, potentialCutblocks): the potential layer marks
      where structures may appear based on a rate;
  3.  Connecting (e.g., potentialPipelines, potentialTransmission,
      potentialRoads): the potential layer needs the current
      transmission, pipeline, and road network; depends on what
      Generating produces;
- `fileName`: if the source is a `.zip` holding one or more shapefiles,
  which shapefile to use;
- `dataType`: layer format – one of `shapefile` (`.shp`/`.gdb`),
  `raster` (`.tif`, converted to shapefile), or `mif` (read as a
  shapefile).

The other two inputs are the study area (`studyArea`) and a raster
(`rasterToMatch`) that defines the projection and spatial resolution.

The full list of module inputs:

| objectName | objectClass | desc | sourceURL |
|:---|:---|:---|:---|
| disturbanceDT | data.table | This data.table needs to contain the following columns: dataName –\> this column groups the type of data by sector (i.e., Energy, Settlements, OilGas, Mining, Forestry, Roads)URL –\> URL link for the specific datasetclassToSearch –\> exact polygon type/class to search for when picking from a dataset with multiple types. If this is not used (i.e., your shapefile is alreday all the data needed), you should still specify this so each entry has a different namefieldToSearch –\> where should classToSearch be found? If this is specified, then the function will subset the spatial object (most likely a shapefile) to classToSearch. Only provide this if this is necessary!dataClass –\> this column details the type of data further (i.e., Settlements, potentialSettlements otherPolygons, otherLines, windTurbines, potentialWindTurbines, hydroStations, oilFacilities, pipelines, etc). Common class to rename the dataset to, so we can harmonize different ones. Potential data classes can be of three general types (that will be specified in the disturbanceGenerator module as a parameter – ALWAYS with ‘potential’ starting): 1. Enlarging (i.e., potentialSettlements and potentialSeismicLines): where the potential one is exactly the same as the current layer, and we only buffer it with time2. Generating (i.e., potentialWind, potentialOilGaspotentialMineral, potentialForestry): where the potential layers are only the potential where structures can appear based on a specific rate3. Connecting (i.e., potentialPipelines, potentialTransmission, potentialRoads incl. forestry ones): where the potential layer needs to have the current/latest transmission, pipeline, and road network. This process will depend on what is generated in point 2.fileName –\> If the original file is a .zip and the features are stored in one of more shapefiles inside the .zip, please provide which shapefile to be useddataType –\> please provide the data type of the layer to be used. These are the current accepted formats: ‘shapefile’ (.shp or .gdb), ‘raster’ (.tif, which will be converted into shapefile), and ‘mif’ (which will be read as a shapefile).It defaults to an example in the Northwest Territories and needs to be provided if the study area is not in this region (i.e., union of BCR6 and NT1) | <https://raw.githubusercontent.com/tati-micheletti/anthroDisturbance_DataPrep/refs/heads/main/data/disturbanceDT.csv> |
| studyArea | SpatVector | Study area to which the module should be constrained to. Defaults to NT1+BCR6. Object can be of class ‘vect’ from terra package | <https://zenodo.org/records/20434361/files/NT1_BCR6.zip> |
| rasterToMatch | SpatRaster | All spatial outputs will be reprojected and resampled to it. Defaults to NT1+BCR6. Object can be of class ‘rast’ from terra package | <https://zenodo.org/records/20434240/files/RTM_BCR6_NT1.tif> |

Summary of user-visible parameters:

| paramName | paramClass | default | min | max | paramDesc |
|:---|:---|:---|:---|:---|:---|
| .plots | character | screen | NA | NA | Used by Plots function, which can be optionally used here |
| .plotInitialTime | numeric | 0 | NA | NA | Describes the simulation time at which the first plot event should occur. |
| .plotInterval | numeric | NA | NA | NA | Describes the simulation time interval between plot events. |
| .saveInitialTime | numeric | NA | NA | NA | Describes the simulation time at which the first save event should occur. |
| .saveInterval | numeric | NA | NA | NA | This describes the simulation time interval between save events. |
| .seed | list |  | NA | NA | Named list of seeds to use for each event (names). |
| .useCache | logical | FALSE | NA | NA | Should caching of events or module be used? |
| studyAreaName | character | NT1 | NA | NA | Name to be used to save interin disturbance layers, related to location |
| checkDisturbanceProportions | logical | FALSE | NA | NA | Should the disturbances from the original data be pre-buffered to calculate area? Mainly designed for debugging and information on original data. |
| whatNotToCombine | character | potential | NA | NA | Here the user should specify which dataClass from the object disturbances should NOT be combined.This is especially important for potential resource layers that need idiosyncratic processes to be generated, which might happen on a separate module (i.e., potentialResourcesYT_DataPrep). This parameter is used as a pattern string to identify which dataClass contains the pattern and excludes these from the harmonization of the datasets. |
| useSavedList | logical | TRUE | NA | NA | If the disturbances object was saved and the parameteris TRUE, it returns the list. Saves time but attention is needed to make sure the objects are correct! |

### Events

The module runs two events:

1.  `init`: validates and coerces the inputs – `studyArea` to a terra
    `SpatVector`, `rasterToMatch` to a `SpatRaster`, and `disturbanceDT`
    to a `data.table` – reprojecting `studyArea` to match
    `rasterToMatch` when needed;
2.  `loadAndHarmonizeDisturbanceDT`: builds the disturbance data.
    `createDisturbanceList()` loops over `dataName`, `dataClass`, and
    `classToSearch` to download each dataset, load it, reproject
    non-matching layers to the `rasterToMatch` projection, crop to the
    study area, and merge layers sharing a common `dataClass`.
    `harmonizeList()` then unifies sub-sectors that can be simulated
    together into the final `disturbanceList`.

### Plotting

This module does not schedule any plot events.

### Saving

This module does not schedule any save events. When
`useSavedList = TRUE`, a previously-saved `disturbances` list is reused
instead of being rebuilt, which saves time – but confirm the saved
objects are the expected ones.

### Module outputs

| objectName | objectClass | desc |
|:---|:---|:---|
| disturbances | list | List (general category) of lists (specific class) needed for generating disturbances. This last list contains: Outter list names: dataName from disturbanceDTInner list names: dataClass from disturbanceDT, which might not be an unique class |
| disturbanceList | list | List (general category) of lists (specific class) needed for generating disturbances. This last list contains: Outter list names: dataName from disturbanceDTInner list names: dataClass from disturbanceDT, which is a unique class after harmozining, except for any potential resources that need idiosyncratic processing. This means that each combination of dataName and dataClass (except for ‘potential’) will only have only one element. Another modulecan deal with the potential layers. For the current defaults, this is the potentialResourcesYT_DataPrepIf none of the potential layers needs to be modified or combines, you might skip this idiosyncratic module and directly use the anthroDisturbance_Generator module. |

Both outputs are lists (general sector category) of lists (specific
class / sub-sector). In `disturbances` the inner `dataClass` may not be
unique; in `disturbanceList` each `dataName` x `dataClass` combination
is unique after harmonization, except for `potential` resources that
need idiosyncratic processing. Those are handled by a downstream module
– for the current defaults, `potentialResourcesYT_DataPrep`. If no
potential layer needs modification or combination, that module can be
skipped and `disturbanceList` passed directly to
`anthroDisturbance_Generator`.

### Links to other modules

Part of the anthropogenic-disturbance module collection, run in sequence
with `potentialResourcesYT_DataPrep` (idiosyncratic potential-resource
processing) and `anthroDisturbance_Generator` (forward generation of new
disturbances). The collection can be combined with landscape-simulation
modules (e.g., `Biomass_core`) and fire (e.g., `scfm`) and caribou
modules to improve realism in forecasts.

### Getting help

- <https://github.com/FOR-CAST/anthroDisturbance_DataPrep/issues>
