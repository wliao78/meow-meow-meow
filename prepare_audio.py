"""12 independent source recordings for owner-cat entertainment interaction.
Only trim, mono/resampling, modest peak normalization and edge fades.
No repeats, concatenation, pitch/speed changes; never infer cat semantics.
Run /usr/bin/python3, using bundled audioop.
"""
from pathlib import Path
import wave,audioop,array,math,json,hashlib
root=Path(__file__).parent
labels=['过来','吃饭啦','喝水啦','陪我玩','抱抱','摸摸头','我爱你','想你了','真乖','别闹啦','起床啦','晚安']
authors={'200336':'jsbarrett','451250':'dreamstobecome','110011':'tuberatanka','333916':'lextrack','732520':'Lukey1028','412016':'skymary','528193':'fthgurdy','362652':'TRNGLE','345039':'kentspublicdomain'}
context={'200336':'作者记录自家猫发出颤音，未声称情绪','451250':'作者明确猫舒服地坐在膝上，满足地轻啾','110011':'作者描述饥饿猫的单喵','333916':'作者描述猫叫，标签cute，未声称情绪','732520':'作者描述一岁猫的单喵','412016':'作者描述呼噜转猫叫，未声称情绪','528193':'作者描述猫的短叫，未声称情绪','362652':'作者描述猫的短叫，未声称情绪','345039':'作者描述家猫开心/舒服的呼噜'}
entries=[('200336',0,3.2),('F_BAC01_MC_MN_SIM01_101.wav',0,None),('110011',0,None),('732520',0,None),('451250',0,3.2),('F_BRA01_MC_MN_SIM01_302.wav',0,None),('412016',0,None),('F_BRI01_MC_FI_SIM01_201.wav',0,None),('362652',0,None),('333916',0,None),('528193',0,None),('345039',7,9.6)]
clips=[]
for i,(sid,start,end) in enumerate(entries):
 dataset=sid.endswith('.wav')
 p=root/'Research'/('CatMeows/'+sid if dataset else 'Decoded/'+sid+'.wav')
 with wave.open(str(p),'rb') as f:
  rate=f.getframerate();assert f.getnchannels()==1 and f.getsampwidth()==2
  raw=f.readframes(f.getnframes());end=len(raw)/(rate*2) if end is None else end
 pcm=raw[round(start*rate)*2:round(end*rate)*2]
 assert len(pcm)>400 and audioop.max(pcm,2)>0
 sourcepeak=audioop.max(pcm,2);gain=(32767*10**(-12/20))/sourcepeak
 pcm=audioop.mul(pcm,2,gain)
 if rate!=44100:pcm,_=audioop.ratecv(pcm,2,1,rate,44100,None)
 a=array.array('h',pcm);fade=441
 for j in range(min(fade,len(a)//2)):
  a[j]=round(a[j]*j/fade);a[-1-j]=round(a[-1-j]*j/fade)
 pcm=a.tobytes();out=root/'MeowPaw/Audio'/('cat-%d.wav'%(i+1))
 with wave.open(str(out),'wb') as f:f.setnchannels(1);f.setsampwidth(2);f.setframerate(44100);f.writeframes(pcm)
 original=root/'Research'/('CatMeows/'+sid if dataset else (('InteractionCC0/' if (root/'Research/InteractionCC0'/(sid+'.mp3')).exists() else '')+sid+'.mp3'))
 clips.append({'button_id':i,'output_filename':out.name,'default_label':labels[i],'source_id':sid,'source_filename':original.name,'source_url':'https://zenodo.org/records/4008297' if dataset else 'https://freesound.org/people/'+authors[sid]+'/sounds/'+sid+'/',
 'source_context':'CatMeows: familiar-home waiting for food; no positive-affect assertion' if dataset else context[sid],
 'license':'CatMeows: scientific research/non-commercial, acknowledgement required' if dataset else 'CC0-1.0','source_sha256':hashlib.sha256(original.read_bytes()).hexdigest(),
 'source_start_seconds':start,'source_end_seconds':end,'original_rate':rate,'sample_rate':44100,'duration_seconds':len(pcm)/88200,'gain_db':20*math.log10(gain),'peak_dbfs':20*math.log10(audioop.max(pcm,2)/32767),'rms_dbfs':20*math.log10(max(audioop.rms(pcm,2),1)/32767),'fade_edge_seconds':.01,
 'repetition':False,'concatenation':False,'pitch_change':False,'speed_change':False,'sha256':hashlib.sha256(out.read_bytes()).hexdigest(),'auditory_review':'not_completed; model audio input unsupported','semantic_mapping':'owner phrase for entertainment; not a scientific translation of recorded context'})
assert len(set(c['source_id'] for c in clips))==12
assert all(.2<c['duration_seconds']<4 for c in clips)
manifest={'status':'12_independent_original_recordings_for_owner_interaction','actual_model_audition':False,'distinct_perceived_timbres_verified':False,'voice_music_distress_exclusion_verified':False,'selection_policy':'No isolation context; no brushing default-positive assumption; MBPL668822 rejected due to pitched/voice-tag ambiguity. Sources without affect descriptions not claimed comfortable. Author descriptions are not auditory verification.','noncommercial_personal_use_only':True,'clips':clips}
(root/'Research/clip-log.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2))
(root/'Evidence/AudioMetrics.json').write_text(json.dumps(clips,ensure_ascii=False,indent=2))
rows=['# 当前12按钮独立录音映射','','主人的短句与真实猫声用于娱乐互动，不科学翻译。全部来自12份不同原始录音；无重复组合、变调或变速。I类独处和B类梳毛均未嵌入；只有3条F等饭录音，另9条CC0短叫/颤音/轻啾/呼噜。未实际听审，无法确认每条听感差异和排除全部不适声音。','','|按钮|来源|原始片段秒|可核实情境|','|---|---|---|---|']
rows+=['|%s|%s|%.3f–%.3f|%s|'%(c['default_label'],c['source_id'],c['source_start_seconds'],c['source_end_seconds'],c['source_context']) for c in clips]
(root/'Research/Current-Button-Mapping.md').write_text('\n'.join(rows)+'\n')
with wave.open(str(root.parent/'Deliverables/MeowPaw-Audio-Samples.wav'),'wb') as dst:
 dst.setnchannels(1);dst.setsampwidth(2);dst.setframerate(44100)
 for c in clips:
  with wave.open(str(root/'MeowPaw/Audio'/c['output_filename']),'rb') as f:dst.writeframes(f.readframes(f.getnframes()))
  dst.writeframes(b'\0\0'*22050)
print(json.dumps([{k:c[k] for k in ['button_id','source_id','duration_seconds','peak_dbfs','rms_dbfs']} for c in clips],ensure_ascii=False,indent=2))
