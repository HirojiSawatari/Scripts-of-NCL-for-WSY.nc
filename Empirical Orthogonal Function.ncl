
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

  f = addfile("WSY.nc","w")
  f1 = addfile("WSY_tsiS.nc","w")
  ts = f->PRECT
  ts1 = f1->PRECT
  time = f->time
  lat = f->lat
  lon = f->lon
  ts!0 = "time"
  ts!1 = "lat"
  ts!2 = "lon"
  ts&time = time
 
  year = new(2000,integer)

  do i=1,2000
     year(i-1) = i
  end do    

  do i=0,23999
;  do i=0,17999
     do n=0,47
        do m=0,95
           if((i+1) % 12 .eq. 0) then
              a = (i + 1) / 12 - 1
              ts(a,n,m) = (sum(ts(i-11:i,n,m)) / 12)
           end if
        end do
     end do
  end do

  do i=0,23999
     do n=0,47
        do m=0,95
           if((i+1) % 12 .eq. 0) then
              a = (i + 1) / 12 - 1
              ts1(a,n,m) = (sum(ts1(i-11:i,n,m)) / 12)
           end if
        end do
     end do
  end do

  k = 11
  do i=500,1988
     do n=0,47
        do m=0,95
           ts(i,n,m) = (sum(ts((i):(k+i-1),n,m)))/k
           ts1(i,n,m) = (sum(ts1((i):(k+i-1),n,m)))/k
        end do
     end do
  end do

  latS   =  -40.
  latN   =  60.
  lonL   =  0.
  lonR   =  360.

;  latS   =  16.
;  latN   =  43.
;  lonL   =  97.
;  lonR   =  132.

;  latS   =  35.
;  latN   =  54.
;  lonL   =  86.
;  lonR   =  124.

  iStrt  =  500
  iLast  =  1989

  neof   = 1        ; number of EOFs      
  optEOF = True
  
  optETS = False

  x2      = ts(iStrt:iLast,{latS:latN},{lonL:lonR})
  x2      = x2 * 86400000

  y2      = ts1(iStrt:iLast,{latS:latN},{lonL:lonR})
  y2      = y2 * 86400000
     
  x      = x2({lat|latS:latN},{lon|lonL:lonR},time|:)
  y      = y2({lat|latS:latN},{lon|lonL:lonR},time|:)  

  eof    = eofunc_Wrap(x, neof, optEOF)
  eof2    = eofunc_Wrap(y, neof, optEOF)
  eof_ts = eofunc_ts_Wrap (x, eof, optETS)
  eof2_ts = eofunc_ts_Wrap (y, eof, optETS)

;  eof = -eof
;  eof2 = -eof2
;  eof_ts = -eof_ts
;  eof2_ts = -eof2_ts

;  eof(1,:,:) = -eof(1,:,:)
;  eof2(1,:,:) = -eof2(1,:,:)
;  eof_ts(1,:) = -eof_ts(1,:)
;  eof2_ts(1,:) = -eof2_ts(1,:)

  wks = gsn_open_wks("png","eof4all")
  gsn_define_colormap(wks,"BlWhRe")       ; choose colormap
  plot = new(neof,graphic)                ; create graphic array
                                          ; only needed if paneling
; EOF patterns

  res                      = True
  res@gsnDraw              = False        ; don't draw yet
  res@gsnFrame             = False        ; don't advance frame yet

;---This resource not needed in V6.1.0
  res@gsnSpreadColors      = True         ; spread out color table

  res@gsnAddCyclic         = False        ; plotted dataa are not cyclic

  res@mpFillOn             = False        ; turn off map fill
;  res@mpMinLatF            = 37.8         ; zoom in on map
;  res@mpMaxLatF            = 53.
;  res@mpMinLonF            = 87.7
;  res@mpMaxLonF            = 122.2

  res@mpMinLatF            = -40.         ; zoom in on map
  res@mpMaxLatF            = 60.
  res@mpMinLonF            = 0.
  res@mpMaxLonF            = 360.

  res@mpOutlineSpecifiers=(/"Mongolia","China","Russia"/)

  res@cnFillOn             = True         ; turn on color fill
  res@cnLinesOn            = False        ; True is default
 ;res@cnLineLabelsOn       = False        ; True is default
  res@lbLabelBarOn         = False        ; turn off individual lb's

                                          ; set symmetric plot min/max
  symMinMaxPlt(eof, 16, False, res)       ; contributed.ncl

; panel plot only resources
  resP                     = True         ; modify the panel plot
  resP@gsnMaximize         = True         ; large format
  resP@gsnPanelLabelBar    = True         ; add common colorbar
  resP@lbLabelAutoStride   = True         ; auto stride on labels

  do n=0,neof-1
     res@gsnLeftString  = "EOF "+(n+1)
     res@gsnRightString = sprintf("%5.1f", eof@pcvar(n)) +"%"
     plot(n)=gsn_csm_contour_map_ce(wks,eof(n,:,:),res)
  end do
  gsn_panel(wks,plot,(/neof,1/),resP)     ; now draw as one plot


  rts           = True
  rts@gsnDraw   = False       ; don't draw yet
  rts@gsnFrame  = False       ; don't advance frame yet
  rts@gsnScale  = True        ; force text scaling

; these four rtsources allow the user to stretch the plot size, and
; decide exactly where on the page to draw it.

  rts@vpHeightF = 0.40        ; Changes the aspect ratio
  rts@vpWidthF  = 0.85
  rts@vpXF      = 0.10        ; change start locations
  rts@vpYF      = 0.75        ; the plot


  rts@tiYAxisString = "Pa"                    ; y-axis label

  rts@gsnYRefLine           = 0.              ; reference line
  rts@gsnXYBarChart         = True            ; create bar chart
  rts@gsnAboveYRefLineColor = "red"           ; above ref line fill red
  rts@gsnBelowYRefLineColor = "blue"          ; below ref line fill blue

; panel plot only resources
  rtsP                      = True            ; modify the panel plot
  rtsP@gsnMaximize          = True            ; large format
;  rtsP@txString             = "SLP: "+season+": "+yStrt+"-"+yLast

;  year = yyyymm/100

; create individual plots
  do n=0,neof-1
     rts@gsnLeftString  = "EOF "+(n+1)
     rts@gsnRightString = sprintf("%5.1f", eof@pcvar(n)) +"%"
     plot(n) = gsn_csm_xy (wks,year,eof_ts(n,:),rts)
  end do
  gsn_panel(wks,plot,(/neof,1/),rtsP)

  

  r               = True                        ; plot mods desired
  r@gsnDraw       = False                       ; do not draw
  r@gsnFrame      = False
  sdof = specx_anal(eof_ts(1,:),0,0,0.1)
  printVarSummary(sdof)
  splt = specx_ci(sdof,0.05,0.95)
  r@trXMinF=2
  r@trXMaxF=20
  r@trYMinF=0
  r@trYMaxF=50
  r@tmXBMode="Explicit"
  r@tmXBValues=(/2,4,8,16/)
  r@tmXBLabels=(/"2","4","8","16"/)
  r@xyLineColors = (/"foreground","white","white","red"/)

  rP                      = True            ; modify the panel plot
  rP@gsnMaximize          = True

  plot = gsn_csm_xy(wks,1/sdof@frq, splt,r)
  gsn_panel(wks,plot,(/1,1/),rP)



  ra1 = pattern_cor(eof2(0,:,:), eof(0,:,:), 1.0, 0)
  print(ra1)

  ra2 = pattern_cor(eof2(1,:,:), eof(1,:,:), 1.0, 0)
  print(ra2)

  ra3 = pattern_cor(eof2(2,:,:), eof(2,:,:), 1.0, 0)
  print(ra3)

  r1 = escorc(eof_ts(0,:),eof2_ts(0,:))
  print(r1)

  r2 = escorc(eof_ts(1,:),eof2_ts(1,:))
  print(r2)

  r3 = escorc(eof_ts(2,:),eof2_ts(2,:))
  print(r3)

end

