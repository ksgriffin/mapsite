load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "/home/carl/nclscripts/lib/ut_string.ncl"
load "/spare11/ktyle/gem2ncl/ncl6/gem2ncl.ncl"

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
undef("populate_gfs_level_archive")

procedure populate_gfs_level_archive(fileLoc:string, plevel:integer, sDate:double, eDate:double, timeUnits:string)

begin

  sDate@units = timeUnits
  eDate@units = timeUnits
  print(timeUnits.ne."days since 1800-01-01 00:00:00")
  if(timeUnits.ne."days since 1800-01-01 00:00:00") then
    sDate = ut_convert(sDate,"days since 1800-01-01 00:00:00")
    eDate = ut_convert(eDate,"days since 1800-01-01 00:00:00")
  end if

  nDays = eDate-sDate ; number of days we want to store
  outFileName = fileLoc+"gfs"+plevel+".nc"

  print( (/ ut_string( eDate, "" ) /) )
 ; year = 2011
 ; month = 12
 ; day = 5
 ; hour = 6

  ;timeUnits = "days since 1800-01-01 00:00:00"
  ;lastDate = ut_inv_calendar( year, month, day, hour, 0, 0, timeUnits, 0 )
   
  lastDate = eDate
  ; set up the array for the GFS data
  nt = toint(4 * nDays + 1)
  ny = 361
  nx = 720

  u = new( (/ nt, ny, nx /), "float" )
  u!0 = "time"
  u!1 = "lat"
  u!2 = "lon"
  u&time = lastDate + fspan( -nDays, 0, nt )
  u&lat = fspan( -90, 90, ny )
  u&lon = fspan( 0, 359.5, nx )
  
  u&time@units = timeUnits
  u&lat@units = "degrees_north"
  u&lon@units = "degrees_east"

  u@units = "m s-1"
  u@center = "US National Weather Service - NCEP (WMC)"
  u@production_status = "Operational products"
  u@_FillValue = 1e+20
  u@grid_type = "Latitude/longitude"
  u@parameter_discipline_and_category = "Meteorological products, Momentum"
  u@level = plevel 
  u@level_type = "Isobaric surface (hPa)"
  u@forecast_time = 0
  u@forecast_time_units = "hours"
  u@long_name = "u-component of wind"

  v = u
  v@long_name = "v-component of wind"

  w = u
  w@long_name = "w-component of wind"
  w@units = "hPa s-1"

  temp = u
  temp@parameter_discipline_and_category = "Meteorological products, Temperature"
  temp@long_name = "temperature"
  temp@units = "Kelvin"

  rh = u
  rh@parameter_discipline_and_category = "Meteorological products, Moisture"
  rh@long_name = "relative humidity"
  rh@units = "%"

  g = u
  g@parameter_discipline_and_category = "Meteorological products, Mass"
  g@long_name = "height"
  g@units = "meters"

  print( "For level: "+plevel)
  print( ut_string( u&time(0), "" ) + "    to    " \\
       + ut_string( u&time(nt-1), "" ) )

  print( "Reading the gemcrap GFS data..." )
  gfsDir = "/nasdata1/unidata/nmc2/"
  utc_date = ut_calendar( u&time, -5 )
  do t = 0, nt-1
    print( (/ ut_string( u&time(t), "" ) /) )
      fileName = gfsDir \\
               + ut_string( u&time(t), "%y%N%D%H" ) \\
               + "_gfs_255.gem"
  ; print(fileName)

    u(t,:,:) = gem_read( fileName, date2gem( u&time(t), True ), "UREL", plevel, 1 )
    v(t,:,:) = gem_read( fileName, date2gem( v&time(t), True ), "VREL", plevel, 1 )
    w(t,:,:) = gem_read( fileName, date2gem( v&time(t), True ), "OMEG", plevel, 1 )
    rh(t,:,:) = gem_read( fileName, date2gem( v&time(t), True ), "RELH", plevel, 1 )
    temp(t,:,:) = gem_read( fileName, date2gem( v&time(t), True ), "TMPK", plevel, 1 )
    g(t,:,:) = gem_read( fileName, date2gem( v&time(t), True ), "HGHT", plevel, 1 )    


  end do

  print( min(u) + " " + max(u) )
  print( min(v) + " " + max(v) )
  print( min(w) + " " + max(w) )
  print( min(rh) + " " + max(rh) )
  print( min(temp) + " " + max(temp) )
  print( min(g) + " " + max(g) )


  print( "Missing: " + num( ismissing( (/ u, v /) ) ) )
;  u850(lat|:,lon|:,time|:) = linmsg( u850(lat|:,lon|:,time|:), -1 )
;  v850(lat|:,lon|:,time|:) = linmsg( v850(lat|:,lon|:,time|:), -1 )
;  print( "Missing: " + num( ismissing( (/ u850, v850 /) ) ) )

  print( "Writing the GFS data..." )
  ;file name defined up top  
  system( "rm -f " + outFileName )
  outFile = addfile( outFileName, "c" )
;  outFile = addfile( outFileName, "w" )

  outFile->u = u
  outFile->v = v
  outFile->w = w
  outFile->rh = rh
  outFile->t = temp
  outFile->g = g


end
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
