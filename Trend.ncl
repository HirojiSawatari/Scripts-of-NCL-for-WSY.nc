load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

;************************************************
; Specify geographical region and time span (year-month start and end
;************************************************

  latS     = -90               
  latN     =  90
  lonL     =   0
  lonR     = 360

  ymStrt   = 190001     
  ymLast   = 199912

  pltType  = "ps"  
  pltName  = "regress"

;************************************************
; Read from netCDF file: variable is type short...unpack
;************************************************
   f      = addfile("WSY.nc","r") 

   YYYYMM = cd_calendar( f->time, -1)

   iStrt  = ind(YYYYMM.eq.ymStrt)
   iLast  = ind(YYYYMM.eq.ymLast)

   x      = short2flt( f->TS(iStrt:iLast,{latS:latN},{lonL:lonR}) )

;   x      = x * (-86400000)

;  TIME   = f->time
;  YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
;  iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)

;  x    = f->TS(iYYYY,{latS:latN},{lonL:lonR})

;   x      = x-273.15
   x@units= "degC"

   printVarSummary(x)                            ; [time| 720]x[lat| 91]x[lon| 180]

   yyyymm = cd_calendar(x&time, -1)
   yyyy   = yyyymm/100

   dimx = dimsizes(x)
   ntim = dimx(0)                ; all years and months
   nlat = dimx(1)
   mlon = dimx(2)

   year  = ispan(yyyy(0), yyyy(ntim-1), 1)
   nyrs  = dimsizes(year)

;************************************************
; Areal averages: cos(lat) is good enough
;************************************************

   xann  = month_to_annual(x , 1)                 ; [year| 60]x[lat| 91]x[lon| 180]
   xann&year  = year

;   xann    = month_to_season (x, season)

   printVarSummary(xann)

;************************************************
; Calculate the regression coefficients (slopes)    
;************************************************
   rc           = regCoef(year,xann(lat|:,lon|:,year|:))            
; rc           = regCoef(year,xann(lat|:,lon|:,time|:))  

   rc@long_name = "Trend"
   rc@units     = xann@units+"/year"
   copy_VarCoords(xann(0,:,:), rc)                ; copy lat,lon coords

   printVarSummary(rc)

;************************************************
; for illustration: change units to degC/period-used
;************************************************
   rc           = rc*nyrs                       ; (C/year)*(nyrs)
   rc@units     = "degC/"+nyrs+"_year"
 

;************************************************
; plotting parameters 
;************************************************
   wks  = gsn_open_wks("png","regress_4")       ; specifies a ps plot
   gsn_define_colormap(wks,"BlRe")   
;   gsn_define_colormap(wks,"GMT_gebco")

   res                       = True     
   res@gsnMaximize           = True             ; make large
   res@gsnZonalMean               = True 

   res@cnFillOn              = True             ; turn on color
   res@cnLinesOn             = False            ; turn off contour lines
   res@cnLineLabelsOn        = False            ; turn off contour line labels
 ;;res@cnFillMode            = "RasterFill"

   res@cnLevelSelectionMode  = "ManualLevels"   ; set manual contour levels

;   res@cnMinLevelValF        =  -200.0            ; set min contour level
;   res@cnMaxLevelValF        =   200.0            ; set max contour level
;   res@cnLevelSpacingF       =   40.0            ; set contour interval

   res@cnMinLevelValF        =  -2.            ; set min contour level
   res@cnMaxLevelValF        =   2.            ; set max contour level
   res@cnLevelSpacingF       =   0.1            ; set contour interval
;   res@mpMinLatF            = 15.         ; zoom in on map
;   res@mpMaxLatF            = 55.
;   res@mpMinLonF            = 70.
 ;  res@mpMaxLonF            = 140.

   res@mpMinLatF            = -90.         ; zoom in on map
   res@mpMaxLatF            = 90.
   res@mpMinLonF            = 0.
   res@mpMaxLonF            = 360.

   res@mpCenterLonF         = 180.
   res@mpOutlineSpecifiers=(/"China"/)

   res@mpFillOn              = False            ; turn off default background gray
  ;res@mpCenterLonF          = 180

   res@gsnCenterString       = year(0)+"-"+year(nyrs-1) 
   
;  res@tiMainString          = "20th Century Reanalysis: sig995"    ; fili
   plot = gsn_csm_contour_map_ce(wks,rc,res)    


  end
