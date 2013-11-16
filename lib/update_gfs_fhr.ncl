;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;load "/home/carl/nclscripts/lib/gem2ncl.ncl"
load "/home/carl/nclscripts/lib/ut_string.ncl"

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Written by Kyle Griffin; Spring 2012
; updates: 16 May 2012 - soft coded max_cycles to allow for a longer wait time
;          22 May 2012 - temperature, u, and v at surface are now 3-D variables
;                        upon hybrid sigma levels upgrade (added 80m and 100m)
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
procedure update_gfs_fhr(fileLoc:string, plevels[*]:numeric, opt:logical, fhr:integer)

begin

  print( "Updating GFS forecast F"+sprinti("%0.3i",fhr)+" data..." )

  ; most recent date
  year = stringtointeger( systemfunc( "date +'%Y' -d today " ) )
  month = stringtointeger( systemfunc( "date +'%m' -d today " ) )
  day = stringtointeger( systemfunc( "date +'%d' -d today " ) )
  inHour = stringtointeger( systemfunc( "date +'%H' -d today " ) )

  ;Assumes script is being run at least :30 minutes after start of cycle
  ;Will spend lots of time waiting if this is not the case, but that's ok
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

  timeUnits = "days since 1800-01-01 00:00:00"
  currDate = ut_inv_calendar( year, month, day, hour, 0, 0, timeUnits, 0 )
  if( inHour.lt.3 ) then
    currDate = currDate - 1
  end if

  fhrDate = currDate + (tofloat(fhr)/24)
  fhrDate@units = "days since 1800-01-01 00:00:00"

  print("Cycle: "+ut_string( currDate, "" ) )
  print("Forecast date: "+ut_string(fhrDate,"") )

  fileName = fileLoc+"gfs"+sprinti("%0.2i",hour)+"_F"+sprinti("%0.3i",fhr)+".nc"
 
  ; Maximum number of 30-second cycles to wait for the data files
  max_cycles = 120
 
  ; set up the array for the GFS data
  nt = 1 
  ny = 361
  nx = 720
  nlevels = toint(dimsizes(plevels))

  uNew = new( (/ nt, nlevels, ny, nx /), "float" )
  uNew!0 = "time"
  uNew!1 = "pres_lev"
  uNew!2 = "lat"
  uNew!3 = "lon"
  uNew&time = fhrDate
  uNew&pres_lev = plevels
  uNew&lat = fspan( -90, 90, ny )
  uNew&lon = fspan( 0, 359.5, nx )
  uNew&pres_lev@units = "hPa" 
  uNew&lat@units = "degrees_north"
  uNew&lon@units = "degrees_east"

  ;print(plevels)
 
  vNew = uNew
  wNew = uNew   ;(:,{100:1000},:,:)  < w doesn't exist above 100 mb
  tNew = uNew
  gNew = uNew
  rhNew = uNew

  mslpNew = new( (/nt, ny, nx/), "float")
  mslpNew!0 = "time"
  mslpNew!1 = "lat"
  mslpNew!2 = "lon"
  mslpNew&time = fhrDate
  mslpNew&lat = fspan( -90, 90, ny )
  mslpNew&lon = fspan( 0, 359.5, nx )
  mslpNew&lat@units = "degrees_north"
  mslpNew&lon@units = "degrees_east"

  ;mslp: PRMSL_P0_L101_GLL0
  tsfcNew = mslpNew ;TMP_P0_L103_GLL0
  rhsfcNew = mslpNew ;RH_P0_L103_GLL0 
  pwNew = mslpNew ;PWAT_P0_L200_GLL0
  usfcNew = mslpNew ;UGRD_P0_L103_GLL0
  vsfcNew = mslpNew ;VGRD_P0_L103_GLL0
  gustNew = mslpNew ;GUST_P0_L1_GLL0
  if(fhr.ne.0) then
    tcldNew = mslpNew ;TCDC_P8_L200_GLL0_avg6h
    olrNew = mslpNew ;ULWRF_P8_L8_GLL0_avg6h
    pcp6New = mslpNew ;APCP_P8_L1_GLL0_acc6h
  end if
  capeNew = mslpNew ;CAPE_P0_L1_GLL0
  cinNew = mslpNew ;CIN_P0_L1_GLL0
  liNew = mslpNew ;LFTX_P0_L1_GLL0
  ;srhNew = mslpNew ;HLCY_P0_2L103_GLL0
  gfzlvNew = mslpNew ;HGT_P0_L4_GLL0
  rhfzlvNew = mslpNew ;RH_P0_L4_GLL0

  dtpresNew = new( (/nt, 2, ny, nx/),"float" )
  dtpresNew!0 = "time"
  dtpresNew!1 = "pv_lev"
  dtpresNew!2 = "lat"
  dtpresNew!3 = "lon"
  dtpresNew&time = fhrDate
  dtpresNew&pv_lev =  (/-2, 2/)
  dtpresNew&lat = fspan( -90, 90, ny )
  dtpresNew&lon = fspan( 0, 359.5, nx )
  dtpresNew&lat@units = "degrees_north"
  dtpresNew&lon@units = "degrees_east"


  ;dtpres:  ;PRES_P0_L109_GLL0 
  dttmpNew = dtpresNew ;TMP_P0_L109_GLL0
  dtuNew = dtpresNew ;UGRD_P0_L109_GLL0
  dtvNew = dtpresNew ;VGRD_P0_L109_GLL0

  print( "Read the F"+sprinti("%0.3i",fhr)+" grib2 GFS data..." )
    sysFileName = "/cas2/unidata/GRIB/gfs0p5deg/GFS_" \\
                + ut_string( currDate, "%y%N%D_%H" ) \\
                + "_"+sprinti("%0.3i",fhr)
    gfsFileName = sysFileName+".grb"

    ; Wait for file to be present, up to ~35 minutes
    ; (Yeah, we all know NCEP can be slower than that, but oh well)
    ismissingcount = 0
    do while(.not.isfilepresent(sysFileName).and.ismissingcount.le.max_cycles)
      ismissingcount = ismissingcount + 1
      print(ismissingcount+" sleep 30")
      system("sleep 30")
    end do

    if( ismissingcount.ge.max_cycles ) then
      print( "DANGER! DANGER! File did not download: " + gfsFileName )
      system( "mail -s 'Error downloading TEST file: " + gfsFileName \\
              + "' ksgriffin2@wisc.edu < error_email.txt " )
      uNew(0,:,:,:) = uNew@_FillValue
      vNew(0,:,:,:) = vNew@_FillValue
      tNew(0,:,:,:) = tNew@_FillValue
      gNew(0,:,:,:) = gNew@_FillValue
      rhNew(0,:,:,:) = rhNew@_FillValue
      if(presLev.ge.100) then
        wNew = uNew
        wNew(0,:,:,:) = wNew@_FillValue 
      end if
    end if

    checksize = 48000000
    if(tostring(fhr).eq."0") then
      checksize = 42000000
    end if

    if(isfilepresent(sysFileName)) then
      ; Wait until file is fully populated
      ; Ultimately should be 48-55 MB, but going with low 40s to be safe
      do while(tofloat(systemfunc("du -sb "+sysFileName+"| awk '{print $1}'")).le.checksize)
        print("Waiting for "+sprinti("%0.3i",fhr)+" file to build...")
        print(systemfunc("du -sb "+sysFileName+"| awk '{print $1}'"))
        system("sleep 30")
      end do

      system("sleep 15")

      gfsFile = addfile( gfsFileName, "r" )

      print("Processing F"+sprinti("%0.3i",fhr)+" data now...")

      do i=0,nlevels-1
        presLev = plevels(i) * 100
        ;print(presLev+"")
        ; Pressure Level variables
        if(presLev.ge.10000) then
          wNew(0,i,:,:) = (/ gfsFile->VVEL_P0_L100_GLL0({presLev},::-1,:) /)
        end if
        if(presLev.lt.10000) then
          wNew(0,i,:,:) = wNew@_FillValue
        end if
        uNew(0,i,:,:) = (/ gfsFile->UGRD_P0_L100_GLL0({presLev},::-1,:) /)
        vNew(0,i,:,:) = (/ gfsFile->VGRD_P0_L100_GLL0({presLev},::-1,:) /)
        tNew(0,i,:,:) = (/ gfsFile->TMP_P0_L100_GLL0({presLev},::-1,:) /)
        gNew(0,i,:,:) = (/ gfsFile->HGT_P0_L100_GLL0({presLev},::-1,:) /)
        rhNew(0,i,:,:) = (/ gfsFile->RH_P0_L100_GLL0({presLev},::-1,:) /)
      end do 

     ; Single layer variables
     ; plus some funky stuff for variable names changing over time
     if(opt.eq.True) then
       delete(gfsFile)
       gfsFile = addfile( gfsFileName, "r" )
       mslpNew(0,:,:) = (/gfsFile->PRMSL_P0_L101_GLL0(::-1,:) /)
       tsfcNew(0,:,:) = (/gfsFile->TMP_P0_L103_GLL0({2},::-1,:) /)
       rhsfcNew(0,:,:) = (/gfsFile->RH_P0_L103_GLL0(::-1,:) /)
       pwNew(0,:,:) = (/gfsFile->PWAT_P0_L200_GLL0(::-1,:) /)
       usfcNew(0,:,:) = (/gfsFile->UGRD_P0_L103_GLL0({10},::-1,:) /)
       vsfcNew(0,:,:) = (/gfsFile->VGRD_P0_L103_GLL0({10},::-1,:) /)
       gustNew(0,:,:) = (/gfsFile->GUST_P0_L1_GLL0(::-1,:) /)
       ;ulwrfNew(0,:,:) = (/gfsFile->ULWRF_P8_L8_GLL0_avg6h(::-1,:) /)
       if(fhr.ne.0) then
         if(fhr.eq.6) then
           tcldNew(0,:,:) = (/gfsFile->TCDC_P8_L200_GLL0_avg(::-1,:) /)
           olrNew(0,:,:) = (/gfsFile->ULWRF_P8_L8_GLL0_avg(::-1,:) /)
           pcp6New(0,:,:) = (/gfsFile->APCP_P8_L1_GLL0_acc(::-1,:) /)
         else
           tcldNew(0,:,:) = (/gfsFile->TCDC_P8_L200_GLL0_avg6h(::-1,:) /)
           olrNew(0,:,:) = (/gfsFile->ULWRF_P8_L8_GLL0_avg6h(::-1,:) /)
           pcp6New(0,:,:) = (/gfsFile->APCP_P8_L1_GLL0_acc6h(::-1,:) /)
         end if
       end if
       delete(gfsFile)
       gfsFile = addfile( gfsFileName, "r" )
       capeNew(0,:,:) = (/gfsFile->CAPE_P0_L1_GLL0(::-1,:) /)
       cinNew(0,:,:) = (/gfsFile->CIN_P0_L1_GLL0(::-1,:) /)
       liNew(0,:,:) = (/gfsFile->LFTX_P0_L1_GLL0(::-1,:) /)
       ;srhNew(0,:,:) = (/gfsFile->HLCY_P0_2L103_GLL0(::-1,:) /)
       gfzlvNew(0,:,:) = (/gfsFile->HGT_P0_L4_GLL0(::-1,:) /)
       rhfzlvNew(0,:,:) = (/gfsFile->RH_P0_L4_GLL0(::-1,:) /)
     end if
     delete(gfsFile)
     gfsFile = addfile( gfsFileName, "r" )

     ; +/- 2 PVU levels
     dtpresNew(0,:,:,:) = (/gfsFile->PRES_P0_L109_GLL0(:,::-1,:) /)
     dttmpNew(0,:,:,:) = (/gfsFile->TMP_P0_L109_GLL0(:,::-1,:) /)
     dtuNew(0,:,:,:) = (/gfsFile->UGRD_P0_L109_GLL0(:,::-1,:) /)
     dtvNew(0,:,:,:) = (/gfsFile->VGRD_P0_L109_GLL0(:,::-1,:) /)

  end if
    


  print( "Missing: " + num( ismissing( (/ uNew, vNew /) ) ) )
;  uNew(lat|:,lon|:,time|:) = linmsg( uNew(lat|:,lon|:,time|:), -1 )
;  vNew(lat|:,lon|:,time|:) = linmsg( vNew(lat|:,lon|:,time|:), -1 )
;  print( "Missing: " + num( ismissing( (/ uNew, vNew /) ) ) )

  print( "Writing the GFS data, F"+sprinti("%0.3i",fhr)+"..." )
  system( "rm -f " + fileName )
  outFile = addfile( fileName, "c" )

  outFile->cycle = currDate
  outFile->u = uNew
  outFile->v = vNew
  outFile->t = tNew
  outFile->g = gNew
  outFile->rh = rhNew
  outFile->w = wNew
  outFile->mslp = mslpNew
  outFile->t_sfc = tsfcNew
  outFile->rh_sfc = rhsfcNew 
  outFile->pwat = pwNew
  outFile->u_sfc = usfcNew
  outFile->v_sfc = vsfcNew
  outFile->gust_sfc = gustNew
  if(fhr.ne.0) then
    outFile->tot_cloud = tcldNew
    outFile->olr = olrNew
    outFile->pcp_6h = pcp6New
  end if
  outFile->sbcape = capeNew
  outFile->sbcin = cinNew
  outFile->li = liNew
;  outFile->srh = srhNew
  outFile->hgt_frzlev = gfzlvNew
  outFile->rh_frzlev = rhfzlvNew
  outFile->dt_pres = dtpresNew
  outFile->dt_temp = dttmpNew
  outFile->u_dt = dtuNew
  outFile->v_dt = dtvNew

  print( "Thank you, come again." )

end
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
