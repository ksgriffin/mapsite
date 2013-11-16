load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/ut_string.ncl"

undef("get_anoms")
function get_anoms(var:string, lev:numeric)
;******************************************************************************
; Reads in pre-formatted climo files, with individual files containing a single
; synoptic hour (00, 06, 12, or 18) climatology with time coord as day of year.
; Both the means and std. deviations are assembled into a full year's worth of
; data and then subtracted from the input data provided.
;
; Returns: numeric array, type of input, formatted as:
;               (/2, 1464, num_lat, num_lon /)
;          with index 0 of coordinate 0 representing the means and index 1
;          representing the standard deviations
;          Time units are in fractional day of year format, where:
;               0600 UTC 1 January = 1.25
;               1200 UTC 3 February = 35.50
;               1800 UTC 31 December = 366.75
;******************************************************************************

begin

  file_hours = (/"00","06","12","18"/)
  meanfile = addfile("/cfsr/data/climo/mean/"+var+".0p5.mean.climo.nc","r")
  stdfile = addfile("/cfsr/data/climo/stdev/"+var+".0p5.stdev.climo.nc","r")
  print("Reading Climo Data.")

  climo_orig = meanfile->$var$
  sdev_orig = stdfile->$var$

  sdev = new( (/366*4,dimsizes(climo_orig&lat),dimsizes(climo_orig&lon)/),"float")
  climo = sdev
  do day=0,365
    idx=day*4
    do h=0,3
      climo(idx+h,:,:)=climo_orig(day,h,{lev},:,:)
      sdev(idx+h,:,:)=sdev_orig(day,h,{lev},:,:)
    end do
  end do

  climo!0 = "time"
  climo!1 = "lat"
  climo!2 = "lon"
  climo&lat = climo_orig&lat
  climo&lon = climo_orig&lon
  climo&time = fspan(1,366.75,366*4)
  
  ret_arr = new( (/2,dimsizes(climo&time),dimsizes(climo&lat),dimsizes(climo&lon)/),typeof(climo))
  ret_arr!1 = "time"
  ret_arr!2 = "lat"
  ret_arr!3 = "lon"
  ret_arr&lat = climo_orig&lat
  ret_arr&lon = climo_orig&lon
  ret_arr&time = fspan(1,366.75,366*4)

  ret_arr(0,:,:,:) = (/climo/)
  ret_arr(1,:,:,:) = (/sdev/)

  return(ret_arr)

end

undef("get_means")
function get_means(var:string, lev:numeric)
begin

  file_hours = (/"00","06","12","18"/)
  meanfile = addfile("/cfsr/data/climo/mean/"+var+".0p5.mean.climo.nc","r") 
  print("Reading mean data.")

  climo_orig = meanfile->$var$

  climo = new( (/366*4,dimsizes(climo_orig&lat),dimsizes(climo_orig&lon)/),"float")

  do day=0,365
    idx=day*4
    do h=0,3
      climo(idx+h,:,:)=climo_orig(day,h,{lev},:,:)
    end do
  end do

  climo!0 = "time"
  climo!1 = "lat"
  climo!2 = "lon"
  climo&lat = climo_orig&lat
  climo&lon = climo_orig&lon
  climo&time = fspan(1,366.75,366*4)

  return(climo)

end

undef("get_stddevs")
function get_stddevs(var:string, lev:numeric)
begin

  file_hours = (/"00","06","12","18"/)
  std_p = addfile("/cfsr/data/climo/stdev/"+var+".0p5.stdev.climo.nc","r")
  print("Reading std dev data.")

  sdev_orig = std_p->$var$

  std = new( (/366*4,dimsizes(sdev_orig&lat),dimsizes(sdev_orig&lon)/),"float")
 
  do day=0,365
    idx=day*4
    do h=0,3
      std(idx+h,:,:)=sdev_orig(day,h,{lev},:,:)
    end do 
  end do

  std!0 = "time"
  std!1 = "lat"
  std!2 = "lon"
  std&lat = sdev_orig&lat
  std&lon = sdev_orig&lon
  std&time = fspan(1,366.75,366*4)

  return(std)

end

undef("get_means_ml")
function get_means_ml(var:string, lev[*]:numeric)
begin

  file_hours = (/"00","06","12","18"/)
  meanfile = addfile("/cfsr/data/climo/mean/"+var+".0p5.mean.climo.nc","r")
  print("Reading mean data.")

  climo_orig = meanfile->$var$

  climo = new( (/366*4,dimsizes(lev),dimsizes(climo_orig&lat),dimsizes(climo_orig&lon)/),"float")

  do day=0,365
    idx=day*4
    do h=0,3
      climo(idx+h,:,:,:)=climo_orig(day,h,{lev},:,:)
    end do
  end do

  climo!0 = "time"
  climo!1 = "lev"
  climo!2 = "lat"
  climo!3 = "lon"
  climo&lat = climo_orig&lat
  climo&lon = climo_orig&lon
  climo&lev = lev
  climo&time = fspan(1,366.75,366*4)

  return(climo)

end

undef("get_stddevs_ml")
function get_stddevs_ml(var:string, lev[*]:numeric)
begin

  file_hours = (/"00","06","12","18"/)
  stdfile = addfile("/cfsr/data/climo/stdev/"+var+".0p5.stdev.climo.nc","r")
  print("Reading mean data.")
    sdev_orig = stdfile->$var$

  sdev = new( (/366*4,dimsizes(lev),dimsizes(sdev_orig&lat),dimsizes(sdev_orig&lon)/),"float")

  do day=0,365
    idx=day*4
    do h=0,3
      sdev(idx+h,:,:,:)=sdev_orig(day,h,{lev},:,:)
    end do
  end do

  sdev!0 = "time"
  sdev!1 = "lev"
  sdev!2 = "lat"
  sdev!3 = "lon"
  sdev&lat = sdev_orig&lat
  sdev&lon = sdev_orig&lon
  sdev&lev = lev
  sdev&time = fspan(1,366.75,366*4)

  return(sdev)

end

undef("get_climo")
function get_climo(var:string, lev[*]:numeric)
begin

  means = get_means_ml(var,lev)
  sdevs = get_stddevs_ml(var,lev)

  thing = new( (/2,dimsizes(means&time),dimsizes(means&lev),dimsizes(means&lat),dimsizes(means&lon)/),typeof(means))
  thing(0,:,:,:) = (/means/)
  thing(1,:,:,:) = (/sdevs/)
  
  thing!0 = "stat"
  thing!1 = "time"
  thing!2 = "lev"
  thing!3 = "lat"
  thing!4 = "lon"
  thing&stat = (/"means","stddevs"/)
  thing&lat = means&lat
  thing&lon = means&lon
  thing&lev = means&lev
  thing&time = fspan(1,366.75,366*4)

  delete([/means,sdevs/])

  return(thing)

end


undef("calc_anoms")
function calc_anoms(obs[*][*][*]:numeric, var:string, lev:numeric)
; This currently does not work if dates wrap around from Dec to Jan!!
begin

  climo_stuff = get_means(var,lev)
  ;anoms = new( dimsizes(obs), "float")
  ;copy_VarCoords(obs,anoms)
  ; A brief attempt to check for whether the data is aligned with same lons
  if(min(obs&lon).ne.min(climo_stuff&lon))then
    climo_stuff = lonFlip(climo_stuff)
  ;  print("Flipping")
  end if 
  lat_min = min(obs&lat)
  lat_max = max(obs&lat)
  lon_min = min(obs&lon)
  lon_max = max(obs&lon)
  conv_times = toint(ut_string(obs&time,"%j"))+toint(ut_string(obs&time,"%h"))/24.0
;  sort_time = qsort(conv_times)
;  printVarSummary(obs)
;  printVarSummary(climo_stuff({conv_times},{lat_min:lat_max},{lon_min:lon_max}))
  anoms = obs(time|:,lat|:,lon|:) - climo_stuff({conv_times},{lat_min:lat_max},{lon_min:lon_max})
  copy_VarCoords(obs,anoms)
  return(anoms)

end

undef("calc_std_anoms")
function calc_std_anoms(obs[*][*][*]:numeric, var:string, lev:numeric )
; This currently does not work if dates wrap around from Dec to Jan!!
begin

  stddev_stuff = get_stddevs(var,lev)
  anoms = calc_anoms(obs,var,lev)
  copy_VarCoords(obs,anoms)
  conv_times = toint(ut_string(obs&time,"%j"))+toint(ut_string(obs&time,"%h"))/24.0
  std_anoms = anoms(:,:,:) / stddev_stuff({conv_times},:,:)
  copy_VarCoords(obs,std_anoms)
  return(std_anoms)

end
