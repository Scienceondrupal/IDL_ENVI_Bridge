    IDL/ENVI Bridge Copyright (C) 2014  New Media Studio, Inc.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.


This IDL/ENVI Bridge module works in conjunction with an Exelis ENVI Service Engine, and an IDL function, to generate highly customizable maps of generic data set. The goal of this project is to demonstrate how a Drupal module can work with an ESE installation to reduce the need of the Drupal developer from having to write IDL code to display various data sets on their site. This module allows the design of the map through the configuration page of the module with many options provided for the Image, MapContinents, ColorBar and MapGrid functions of IDL object graphics. This module requires an ESE installation with IDL 8.3 or higher. This module has been tested on an Ubuntu installation on the Amazon Web Services cloud.

This system is intended to allow variety of time series data sets to be placed in the specified "data directory" with a standardized file naming format, making those files immediately available to the Drupal module for display. The GeoTIFF data file format is the one that has been tested. With this format, the geospatial information is embedded and the IDL objects utilize this to greatly simplifying the setup process. The ESE module requires that the name of the dataset (i.e. Tropospheric_NO2) be used for the folder name containing the data sets in the data directory. The file naming format is dataset_name.yyyy.mm.tif, where yyyy is the year and mm is the two digit month. This model can be changed but will require modification of the IDL code. 

Once the data is in place and the module installed, the administrator can customize the presentation map through the configuration page of the module. A wide range of options are available for the user to manipulate. The user can set the size of the display, the range of values to display, select a color table, draw continental and country boundaries, draw latitude and longitude grids and generate a color bar among others. However, this is just a select set of display parameters have been chosen for this project and others may be selected if IDL code is modified.


Included in this package:

ese.module, The Drupal module that defines the configuration page options and dataset browser page.

ese.install, The Drupal install and uninstall functionality.

ese.info, The Drupal information definition description.

ese_display_data.pro, The IDL code that provides the service to be called from the module.

config.json, The JSON definition of the parameters of the ese_display_data service task.


Installation:

The three Drupal files are placed in the Drupal sites custom module folder.

Modify the there Site Configuration paths in the ese_diplay_data.pro file.

The IDL and JSON files are compressed with zip and submitted to the ESE through the administration interface.


FAQ:
Do I need an Exelis ENVI Service Engine license?
Yes you do. You can contact Thomas Harris at Thomas.Harris@exelisinc.com.





