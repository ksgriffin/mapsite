undef("spread_colors_rgba_noread")
function spread_colors_rgba_noread(colors[*][*]:numeric, ind_start:numeric,ind_end:numeric,res[1]:logical)
local nlevels, cmap, ncolors, min_index, max_index, minix, maxix, \
reverse, itmp, fmin, fmax, fcols, icols
begin

  cmap = colors(ind_start:ind_end,:)
  ncolors = dimsizes(cmap(:,0))

;---Check if the approriate contour level resources have been set.
  if(isatt(res,"cnLevels")) then
    nlevels = dimsizes(res@cnLevels)
  else if (isatt(res,"cnMinLevelValF").and. \
           isatt(res,"cnMinLevelValF").and. \
           isatt(res,"cnLevelSpacingF")) then
    nlevels = toint(((res@cnMaxLevelValF-res@cnMinLevelValF)/res@cnLevelSpacingF)+1)
  else
    print("spread_colors: warning: either cnLevels or")
    print("cnMinLevelValF/cnMaxLevelValF/cnLevelSpacingF")
    print("must be set. Defaulting...")
    return(cmap)
  end if
  end if

;
; -1 indicates that min/max_index should be set equal to ncolors - 1
; -2 indicates that min/max_index should be set equal to ncolors - 2, etc.
;
; If after adjusting for negative indices, and maxix < minix, then 
; this implies that the user wants to reverse the colors.

  min_index = 0
  max_index = -1

  if (min_index .lt. 0)
    minix = ncolors + min_index
  else
    minix = min_index
  end if

  if (max_index .lt. 0)
    maxix = ncolors + max_index
  else
    maxix = max_index
  end if
;---Make sure indices fall within range of the color map.
  minix = min((/ncolors-1,max((/0,minix/))/))
  maxix = min((/ncolors-1,max((/0,maxix/))/))

;---If maxix < minix, then colors are to be reversed.
  reverse = False
  if(maxix.lt.minix)
    reverse = True
    itmp    = maxix
    maxix   = minix
    minix   = itmp
  end if

  fmin  = tofloat(minix)
  fmax  = tofloat(maxix)
  fcols = fspan(fmin,fmax,nlevels+1)
  if(.not.reverse) then
    icols = tointeger(fcols + 0.5)
  else
    icols = tointeger(fcols(::-1) + 0.5)
  end if

  if(isatt(res,"cnFirstColorTransparent")) then
    if(res@cnFirstColorTransparent) then 
      cmap(icols(0),3) = 0
    end if
  end if

  if(isatt(res,"cnFirstColorWhite")) then
    if(res@cnFirstColorWhite) then
      cmap(icols(0),:) = (/1,1,1,1/)
    end if
  end if

  return(cmap(icols,:))
end

undef("spread_colors_rgba")
function spread_colors_rgba(colormap[1]:string, ind_start:numeric,ind_end:numeric,res[1]:logical)
local nlevels, cmap, ncolors, min_index, max_index, minix, maxix, \
reverse, itmp, fmin, fmax, fcols, icols
begin
;---Get the RGBA values for the given color map.
  cmap_init    = read_colormap_file(colormap)
  return(spread_colors_rgba_noread(cmap_init,ind_start,ind_end,res))
end
