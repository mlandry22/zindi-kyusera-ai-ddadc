# HuggingFace processing: exports CSV
library(data.table)
library(jsonlite)
l<-list()
json_pre_dir<-"hf-space-preds/hf-space-full-output/pre-missing-4/"
for(f in list.files(json_pre_dir)){
  j<-read_json(paste0(json_pre_dir,f))
  annotations<-j$annotations
  detections<-length(annotations)
  l[[length(l)+1]]<-data.table(set="pre",file=f,detections=detections)
}
json_post_dir<-"hf-space-preds/hf-space-full-output/post-missing-4/"
for(f in list.files(json_post_dir)){
  j<-read_json(paste0(json_post_dir,f))
  annotations<-j$annotations
  detections<-length(annotations)
  l[[length(l)+1]]<-data.table(set="post",file=f,detections=detections)
}
dt<-rbindlist(l)
dt[,id:=paste0(substr(file,1,nchar("malawi-cyclone_00000000")),"_X_no_damage")]
dt[,detections:=as.integer(detections)]
hf_roll<-dcast(dt,id~set,value.var = "detections",fun.aggregate = max)
hf_roll[is.na(pre),pre:=post]
hf_roll[is.na(post),post:=pre]
hf_roll[,`:=`(hf_max=pmax(post,pre),hf_diff=abs(post-pre))]
fwrite(hf_roll,"huggingface_space_rolled.csv")
