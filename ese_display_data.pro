;+
; :Description:
;    Display GeoTIFF a variety of data sets as an ENVI Service Engine (ESE) task with input from the 
;    Drupal ESE module. 
;    
;    The ESE_DISPLAY_DATA proceedure uses IDL new object graphics to generate 
;    maps of a time series of multiple data sets. The objects used are: image(), mapcontinents(), colorbar()
;    and mapgrid(). A select set of parameters for each of these objects are
;    set in the Drupal module configuration interface and the values are passed
;    to the ESE and on to this task. Other users may wish to select different
;    keywords to pass in to generate custom maps. This project was designed as
;    a demonstration of the use of the ESE via a Drupal module.
;
; :Information:
;    This .pro file, along with its config.json file, defines an ESE task.
;    The config.json contains metadata about the task and its parameters, while
;    this .pro file contains the actual implementation of the task algorithm.
;    
;    The data sets are placed in the data_dir, defined below, and are placed in
;    a folder with the same name as d_set. The format of the file names is:
;    [d_set].YYYY.MM.ext
;    where:
;      d_set is the name of the data set
;      YYYY is the year
;      MM is the month
;      ext is the file format extension. Only GeoTIFFs have been tested.
;      
;    This code is intended for use with IDL 8.3 or higher. This was the first version where the
;    "data" argument of the image function could accept a file name and read the
;    data and geospatial information and set up the mapping properties. This
;    feature greatly simplifies the configuration of a map for the Drupal user.
;    As stated above, only GeoTIFFs have been tested but other file formats that contain
;    geospatial information may work as well. Other users will have to test this.
;    
;  :Site specific parameters:
;    data_dir:    path to the data directory
;    url_path:    URL path to the ESE jobs directory
;    drupal_dir:  local path to the ESE jobs directory
;
; :Keywords:
;    d_set:     data set to display, name corresponds to data_dir/d_set
;    d_yr:      data year
;    d_mo:      data month
;    img_url:   resulting image URL
;    i_wdim:    image: dimensions width and height of window
;    i_minv:    image: min_value
;    i_maxv:    image: max_value
;    i_marg:    image: margin all sides, scaler, or four-element vector  
;    i_rgb:     image: rgb_table number
;    i_x_rng:   image: x range: min, max
;    i_y_rng:   image: y range: min, max
;    mc_cont:   mapcontinent: map continents color,linestyle,thick
;    mc_cntr:   mapcontinent: map countries color,linestyle,thick
;    mc_lak:    mapcontinent: map lakes color,linestyle,thick
;    mc_riv:    mapcontinent: map rivers color,linestyle,thick
;    mc_usa:    mapcontinent: map usa color,linestyle,thick
;    mc_can:    mapcontinent: map canada color,linestyle,thick
;    cb:        colorbar: position, title
;    mg:        mapgrid: color, label_color, thick, latlon_spacing, linestyle, label_align
;
; :History:
;   2014/06/24: Created by Martin Landsfeld, The New Media Studio
;   
; :Todo:
;   Use !SERVICE system variable instead of Site configuration parameters
;     http://www.exelisvis.com/docs/System_Variables.html
; 
;-

; IDL/ENVI Bridge Copyright (C) 2014  New Media Studio, Inc.
;
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <http://www.gnu.org/licenses/>.


PRO ESE_DISPLAY_DATA,  d_set, d_yr, d_mo, img_url, $
                       i_wdim, i_minv, i_maxv, i_marg , i_rgb, i_x_rng, i_y_rng, $
                       mc_cont, mc_cntr, mc_lak, mc_riv, mc_usa, mc_can, $
                       cb, mg
  
  ; Site Configuration parameters =================================
  
  data_dir = '/home/ubuntu/exelis/se10/docroot/data/'
  url_path = 'http://ec2-54-191-114-149.us-west-2.compute.amazonaws.com:8181/jobs/'
  drupal_dir = '/home/ubuntu/exelis/se10/docroot/jobs/' 
  
  ; ==================================================================
  
  
  ; test for data file 
  if fix(d_mo) lt 10 then d_mo = '0' + d_mo
  
  cmd = "data_file = string(data_dir, d_set, path_sep(), d_set, '.', d_yr, '.', d_mo, '.tif', f='(11a)')"
  print, cmd
  res = execute(cmd)

  if ~ file_test(data_file) then message, 'ERROR: data file does not exist: ' + data_file
  print, 'found file: '+ data_file
 

  ; Image command build =================================
  
  title = string(d_set, ': ', d_yr, '/', d_mo, f='(5a)')
    
  cmd = 'img=image(data_file, /buffer, title=title'
  
  if keyword_set(i_wdim) then begin
    cmd += string(',dimensions=[', i_wdim, ']', f='(5a)')
  endif
  
  if keyword_set(i_minv) then begin
    cmd += string(',min_value=', i_minv, f='(2a)')
  endif

  if keyword_set(i_maxv) then begin
    cmd += string(',max_value=', i_maxv, f='(2a)')
  endif
  
  if keyword_set(i_marg) then begin
    cmd += string(',margin=[', i_marg, ']', f='(3a)')
  endif

  if keyword_set(i_rgb) then begin
    cmd += string(',rgb_table=', i_rgb, f='(a, i0)')
    ;cmd += string(',rgb_table=49')
  endif

  if keyword_set(i_x_rng) then begin
    cmd += string(',xrange=[', i_x_rng, ']', f='(5a)')
  endif

  if keyword_set(i_y_rng) then begin
    cmd += string(',yrange=[', i_y_rng, ']', f='(5a)')
  endif

  ; wrap up command
  cmd +=  ')'
  print, cmd
  res = execute(cmd)


  ; hide the grid
  cmd = "mapgrid = map.mapgrid"
  print, cmd
  res = execute(cmd)
  cmd = "mapgrid.hide = 1"
  print, cmd  
  res = execute(cmd)
  
  ; MapContinents commands build =================================
  
  if keyword_set(mc_cont) then begin 
    token = strsplit(mc_cont, ',', /extract, count=n_toks)
    cmd = 'mc = mapcontinents(/continents'
    if token[0] ne '' then cmd += string(", color='", token[0], "'", f='(3a)')
    if token[1] ne '' then cmd += string(", linestyle=", token[1], f='(2a)')
    if token[2] ne '' then cmd += string(", thick=", token[2], f='(2a)')
    cmd += ')'
    print, cmd
    res = execute(cmd)
  endif

  if keyword_set(mc_cntr) then begin
    token = strsplit(mc_cntr, ',', /extract, count=n_toks)
    cmd = 'mc = mapcontinents(/countries'
    if token[0] ne '' then cmd += string(", color='", token[0], "'", f='(3a)')
    if token[1] ne '' then cmd += string(", linestyle=", token[1], f='(2a)')
    if token[2] ne '' then cmd += string(", thick=", token[2], f='(2a)')
    cmd += ')'
    print, cmd
    res = execute(cmd)
  endif

  if keyword_set(mc_riv) then begin
    token = strsplit(mc_riv, ',', /extract, count=n_toks)
    cmd = 'mc = mapcontinents(/river'
    if token[0] ne '' then cmd += string(", color='", token[0], "'", f='(3a)')
    if token[1] ne '' then cmd += string(", linestyle=", token[1], f='(2a)')
    if token[2] ne '' then cmd += string(", thick=", token[2], f='(2a)')
    cmd += ')'
    print, cmd
    res = execute(cmd)
  endif

  if keyword_set(mc_lak) then begin
    token = strsplit(mc_lak, ',', /extract, count=n_toks)
    cmd = 'mc = mapcontinents(/lake'
    if token[0] ne '' then cmd += string(", color='", token[0], "'", f='(3a)')
    if token[1] ne '' then cmd += string(", linestyle=", token[1], f='(2a)')
    if token[2] ne '' then cmd += string(", thick=", token[2], f='(2a)')
    cmd += ')'
    print, cmd
    res = execute(cmd)
  endif

  if keyword_set(mc_usa) then begin
    token = strsplit(mc_usa, ',', /extract, count=n_toks)
    cmd = 'mc = mapcontinents(/usa'
    if token[0] ne '' then cmd += string(", color='", token[0], "'", f='(3a)')
    if token[1] ne '' then cmd += string(", linestyle=", token[1], f='(2a)')
    if token[2] ne '' then cmd += string(", thick=", token[2], f='(2a)')
    cmd += ')'
    print, cmd
    res = execute(cmd)
  endif

  if keyword_set(mc_can) then begin
    token = strsplit(mc_can, ',', /extract, count=n_toks)
    cmd = 'mc = mapcontinents(/canada'
    if token[0] ne '' then cmd += string(", color='", token[0], "'", f='(3a)')
    if token[1] ne '' then cmd += string(", linestyle=", token[1], f='(2a)')
    if token[2] ne '' then cmd += string(", thick=", token[2], f='(2a)')
    cmd += ')'
    print, cmd
    res = execute(cmd)
  endif


  ; ColorBar command build =================================

  if keyword_set(cb) then begin
    token = strsplit(cb, ',', /extract, count=n_toks)
    ;print, 'cb: ', cb
    cmd = 'cb = colorbar(target=img'
    if token[0] ne '' then cmd += string(", position=[", token[0], ",", token[1], ",", token[2], ",", token[3], "]", f='(9a)')
    if token[4] ne '' then cmd += string(", title='", token[4], "'", f='(3a)')
    cmd += ')'
    print, cmd
    res = execute(cmd)
  endif

  ; MapGrid commands build =================================

  if keyword_set(mg) then begin
    token = strsplit(mg, ',', /extract, count=n_toks)
    ;print, 'mg: ', mg
    cmd = "mapgrid.hide = 0"
    print, cmd
    res = execute(cmd)
    cmd = "mapgrid.antialias = 0"
    print, cmd
    res = execute(cmd)

    cmd = "mapgrid.color='" + token[0] + "'"
    print, cmd
    res = execute(cmd)
    cmd = "mapgrid.label_color='" + token[1] + "'"
    print, cmd
    res = execute(cmd)
    cmd = "mapgrid.thick=" + token[2]
    print, cmd
    res = execute(cmd)
    cmd = "mapgrid.grid_latitude=" + token[3]
    print, cmd
    res = execute(cmd)
    cmd = "mapgrid.grid_longitude=" + token[3]
    print, cmd
    res = execute(cmd)
    cmd = "mapgrid.linestyle=" + token[4]
    print, cmd
    res = execute(cmd)
    cmd = "mapgrid.label_align=" + token[5]
    print, cmd
    res = execute(cmd)
  endif

  file_name = string('chirps.', d_yr, '.', d_mo, '.png', form='(5a)')
  img_path = drupal_dir + file_name
  
  tokens = strsplit(i_wdim, ',', /extract)
  height = fix(tokens[1])
  width = fix(tokens[0])
  
  print, 'img.Save, ', img_path, ' height=',height,', width=',width,', border=0, bit_depth=1'
  img.Save, img_path, height=height, width=width, bit_depth=1
  
  img_url = url_path + file_name

  
END

