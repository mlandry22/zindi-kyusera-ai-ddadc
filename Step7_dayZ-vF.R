hf_roll<-fread("huggingface_space_rolled.csv")
athena_data<-fread("athena_buildings.csv")
allsubs<-fread("allsubs_20250102.csv")
allsubs[,actual:=NULL]
allsubs<-merge(allsubs,hf_roll[,.(id,hf_post=post,hf_pre=pre,hf_max)],"id",all.x=TRUE)
allsubs<-merge(allsubs,athena_data[,.(id=paste0(id,"_X_no_damage"),athena=building_count)],"id",all.x=TRUE)

allsubs[,`:=`(
  xl11_1 = l11_1
  ,xl11_2 = l11_2
  ,xhf_max = hf_max
  ,xpDet = pDet
  ,xathena = athena
  ,xpix_3 = pix_3
  ,xq72_1 = q72_1
  ,xq72_2 = q72_2
  ,theMax = pmax(l11_1,l11_2,hf_max,pDet,athena,pix_3,q72_1,q72_2)
  ,theMin = pmin(l11_1,l11_2,hf_max,pDet,athena,pix_3,q72_1,q72_2)
  ,ensemble1 = l11_1*0.275 + l11_2*0.275 + 
    (hf_max*0.9) * 0.15 + pDet*0.05 +
    (athena*0.95)*0.05 + pix_3*0.1 + 
    q72_1*0.05 + q72_2*0.05
)]
allsubs[,second_highest:=pmax(
  ifelse(l11_1==theMax,ensemble1,l11_1)
  ,ifelse(l11_2==theMax,ensemble1,l11_2)
  ,ifelse(hf_max==theMax,ensemble1,hf_max)
  ,ifelse(pDet==theMax,ensemble1,pDet)
  ,ifelse(athena==theMax,ensemble1,athena)
  ,ifelse(pix_3==theMax,ensemble1,pix_3)
  ,ifelse(q72_1==theMax,ensemble1,q72_1)
  ,ifelse(q72_2==theMax,ensemble1,q72_2)
)]
allsubs[,second_lowest:=pmin(
  ifelse(l11_1==theMin,ensemble1,l11_1)
  ,ifelse(l11_2==theMin,ensemble1,l11_2)
  ,ifelse(hf_max==theMin,ensemble1,hf_max)
  ,ifelse(pDet==theMin,ensemble1,pDet)
  ,ifelse(athena==theMin,ensemble1,athena)
  ,ifelse(pix_3==theMin,ensemble1,pix_3)
  ,ifelse(q72_1==theMin,ensemble1,q72_1)
  ,ifelse(q72_2==theMin,ensemble1,q72_2)
)]

allsubs[!is.na(ensemble1)][1:2]

allsubs[l11_1>(second_highest*1.2),xl11_1:=round(second_highest)]
allsubs[l11_2>(second_highest*1.2),xl11_2:=round(second_highest)]
allsubs[hf_max>(second_highest*1.2),xhf_max:=round(second_highest)]
allsubs[pDet>(second_highest*1.2),xpDet:=round(second_highest)]
allsubs[athena>(second_highest*1.2),xathena:=round(second_highest)]
allsubs[pix_3>(second_highest*1.2),xpix_3:=round(second_highest)]
allsubs[q72_1>(second_highest*1.2),xq72_1:=round(second_highest)]
allsubs[q72_2>(second_highest*1.2),xq72_2:=round(second_highest)]

allsubs[l11_1<(second_lowest*0.8),xl11_1:=round(second_lowest)]
allsubs[l11_2<(second_lowest*0.8),xl11_2:=round(second_lowest)]
allsubs[hf_max<(second_lowest*0.8),xhf_max:=round(second_lowest)]
allsubs[pDet<(second_lowest*0.8),xpDet:=round(second_lowest)]
allsubs[athena<(second_lowest*0.8),xathena:=round(second_lowest)]
allsubs[pix_3<(second_lowest*0.8),xpix_3:=round(second_lowest)]
allsubs[q72_1<(second_lowest*0.8),xq72_1:=round(second_lowest)]
allsubs[q72_2<(second_lowest*0.8),xq72_2:=round(second_lowest)]

allsubs[,overfitF:=(
  0.25 * xl11_1 + 
    0.25 * xl11_2 + 
    0.20 * (xhf_max*0.9) + 
    0.10 * xpDet +
    0.02 * (xathena*0.9) + 
    0.10 * xpix_3 + 
    0.04 * xq72_1 + 
    0.04 * xq72_2
)]


allsubs[1:5]
allsubs[gsub("no_damage","",id)==id,.N,is.na(overfit3)]
fwrite(allsubs[,.(id,target=ifelse(is.na(overfitF),0,overfitF))],"final_v8.csv")
