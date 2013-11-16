undef("getNumRegions")
function getNumRegions()
begin
  ; This should match the max index in getRegion function below
  return(17)
end

undef("getRegion")
function getRegion(idx:numeric, res:logical)
begin

  res@mpLimitMode = "LatLon"
  res@mpGridLatSpacingF = 20
  res@mpGridLonSpacingF = 20
  if(isatt(res,"mpProjection"))then
    delete(res@mpProjection)
    delete(res@mpCenterLatF)
    delete(res@mpPerimOn)
  end if

  if(idx.eq.1)then
    res@regName = "conus"
    res@mpMinLatF = 17.
    res@mpMaxLatF = 57.
    res@mpMinLonF = -135.
    res@mpMaxLonF = -60.
  end if
  if(idx.eq.2)then
    res@regName = "namer"
    res@mpMinLatF = 5. 
    res@mpMaxLatF = 75.
    res@mpMinLonF = 180.
    res@mpMaxLonF = 320. 
  end if
  if(idx.eq.3)then
    res@regName = "npac"
    res@mpMinLatF = -5.
    res@mpMaxLatF = 75.
    res@mpMinLonF = 110.
    res@mpMaxLonF = 260.
  end if
  if(idx.eq.4)then
    res@regName = "natl"
    res@mpMinLatF = 10.
    res@mpMaxLatF = 80.
    res@mpMinLonF = -100.
    res@mpMaxLonF = 20.
  end if
  if(idx.eq.5)then
    res@regName = "eur"
    res@mpMinLatF = 25.
    res@mpMaxLatF = 80.
    res@mpMinLonF = -40.
    res@mpMaxLonF = 70.
  end if
  if(idx.eq.6)then
    res@regName = "wpac"
    res@mpMinLatF = -5.
    res@mpMaxLatF = 60.
    res@mpMinLonF = 90.
    res@mpMaxLonF = 195.
  end if
  if(idx.eq.7)then
    res@regName = "tropatl"
    res@mpMinLatF = -10.
    res@mpMaxLatF = 40.
    res@mpMinLonF = -100.
    res@mpMaxLonF = 10.
  end if
  if(idx.eq.8)then
    res@regName = "samer"
    res@mpMinLatF = -65.
    res@mpMaxLatF = 10.
    res@mpMinLonF = -170.
    res@mpMaxLonF = -20.
  end if
  if(idx.eq.9)then
    res@regName = "africa"
    res@mpMinLatF = -45.
    res@mpMaxLatF = 45.
    res@mpMinLonF = -30.
    res@mpMaxLonF = 65.
  end if
  if(idx.eq.10)then
    res@regName = "asia"
    res@mpMinLatF = -5.
    res@mpMaxLatF = 80.
    res@mpMinLonF = 25.
    res@mpMaxLonF = 175.
  end if
  if(idx.eq.11)then
    res@regName = "sio"
    res@mpMinLatF = -65.
    res@mpMaxLatF = 10.
    res@mpMinLonF = 10.
    res@mpMaxLonF = 130.
  end if
  if(idx.eq.12)then
    res@regName = "spac"
    res@mpMinLatF = -65.
    res@mpMaxLatF = 10.
    res@mpMinLonF = 90.
    res@mpMaxLonF = 210.
  end if
  if(idx.eq.13)then
    res@regName = "globe"
    res@mpMinLatF = -75.
    res@mpMaxLatF = 75.
    res@mpMinLonF = 0.
    res@mpMaxLonF = 360.
    res@mpGridLatSpacingF = 30
    res@mpGridLonSpacingF = 30
  end if
  if(idx.eq.14)then
    delete(res@mpLimitMode) 
    res@regName = "arctic"
    res@mpProjection = "Orthographic"
    res@mpPerimOn = False
    res@mpCenterLonF = 180.
    res@mpCenterLatF = 90.
  end if
  if(idx.eq.15)then
    res@regName = "antarctic"
    res@mpProjection = "Orthographic"
    res@mpPerimOn = False
    res@mpCenterLonF = 0.
    res@mpCenterLatF = -90.
  end if
  if(idx.eq.16)then
    res@regName = "eastus"
    res@mpMinLatF = 24.
    res@mpMaxLatF = 50.
    res@mpMinLonF = -104.
    res@mpMaxLonF = -64.
  end if
  if(idx.eq.17)then
    res@regName = "westus"
    res@mpMinLatF = 24.
    res@mpMaxLatF = 53.
    res@mpMinLonF = -126.
    res@mpMaxLonF = -86.
  end if

  ; If expanded, update the number of regions in getNumRegions above.

  if(.not.isatt(res,"mpProjection"))then
    res@mpCenterLonF = (((res@mpMaxLonF-res@mpMinLonF)/2.)+res@mpMinLonF)
  end if

  res@gsnMajorLatSpacing = res@mpGridLatSpacingF
  res@gsnMajorLonSpacing = res@mpGridLonSpacingF

  return (res)

end
