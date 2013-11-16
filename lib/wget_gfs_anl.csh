#!/bin/csh

echo "Enter starting date in YYYYMMDDHH format, to six hour intervals"
set startdate = $<
echo "Enter last date in similar format, inclusive:"
set lastdate = $<

set dest_dir = "/free1/kgriffin/gfs_temp"

cd $dest_dir

set date = $startdate
echo Going from $date to $lastdate

while (${date} <= ${lastdate})

echo This loop is for ${date}

## parsing year/day/month out of date

@ hour = `expr ${date} % 100`
@ day = `expr ${date} / 100 % 100`
@ month = `expr ${date} / 10000 % 100`
@ year = `expr ${date} / 1000000 % 100`
@ longyear = `expr ${date} / 1000000`

## Tell you what date is being taken care of
echo "hour $hour day $day month $month year $year"

## Checks to take care of leading zeroes dropped from single-digit numbers
if ($hour == 0) then
  set hour = 00
endif

if ($hour == 6) then
  set hour = 06
endif

if ($day < 10) then
  set day = 0${day}
endif

if ($month < 10) then
  set month = 0${month}
endif

if ($year < 10) then
  set year = 0${year}
endif

## Actually getting the data...pick your poison!

## GFS analyses, 1.0 degree horizontal resolution
#wget -c http://nomads.ncdc.noaa.gov/data/gfs-avn-hi/${longyear}${month}/${longyear}${month}${day}/gfs_3_${longyear}${month}${day}_${hour}00_000.grb

#mv gfs_3_${longyear}${month}${day}_${hour}00_000.grb  1p0deg/GFS_${hour}_${year}${month}${day}_000

## GFS analyses, 0.5 degree horizontal resolution
wget -c http://nomads.ncdc.noaa.gov/data/gfs4/${longyear}${month}/${longyear}${month}${day}/gfs_4_${longyear}${month}${day}_${hour}00_000.grb2

mv gfs_4_${longyear}${month}${day}_${hour}00_000.grb2 0p5deg/GFS_${year}${month}${day}_${hour}_000

#endif

## Incrementing the time in the loop
if (`expr ${date} % 100` != 18) then
  set date = `expr ${date} + 6`
else
  set daydate = `expr ${date} / 100` ## extra 12 should be truncated
  set nextdate = `/home/kgriffin/swio/tomorrow.csh ${daydate}`
  set date = `expr ${nextdate} \* 100`
endif

end


exit(0)
