
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

  f = addfile("WSY_tsiS.nc","w")
  ts = f->PRECT
  time = f->time
  lat = f->lat
  lon = f->lon
  ts!0 = "time"
  ts!1 = "lat"
  ts!2 = "lon"
  ts&time = time
  ts&lat = lat
 
  year = new(2000,integer)

  do i=1,2000
     year(i-1) = i
  end do    

  do i=0,23999
     do n=0,47
        do m=0,95
           if((i+1) % 12 .eq. 0) then
              a = (i + 1) / 12 - 1
              ts(a,n,m) = sum(ts(i-11:i,n,m)) / 12 * (-86400000)
           end if
        end do
     end do
  end do

  k = 5
  do i=500,1994
     do n=0,47
        do m=0,95
           ts(i,n,m) = (sum(ts((i):(k+i-1),n,m)))/k
        end do
     end do
  end do

  do n=0,47
     do m=0,95
        ts(0,n,m) = avg(ts(1199:1248,n,m)) - avg(ts(1149:1298,n,m))
     end do
  end do

  wks  = gsn_open_wks("png","a-b_tsi")       ; specifies a ps plot
   gsn_define_colormap(wks,"BlRe")

   res                       = True
   res@gsnMaximize           = True             ; make large
   res@gsnZonalMean               = True

   res@cnFillOn              = True             ; turn on color
   res@cnLinesOn             = False            ; turn off contour lines
   res@cnLineLabelsOn        = False            ; turn off contour line labels

   res@cnLevelSelectionMode  = "ManualLevels"   ; set manual contour levels

   res@cnMinLevelValF        =  -0.1          ; set min contour level
   res@cnMaxLevelValF        =  0.1             ; set max contour level
   res@cnLevelSpacingF       =  0.01             ; set contour interval
   res@mpMinLatF            = 37.8  
   res@mpMaxLatF            = 53.
   res@mpMinLonF            = 87.7
   res@mpMaxLonF            = 122.2
   res@mpCenterLonF         = 180.
   res@mpOutlineSpecifiers=(/"Mongolia","China","Russia"/)

   plot = gsn_csm_contour_map_ce(wks,ts(0,:,:),res)
   
   
   do n=0,47
      ts(0,n,0) = avg(ts(0,n,{70:140}))
   end do
  

   wks2   = gsn_open_wks ("png","xyplot")                ; send graphics to PNG file

   res2                   = True                     ; plot mods desired
   res2@tiMainString      = "Scatter Plot"           ; add title
   res2@xyMarkLineModes   = "Markers"                ; choose which have markers
   res2@trXMinF = 15
   res2@trXMaxF = 55
   res2@trYMinF = 0.3
   res2@trYMaxF = 1.8
   res2@xyMarkers         =  16                      ; choose type of marker  
   res2@xyMarkerColor     = "red"                    ; Marker color
   res2@xyMarkerSizeF     = 0.01                     ; Marker size (default 0.01)

   res2@tmLabelAutoStride = True                     ; nice tick mark labels
   plot2  = gsn_csm_xy (wks2,lat({15:55}),ts(0,{15:55},0),res2) ; create plot
   

   wks3 = gsn_open_wks ("png","reglineplot")
   res3 = True
   
   res3@trXMinF = 15
   res3@trXMaxF = 55
   res3@trYMinF = 0.3
   res3@trYMaxF = 1.8

;   print(lat(28:38))
;   print(ts(0,28:38,0))

   regl = new(48,double)
   regl(28:38) = regline(lat(28:38),ts(0,28:38,0))
   regl = regl*lat + regl@yintercept
   plot = gsn_csm_xy(wks3,lat(28:38),regl(28:38),res3)

end

