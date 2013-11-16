;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;load "/home/carl/nclscripts/lib/gem2ncl.ncl"
load "/home/carl/nclscripts/lib/ut_string.ncl"
    
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
begin
  
  print( "Updating GFS data..." )
  
  nDays = 90 ; number of days we want to store
  
  ; most recent date
  year = stringtointeger( systemfunc( "date +'%Y' -d today " ) )
  month = stringtointeger( systemfunc( "date +'%m' -d today " ) )
  day = stringtointeger( systemfunc( "date +'%d' -d today " ) )
  inHour = stringtointeger( systemfunc( "date +'%H' -d today " ) )
  
  print ( (/inHour/) )
  
  if( ( inHour.lt.3 ) ) then
    hour = 18
  end if 
  if( ( inHour.ge.3 ).and.( inHour.lt.9 ) ) then
    hour = 0
  end if
  if( ( inHour.ge.9 ).and.( inHour.lt.15 ) ) then
    hour = 6
  end if 
  if( ( inHour.ge.15 ).and.( inHour.lt.21 ) ) then
    hour = 12 
  end if
  if( ( inHour.ge.21 ) ) then 
    hour = 18
  end if 

  print ( (/hour/))
  timeUnits = "days since 1800-01-01 00:00:00"
  currDate = ut_inv_calendar( year, month, day, hour, 0, 0, timeUnits, 0 )
  if( inHour.lt.3 ) then
    currDate = currDate - 1
  end if

  print( (/ ut_string( currDate, "" ) /) )

  print( "Read the old GFS data..." )
  fileName = "/free1/kgriffin/rt_gfs/gfs200.nc"
  inFile = addfile( fileName, "r" )
  uOld = inFile->u200
  vOld = inFile->v200

  ; set up the array for the GFS data
  nt = 4 * nDays + 1
  ny = 361
  nx = 720

  uNew = new( (/ nt, ny, nx /), "float" )
  uNew!0 = "time"
  uNew!1 = "lat"
  uNew!2 = "lon"
  uNew&time = currDate + fspan( -nDays, 0, nt )
  uNew&lat = fspan( -90, 90, ny )
  uNew&lon = fspan( 0, 359.5, nx )

  vNew = uNew

  print( "Copying the overlapping old data into a new array..." )
  uNew({:max(uOld&time)},:,:) = uOld({min(uNew&time):},:,:)
  vNew({:max(vOld&time)},:,:) = vOld({min(vNew&time):},:,:)

  print( "Read the new grib2 GFS data..." )
  t0 = ind( max(uOld&time).eq.uNew&time )
  missingDates = ""
  do t = t0 + 1, nt - 1
    print( (/ ut_string( uNew&time(t), "" ) /) )
    gfsFileName = "/cas2/unidata/GRIB/gfs0p5deg/GFS_" \\
                + ut_string( uNew&time(t), "%y%N%D_%H" ) \\
                + "_000.grb"
    gfsFile = addfile( gfsFileName, "r" )

    if( ismissing( gfsFile ) ) then
      print( "DANGER! DANGER! File did not download: " + gfsFileName )
      system( "mail -s 'Error downloading file: " + gfsFileName \\
              + "' kgriffin@albany.edu < error_email.txt " )
      missingDates = missingDates + ut_string(uNew&time(t),"%y%N%D_%H")
      uNew(t,:,:) = uNew@_FillValue
      vNew(t,:,:) = vNew@_FillValue
    else
      presLev = 200 * 100
      
      uNew(t,:,:) = (/ gfsFile->UGRD_P0_L100_GLL0({presLev},::-1,:) /)
      vNew(t,:,:) = (/ gfsFile->VGRD_P0_L100_GLL0({presLev},::-1,:) /)
    end if
    
  end do
  
  print( min(uNew) + " " + max(uNew) )
  print( min(vNew) + " " + max(vNew) )
  
  print( "Missing: " + num( ismissing( (/ uNew, vNew /) ) ) )
  print( "Missing dates: " + missingDates )
;  uNew(lat|:,lon|:,time|:) = linmsg( uNew(lat|:,lon|:,time|:), -1 )
;  vNew(lat|:,lon|:,time|:) = linmsg( vNew(lat|:,lon|:,time|:), -1 )
;  print( "Missing: " + num( ismissing( (/ uNew, vNew /) ) ) )
  
  print( "Writing the 200GFS data..." )
  outFileName = "/free1/kgriffin/rt_gfs/gfs200.nc"
;  system( "rm -f " + outFileName )
;  outFile = addfile( outFileName, "c" )
  outFile = addfile( outFileName, "w" )
  
  outFile->u200 = uNew
  outFile->v200 = vNew
  
  print( "Thank you, come again." )
  
end
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
