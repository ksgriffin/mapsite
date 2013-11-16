load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/ut_string.ncl"
; below is not really necessary
load "/home/carl/nclscripts/lib/tTick.ncl"

load "/home/kgriffin/ncl_lib/spread_colors_rgba.ncl"
load "/home/kgriffin/ncl_lib/do_anoms.ncl"
load "/home/kgriffin/ncl_lib/gempak.ncl"
load "/home/kgriffin/ncl_lib/bluemarble.ncl"
load "/home/kgriffin/ncl_lib/mappage.ncl"

load "/spare11/ktyle/gem2ncl/ncl6/gem2ncl.ncl"

;load "/home/kgriffin/ncl_lib/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
; ^ code above has huge bugs in PV-calculating script
;   (aka, the calculation line is commented out!!)
; NOTE: not in the 6.1.x versions.
