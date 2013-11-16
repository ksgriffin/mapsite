;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
; gempak.ncl
; -------------------------------------
; A library of functions native to GEMPAK that aren't as easily done in NCL.
;
; First created 31 March 2012.
; -------------------------------------
; List of required "load" statements:
;
;
;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

;######################################
;  Other relevant and useful functions that are built-in:
;  ------------------------------------
;  z2geouv (z,lat,lon, 1) - geostrophic wind from height
;  dewtemp_trh(tk,rh) - dewpoint from temp and RH
;  relhum_ttd(t,td,0) - RH from temp/dewpt (0 in %, 1 in fraction)
;  uv2vr_cfd(u,v,lat,lon, 3) - centered finite difference rel. vort.
;  uv2dv_cfd(u,v,lat,lon, 3) - cent. fin. diff. divergence
;    (both of these fxns have harmonic-based versions if give full globe data)
;  lclvl(p,tk,tdk) - LCL level, in pressure units of p (docs says hPa)
;  hydro(p,tkv,zsfc) - Geo. height from pressure, virt. temp, and sfc geop hgt
;  
;######################################


;**************************************
; function advection
; -----------------
; Calculates the instantaneous advection of a quantity, 
;   defined as wind*grad(field)
; NOTE: uses spherical harmonics to compute gradients
;       and therefore requires a global grid.
;**************************************

undef("advection")
function advection(u:numeric,v:numeric,field:numeric)
; u: zonal wind grid
;    Can have an attribute "units" if units other than
;    m/s are to be assumed
; v: meridional wind grid
; field: quantity to be advected by u and v
; 
; returns a quantity with coordinates that match those of the u variable
;
; Written by Kyle Griffin on 31 March 2012
local mks_units, kt_units, mph_units, grad_x, grad_y, adv_u, adv_v, adv
begin

  mks_units = (/"m/s","ms-1","ms^-1","m s^-1","m s-1","meters/second","meters per second"/)
  kt_units = (/"kts","kt","knots","nautical miles per hour"/)
  mph_units = (/"mph","mi/h","miles/hour","miles/hr","miles per hour"/)

  if(isatt(u,"units"))then
    if(all(u@units.ne.mks_units))then
      if(any(u@units.eq.kt_units))then
        u = u*1.942
      else if(any(u@units.eq.mph_units))then
        u = u*2.237
      else
        return(u@_FillValue)
      end if
      end if
    end if
  end if

  grad_x = v
  grad_y = u
  
  gradsf(field,grad_x,grad_y)

  adv_u = u * grad_y * -1
  adv_v = v * grad_x * -1

  adv = adv_u + adv_v

  copy_VarCoords(u,adv)

  return(adv)

end

undef("flux")
function flux(u:numeric,v:numeric,field:numeric)
; u: zonal wind grid
;    Can have an attribute "units" if units other than
;    m/s are to be assumed
; v: meridional wind grid
; field: quantity that will be fluxed by u and v
; 
; returns a quantity with coordinates that match those of the u variable
;
; Written by Kyle Griffin on 1 April 2012
local flux_u,flux_v,flux,mks_units, kt_units, mph_units, grad_x, grad_y, adv_u, adv_v, adv
begin

  mks_units = (/"m/s","ms-1","ms^-1","m s^-1","m s-1","meters/second","meters per second"/)
  kt_units = (/"kts","kt","knots","nautical miles per hour"/)
  mph_units = (/"mph","mi/h","miles/hour","miles/hr","miles per hour"/)

  if(isatt(u,"units"))then
    if(all(u@units.ne.mks_units))then
      if(any(u@units.eq.kt_units))then
        u = u*1.942
      else if(any(u@units.eq.mph_units))then
        u = u*2.237
      else
        return(u@_FillValue)
      end if
      end if
    end if
  end if


  flux_u = abs(u) * field
  flux_v = abs(v) * field

  flux = flux_u + flux_v

  copy_VarCoords(u,flux)

  return(flux)

end

undef("pot_temp")
function pot_temp(t:numeric, p:numeric)
; t - temperature on a surface
; p - pressures (in Pa) on that surface
;   NOTE: t and p should be of same dimensions 
;           if p is more than a single number
;
; returns values with coordinates of temperature input
;
; written by Kyle Griffin on 2 April 2012
; modifications: K. Griffin - 22-23 May 2012
local theta,R,Cp,ref_pres
begin

  R = 287.05
  Cp = 1004.
  ref_pres = 100000.

  rankt = dimsizes(dimsizes(t))
  rankp = dimsizes(dimsizes(p))

  if(rankp.ne.rankt)then
    if(rankt.eq.4)then
      pcon = conform(t,p,1)
    end if 
    if(rankt.eq.3)then
      pcon = conform(t,p,0)
    end if
  else
    pcon = p
  end if

  theta = t*((ref_pres/pcon)^(R/Cp))

  copy_VarCoords(t,theta)

  return(theta)

end

undef("equiv_pot_temp")
function equiv_pot_temp(t:numeric, q:numeric, p:numeric)
; t - temperature on a surface
; q - specific humidity (in kg/kg)
; p - pressures (in Pa) on that surface
;   NOTE: t and p should be of same dimensions 
;           if p is more than a single number
;
; returns values with coordinates of temperature input
;
; written by Kyle Griffin on 23 May 2012
local theta,R,Cp,ref_pres
begin

  R = 287.05
  Cp = 1004.
  ref_pres = 100000.

  rankt = dimsizes(dimsizes(t))
  rankp = dimsizes(dimsizes(p))

  if(rankp.ne.rankt)then

    if(rankt.eq.4)then
      pcon = conform(t,p,1)
    end if
    if(rankt.eq.3)then
      pcon = conform(t,p,0)
    end if
  else
    pcon = p
  end if

  thetae = (t + (2400000.0/1004.0)*(q/(1-q)))*((ref_pres/pcon)^(R/Cp))
  thetae@long_name = "equivalent potential temperature"
  thetae@units = "K"

  copy_VarCoords(t,thetae)

  return(thetae)

end


undef("front_2d")
function front_2d(u:numeric, v:numeric, t:numeric, p:numeric)

begin

  theta = pot_temp(t,p)

  print(max(theta)+" "+min(theta))
  
  theta_gradx = theta
  theta_grady = theta
  gradsf(theta,theta_gradx,theta_grady)

  u_gradx = u
  u_grady = u
  gradsf(u,u_gradx,u_grady)

  v_gradx = v
  v_grady = v
  gradsf(v,v_gradx,v_grady)

  x_term = theta_gradx*-((u_gradx*theta_gradx)+(v_gradx*theta_grady))
  y_term = theta_grady*-((u_grady*theta_gradx)+(v_grady*theta_grady))

  print(max(x_term)+" "+max(y_term))

  fronto = (1/(theta_gradx+theta_grady))*(x_term+y_term)

  copy_VarCoords(t,fronto)

  return(fronto)

end
