probe_results<-fread("probe_results.csv")
hf_roll<-fread("huggingface_space_rolled.csv")
athena_data<-fread("athena_buildings.csv")
best<-fread("h2ogpte/malawi-cyclone-from-7810/sub_blend_nd2c.csv")
best<-fread("h2ogpte/malawi-cyclone-from-7810/60-20-20_yolo_039v2.csv")
allsubs<-fread("allsubs_20250102.csv")
allsubs[,actual:=NULL]

allsubs<-merge(allsubs,probe_results[,.(id=paste0(id_base,"_no_damage"),actual)],"id",all.x=TRUE)
allsubs<-merge(allsubs,hf_roll[,.(id,hf_post=post,hf_pre=pre,hf_max)],"id",all.x=TRUE)
allsubs<-merge(allsubs,best[,.(id,best=target)],"id",all.x=TRUE)
allsubs<-merge(allsubs,athena_data[,.(id=paste0(id,"_X_no_damage"),athena=building_count)],"id",all.x=TRUE)

just_probes<-allsubs[!is.na(actual)]
just_probes[,mimic:=(
  l11_1*0.3 + l11_2*0.3 + 
    pix_1*0.1 + pix_2*0.1 +
    q72_1*0.1 + q72_2*0.1
)]
just_probes[,overfit1:=(
  l11_1*0.3 + l11_2*0.3 + 
    (hf_max*0.9) * 0.2 +
    pix_3*0.1 + 
    q72_1*0.05 + q72_2*0.05
)]
just_probes[,overfit2:=(
  l11_1*0.25 + l11_2*0.25 + 
    (hf_max*0.9) * 0.2 + pDet*0.1 +
    pix_3*0.1 + 
    q72_1*0.05 + q72_2*0.05
)]
just_probes[,overfit3:=(
  l11_1*0.275 + l11_2*0.275 + 
    (hf_max*0.9) * 0.15 + pDet*0.05 +
    (athena*0.95)*0.05 + pix_3*0.1 + 
    q72_1*0.05 + q72_2*0.05
)]

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

just_probes<-allsubs[!is.na(actual)]



cols_to_check <- names(just_probes)[2:ncol(just_probes)]  # All columns except the first
cols_to_check <- c("l11_1","l11_2","hf_max","pDet","athena","pix_3","q72_1","q72_2")

# Create the comparison
too_high <- just_probes[, lapply(.SD, function(x) sum(x > actual + 5)), 
   .SDcols = cols_to_check]

too_low <- just_probes[, lapply(.SD, function(x) sum(x < actual - 5)), 
            .SDcols = cols_to_check]

rbind(too_high,too_low)




just_probes[,.(
  .N
  ,best=mean(abs(best-actual))
  ,mimic=mean(abs(mimic-actual))
  ,overfit1=mean(abs(overfit1-actual))
  ,overfit2=mean(abs(overfit2-actual))
  ,overfit3=mean(abs(overfit3-actual))
  
  ,l11_1=mean(abs(l11_1-actual))
  ,l11_2=mean(abs(l11_2-actual))
  ,l11_3b=mean(abs(l11_3b-actual))
  #,pix_1=mean(abs(pix_1-actual))
  #,pix_2=mean(abs(pix_2-actual))
  ,pix_3=mean(abs(pix_3-actual))
  ,q72_1=mean(abs(q72_1-actual))
  ,q72_2=mean(abs(q72_2-actual))
  #,q7_1=mean(abs(q7_1-actual))
  #,q7_3=mean(abs(q7_3-actual))
  #,l90_1=mean(abs(l90_1-actual))
  #,l90_2=mean(abs(l90_2-actual))
  #,l90_3=mean(abs(l90_3-actual))
  ,pDet=mean(abs(pDet-actual))
  ,athena=mean(abs(athena-actual))
  ,hf_post=mean(abs(hf_post-actual))
  ,hf_max=mean(abs(hf_max-actual))
  ,hf_avg=mean(abs((hf_post*0.5+hf_pre*0.5)-actual))
  ,hf_max90=mean(abs(hf_max*0.9-actual))
)]

best[1:2]

allsubs[,overfit1:=(
  l11_1*0.3 + l11_2*0.3 + 
    (hf_max*0.9) * 0.2 +
    pix_3*0.1 + 
    q72_1*0.05 + q72_2*0.05
)]

allsubs[,overfit2:=(
  l11_1*0.25 + l11_2*0.25 + 
    (hf_max*0.9) * 0.2 + pDet*0.1 +
    pix_3*0.1 + 
    q72_1*0.05 + q72_2*0.05
)]

allsubs[,overfit3:=(
  0.25 * l11_1 + 
  0.25 * l11_2 + 
  0.20 * (hf_max*0.9) + 
  0.10 * pDet +
  0.02 * (athena*0.9) + 
  0.10 * pix_3 + 
  0.04 * q72_1 + 
  0.04 * q72_2
)]

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

getwd()
# HuggingFace processing: exports CSV
#library(jsonlite)
#l<-list()
#json_pre_dir<-"hf-space-preds/hf-space-full-output/pre-missing-4/"
#for(f in list.files(json_pre_dir)){
#  j<-read_json(paste0(json_pre_dir,f))
#  annotations<-j$annotations
#  detections<-length(annotations)
#  l[[length(l)+1]]<-data.table(set="pre",file=f,detections=detections)
#}
#json_post_dir<-"hf-space-preds/hf-space-full-output/post-missing-4/"
#for(f in list.files(json_post_dir)){
#  j<-read_json(paste0(json_post_dir,f))
#  annotations<-j$annotations
#  detections<-length(annotations)
#  l[[length(l)+1]]<-data.table(set="post",file=f,detections=detections)
#}
#dt<-rbindlist(l)
#dt[,id:=paste0(substr(file,1,nchar("malawi-cyclone_00000000")),"_X_no_damage")]
#dt[,detections:=as.integer(detections)]
#hf_roll<-dcast(dt,id~set,value.var = "detections",fun.aggregate = max)
#hf_roll[is.na(pre),pre:=post]
#hf_roll[is.na(post),post:=pre]
#hf_roll[,`:=`(hf_max=pmax(post,pre),hf_diff=abs(post-pre))]
#fwrite(hf_roll,"huggingface_space_rolled.csv")
#hf_roll[order(-hf_diff)][1:10]

