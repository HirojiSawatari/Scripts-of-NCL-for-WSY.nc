
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

  f = addfile("WSY.nc","w")
  ts = f->TS
  time = f->time
  lat = f->lat
  lon = f->lon
  ts!0 = "time"
  ts!1 = "lat"
  ts!2 = "lon"
  ts&time = time

  f2 = addfile("WSY_tsiS.nc","w")
  ts2 = f2->TS
  time2 = f2->time
  lat2 = f2->lat
  lon2 = f2->lon
  ts2!0 = "time2"
  ts2!1 = "lat2"
  ts2!2 = "lon2"
 
  year = new(2000,integer)

  do i=1,2000
     year(i-1) = i
  end do    

  do i=0,23999
     do n=0,47
        do m=0,95
           if((i+1) % 12 .eq. 0) then
              a = (i + 1) / 12 - 1
              ts(a,n,m) = sum(ts(i-11:i,n,m)) / 12
              ts2(a,n,m) = sum(ts2(i-11:i,n,m)) / 12
           end if
        end do
     end do
  end do

  k = 5
  do i=500,1994
     do n=0,47
        do m=0,95
           ts(i,n,m) = (sum(ts((i):(k+i-1),n,m)))/k
           ts2(i,n,m) = (sum(ts2((i):(k+i-1),n,m)))/k
        end do
     end do
  end do

  do n=0,47
     do m=0,95
        ts(0,n,m) = escorc(ts(649:799,n,m),ts2(649:799,n,m))
     end do
  end do

  wks  = gsn_open_wks("png","cut")       ; specifies a ps plot
   gsn_define_colormap(wks,"BlRe")

   res                       = True
   res@gsnMaximize           = True             ; make large
   res@gsnZonalMean               = True

   res@cnFillOn              = True             ; turn on color
   res@cnLinesOn             = False            ; turn off contour lines
   res@cnLineLabelsOn        = False            ; turn off contour line labels

   res@cnLevelSelectionMode  = "ManualLevels"   ; set manual contour levels

   res@cnMinLevelValF        =  -1            ; set min contour level
   res@cnMaxLevelValF        =  1             ; set max contour level
   res@cnLevelSpacingF       =  0.125             ; set contour interval
   res@mpMinLatF            = 15.  
   res@mpMaxLatF            = 55.
   res@mpMinLonF            = 70.
   res@mpMaxLonF            = 140.
   res@mpCenterLonF         = 180.
   res@mpOutlineSpecifiers=(/"Mongolia","China","Russia"/)

   plot = gsn_csm_contour_map_ce(wks,ts(0,:,:),res)
 
end

