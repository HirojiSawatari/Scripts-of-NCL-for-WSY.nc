load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin
  
  f = addfile("WSY.nc","r")
  f1 = addfile("WSY_tsiS.nc","r")
  f2 = addfile("WSY_ghg.nc","r")
  f3 = addfile("WSY_vol.nc","r")
  f4 = addfile("WSY_lucc.nc","r")

  ts = f->TS
  ts1 = f1->TS
  ts2 = f2->TS
  ts3 = f3->TS
  ts4 = f4->TS

  pre = f->TS
  time = f->time
  time2 = f3->time
  time3 = f2->time
  lat = f->lat
  lon = f->lon
  ts!0 = "time"
  ts!1 = "lat"
  ts!2 = "lon"
  pre!0 = "time"
  pre!1 = "lat"
  pre!2 = "lon"
  ts&time = time
  pre&time = time

;  ts&lat@units = "degree_north"
;  ts&lon@units = "degree_east"

;  latS   =  37.8
;  latN   =  53.
;  lonL   =  87.7
;  lonR   =  122.2

;  latS = 15.
;  latN = 55.
;  lonL = 70.
;  lonR = 140.

  latS = 0.
  latN = 90.
  lonL = 0.
  lonR = 360.

  dimTime = dimsizes(time)
  dimTime2 = dimsizes(time2)
  dimTime3 = dimsizes(time3)

  tsF = new(dimTime,float)
  tsF1 = new(dimTime,float)
  tsF2 = new(dimTime3,float)
  tsF3 = new(dimTime2,float)
  tsF4 = new(dimTime,float)

  preF = new(dimTime,float) 

  tsF = wgt_areaave_Wrap(ts(:,{latS:latN},{lonL:lonR}),1 , 1., 0)
;  tsF1 = wgt_areaave_Wrap(ts1(:,{latS:latN},{lonL:lonR}),1 , 1., 0)
;  tsF2 = wgt_areaave_Wrap(ts2(:,{latS:latN},{lonL:lonR}),1 , 1., 0)
  tsF3 = wgt_areaave_Wrap(ts3(:,{latS:latN},{lonL:lonR}), 1, 1., 0)
;  tsF4 = wgt_areaave_Wrap(ts4(:,{latS:latN},{lonL:lonR}), 1, 1., 0)

  yF = new(2000,float)
  yF1 = new(2000,float)
  yF2 = new(2000,float)
  yF3 = new(2000,float)
  yF4 = new(2000,float)

;  pyF = new(2000,float)
  year = new(2000,integer)

  a = 0
;  a = 499
  yts = 0.
  yts1 = 0.
  yts2 = 0.
  yts3 = 0.
  yts4 = 0.

;  ypre = 0.
  do i=0,23999
     yts = yts + tsF(i)
;     yts1 = yts1 + tsF1(i)
;     yts2 = yts2 + tsF2(i)
;     yts4 = yts4 + tsF4(i)
;     ypre = ypre + preF(i) 
     if((i + 1) % 12 .eq. 0) then
        yF(a) = yts / 12. - 272.15
;        yF1(a) = yts1 / 12. - 272.15
;        yF2(a) = yts2 / 12. - 272.15
;        yF4(a) = yts4 / 12. - 272.15
;        pyF(a) = ypre / 12.
        year(a) = a + 1
        yts = 0.
;        yts1 = 0.
;        yts2 = 0.
;        yts4 = 0.
;        ypre = 0.
        a = a + 1
     end if
  end do

  a = 500
  do i=0,17999
    yts3 = yts3 + tsF3(i)
    if((i + 1) % 12 .eq. 0) then
        yF3(a) = yts3 / 12. - 272.15
        yts3 = 0.
        a = a + 1
     end if
  end do

  dF = new(200,float)
;  pdF = new(200,float)
  decade = new(200,integer)
  a = 0
  dts = 0.
;  dpre = 0.
;  do i=50,199
  do i=0,1498
     dts = dts + yF(i)
;     dpre = dpre + pyF(i)
     if((i + 1) % 10 .eq. 0) then
        dF(a) = dts / 10.
;        pdF(a) = dpre / 10.
        decade(a) =  (a * 10)
        dts = 0.
;        dpre = 0.
        a = a + 1
     end if
  end do

  pa = avg(yF(1849:1999))
;  pa1 = avg(yF1(1849:1948))
;  pa2 = avg(yF2(1849:1948))
  pa3 = avg(yF3(1849:1999))
;  pa4 = avg(yF4(1849:1948))

;  print(pa-273.15)

;  ta = avg(pyF)
  do i=0,1999
;     pyF(i) = pyF(i) - ta
     yF(i) = yF(i) - pa
;     yF1(i) = yF1(i) - pa1
;     yF2(i) = yF2(i) - pa2
     yF3(i) = yF3(i) - pa3
;     yF4(i) = yF4(i) - pa4
  end do 

  wks = gsn_open_wks("png","tab")

  res = True
  res@gsnScale = True
  res@gsnMaximize = True
  res@vpHeightF = 0.43
  res@vpWidthF = 0.85

  res@tiYAxisString = ""

;--------bar chart------
;  res@tiMainString = "Surface Tempreture"
;  res@gsnXYBarChart = True

;  plot = gsn_csm_xy(wks,time(20:70),ts(20:70,20,20),res)
 
;--------line chart-----
;  res@tiMainString = "Five Secondary Smoothing"
  res@gsnXYBarChartOutlineOnly = True
  res@xyLineThicknesses = (/1.0,2.0,3.0/)
  res@xyLineColors = (/"red","black","green","blue","brown"/)
  res@xyDashPatterns    = (/0.0,0.0,0.0,0.0,0.0/) 
  res@tiXAxisString = "Year"
  res@tiYAxisString = "Slip Statistics"

  res@pmLegendDisplayMode    = "Always"   ; Display a legend.
  res@xyExplicitLegendLabels = (/"ALL","Tsi","GHGs","Vol","LUCC"/)
  res@pmLegendWidthF         = 0.10       ; Make it smaller
  res@pmLegendHeightF        = 0.10        ; Make it smaller

  res@trXMinF = 0
  res@trXMaxF = 2000
;  res@trYMinF = -0.8
;  res@trYMaxF = 0.5

;*  res@vpHeightF = 0.23        ; Changes the aspect ratio
;*  res@vpWidthF  = 1.

;  res@pmLegendOrthogonalPosF = -1.2      ; Move into to plot
;  res@pmLegendParallelPosF   = 0.75      ; Move to right
;  res@lgPerimOn              = False      ; No legend perimeter.
;  res@lgLabelFontHeightF     = 0.015

;  res@vpHeightF = 0.23        ; Changes the aspect ratio
;  res@vpWidthF  = 1.
;  res@trYMaxF = 0.4
;  res@trYMinF = -0.4
;  res@tiYAxisString = "Surface Tempreture(¡æ)"

;  plot = gsn_csm_xy(wks,year(::1),tsF(::1),res)

;----------------regression equation--------------
;  dimYear = 201 
;  bb = (sum(yF*year)-(1./dimYear)*sum(yF)*sum(year))/(sum(year*year)-(1./dimYear)*sum(year)*sum(year))
;  aa = avg(yF)-bb*avg(year)

;  data = new((/2,201/),float)
;  data(0,:) = yF(:)
;  data(1,:) = aa+bb*year(:)
;  plot(0) = gsn_csm_xy(wks,year,data,res)
;--------------------------------------------------
 
;------------------moving average-------------------
  k = 11
  slo = new(1988,float)
  slo1 = new(1988,float)
  slo2 = new(1988,float)
  slo3 = new(1988,float)
  slo4 = new(1988,float)
;  pslo = new(1990,float)
  do i=0,1987
;     slo(i) = (sum(yF((i):(k+i-1))))/k * 86400000 * 365
     slo(i) = (sum(yF((i):(k+i-1))))/k
     slo1(i) = (sum(yF1((i):(k+i-1))))/k
     slo2(i) = (sum(yF2((i):(k+i-1))))/k
     slo3(i) = (sum(yF3((i):(k+i-1))))/k
     slo4(i) = (sum(yF4((i):(k+i-1))))/k
;     pslo(i) = (sum(pyF((i):(k+i-1))))/31
  end do
 
  sdof = specx_anal(yF(1199:1249),0,0,0.1)
  printVarSummary(sdof)
  splt = specx_ci(sdof,0.05,0.95)

  r               = True                        ; plot mods desired
  r@gsnDraw       = False                       ; do not draw
  r@gsnFrame      = False
  r@tiMainString="Global Precipitation (801-1250)"		           ; title
  r@tiXAxisString="Cycle (years)"  ; xaxis
  r@tiYAxisString="Variance"                  ; yaxis
  r@gsnCenterString="(no running)"
  r@trXMinF=0
  r@trXMaxF=50
  r@tmXBMode="Explicit"
  r@tmXBValues=(/1,2,4,8,16,32/)
  r@tmXBLabels=(/"1","2","4","8","16","32"/)
  r@xyLineColors = (/"foreground","green","blue","red"/)

  rP                      = True            ; modify the panel plot
  rP@gsnMaximize          = True

;  plot = gsn_csm_xy(wks,1/sdof@frq, splt,r)
;  gsn_panel(wks,plot,(/1,1/),rP)

  plot = gsn_csm_xy(wks,year(649:799),sloall(649:799),res)

  printVarSummary(slo)

  data = new((/5,150/),float)
  data(0,:) = slo(649:798)
  data(1,:) = slo1(649:798)
  data(2,:) = slo2(649:798)
  data(3,:) = slo3(649:798)
  data(4,:) = slo4(649:798)
         
;  plot = gsn_csm_xy(wks,year(649:798),data,res)

  plot = gsn_csm_xy(wks,year(0:1987),slo(0:1987),res)

;---------------------------------------------------

;-------------------cumulative departure------------
;  dep = new(15,float)
;  do i=0,14
;     dep(i) = sum(dF(0:i))-avg(dF)*(i+1)
;  end do
 
;  data = new((/2,15/),float)
;  data(0,:) = dep(:)
;  data(1,:) = 0.

;  plot = gsn_csm_xy(wks,decade,data,res)

;  gsn_panel(wks,plot,(/1,2/),False)

;--------------nine secondary smoothing-----------
;  smo = new(151,float)
;  psmo = new(200,float)
;  do i=1199,1349
;    smo(i-1199) = (-21*slo(i)+14*slo(i+1)+39*slo(i+2)+54*slo(i+3)+59*slo(i+4)+54*slo(i+5)+39*slo(i+6)+14*slo(i+7)-21*slo(i+8))/231
;    psmo(i) = (-21*pdF(i)+14*pdF(i+1)+39*pdF(i+2)+54*pdF(i+3)+59*pdF(i+4)+54*pdF(i+5)+39*pdF(i+6)+14*pdF(i+7)-21*pdF(i+8))/231
;    smo(i) = (-3*dF(i)+13*dF(i+1)+17*dF(i+2)+12*dF(i+3)-3*dF(i+4))/35
;  end do

;  data = new((/2,151/),float)
;  data(0,:) = slo(1199:1349)
;  data(1,:) = smo(:)
  
;  res@trYMaxF = 15.
;  res@trYMinF = 13.6
;  res@trXMaxF = 1260
;  res@trXMinF = 1220
  
;  plot = gsn_csm_xy(wks,year(1199:1349),data,res)
;--------------------------------------------------

;----------------sliding t-test---------------------
  sli = new(2000,float)

  regl = new(2000,float) 

  do i=100,1899
     s = sqrt((100.*variance(yF(i+1:i+100))+100.*variance(yF(i-100:i-1)))/98.)
     sli(i) = (avg(yF(i+1:i+100))-avg(yF(i-100:i-1)))/(s*sqrt(0.02))
  end do

;  data = new((/3,2000/),float)
;  data(0,:) = sli(:) 
;  data(1,:) = 2.898
;  data(2,:) = -2.898
  
  regl(649:798) = regline(year(649:798),slo(649:798))
 
  regl = regl*year + regl@yintercept

  print(regl(649:798))

  plot = gsn_csm_xy(wks,year(649:798),regl(649:798),res)

  resL = True
                                                                                                                                                                                                                                                                                                              resL@trYMaxF = 1.
  resL@trYMinF = -1.
  resL@xyLineColors = "red"
;  resL@vpHeightF = 0.43
;  resL@vpWidthF = 0.85
  resL@tiXAxisString = "Year"
;  resL@tiYAxisString = "Surface temperature(mm/day)"

  resR = True
  resR@trYMaxF = 1.
  resR@trYMinF = -1.
  resR@xyLineColors = "blue"
  resL@vpHeightF = 0.43
  resL@vpWidthF = 0.85

;  plot = gsn_csm_xy2(wks,year(0:1969),slo2(0:1969),slot(0:1969),resL,resR)
  m1 = sum(slo(1264:1353)*slo1(1264:1353))
  n1 = sqrt(sum(slo(1264:1353)*slo(1264:1353)))*sqrt(sum(slo1(1264:1353)*slo1(1264:1353)))
  r1 = m1 / n1
  print(r1)

  m3 = sum(slo(1264:1353)*slo3(1264:1353))
  n3 = sqrt(sum(slo(1264:1353)*slo(1264:1353)))*sqrt(sum(slo3(1264:1353)*slo3(1264:1353)))
  r3 = m3 / n3
  print(r3)

  m2 = sum(slo(1264:1353)*slo2(1264:1353))
  n2 = sqrt(sum(slo(1264:1353)*slo(1264:1353)))*sqrt(sum(slo2(1264:1353)*slo2(1264:1353)))
  r2 = m2 / n2
  print(r2)

  m4 = sum(slo(1264:1353)*slo4(1264:1353))
  n4 = sqrt(sum(slo(1264:1353)*slo(1264:1353)))*sqrt(sum(slo4(1264:1353)*slo4(1264:1353)))
  r4 = m4 / n4
  print(r4)

  tsi = escorc(slo(649:798),slo1(649:798))
  print(tsi)

  ghg = escorc(slo(649:798),slo2(649:798))
  print(ghg)

  vol = escorc(slo(649:798),slo3(649:798))
  print(vol)

  lucc = escorc(slo(649:798),slo4(649:798))
  print(lucc)

  yF33 = new(1500,float)
  yF33(0:1499) = yF3(500:1999)

  out = addfile("yFTS_ctrl.nc","c")
  yF!0 = "year"
  yF&year = ispan(1,2000,1)
  yF@long_name="surface temperature"
  yF@units="centigrade"
  out->ts = yF


end
