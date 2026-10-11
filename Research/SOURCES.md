# 当前互动音源与使用条件

当前12按钮来自12份不同原始录音，含短喵、颤音、轻啾与呼噜，不再重复组合。同一长录音只用于一个按钮。准确文件/片段/增益/哈希见clip-log.json与Current-Button-Mapping.md，prepare_audio.py可重建。

## Freesound · 9条CC0

|作者|ID/作品|作者描述可支持的内容|
|---|---|---|
|jsbarrett|[200336 Cat trilling](https://freesound.org/people/jsbarrett/sounds/200336/)|自家猫颤音，未宣称情绪|
|dreamstobecome|[451250 cat chirp](https://freesound.org/people/dreamstobecome/sounds/451250/)|猫舒服坐在膝上，满足地轻啾|
|tuberatanka|[110011 cat meow](https://freesound.org/people/tuberatanka/sounds/110011/)|饥饿猫短喵|
|Lukey1028|[732520 Young Cat Meow](https://freesound.org/people/Lukey1028/sounds/732520/)|一岁猫短喵|
|skymary|[412016 cat purring and meow](https://freesound.org/people/skymary/sounds/412016/)|呼噜转喵，未宣称情绪|
|TRNGLE|[362652 Cat meow](https://freesound.org/people/TRNGLE/sounds/362652/)|猫短叫，未宣称情绪|
|lextrack|[333916 Cat Meowing](https://freesound.org/people/lextrack/sounds/333916/)|猫短叫，cute标签非情绪验证|
|fthgurdy|[528193 Cat Meow 2](https://freesound.org/people/fthgurdy/sounds/528193/)|猫短叫，未宣称情绪|
|kentspublicdomain|[345039 Cat purr domestic happy glad](https://freesound.org/people/kentspublicdomain/sounds/345039/)|作者明确家猫开心舒服的呼噜|

官方页面CC0已核查，使用官方HQ MP3预览，不修改原MP3；FFmpeg技能工具仅解码为单声道PCM，之后仅裁剪、电平和10ms边缘淡化。未变调、变速、复制竞品或合成人声。MBPL668822因pitched/voice标签来源处理不清而未采用；未把标签当作人声合成事实。

## CatMeows · 3条非商业F等饭录音

原站：[Zenodo4008297](https://zenodo.org/records/4008297)，DOI10.5281/zenodo.4008297，版本1.0.2，dataset.zip官方MD5 b5fa911bcd6514e39dfef6876f747df4匹配；440个独立PCM猫叫，作者在extras另存非猫叫及未分段序列。本次只采用F_BAC01_MC_MN_SIM01_101.wav、F_BRA01_MC_MN_SIM01_302.wav、F_BRI01_MC_FI_SIM01_201.wav。真实原始PCM为8kHz，不把重采样44.1kHz声称为恢复高频音质。

原站许可允许科学研究及非商业用途，要求致谢。用户明确本次为自用非商业App；不得将它说成CC0、MIT音频、无限商业授权或供商业上架。GitHub Yfyangd/meow仅提供研究线索，没有复制其代码、模型或将其MIT代码许可套用至音频。

致谢：Luca Andrea Ludovico、Stavros Ntalampiras、Giorgio Presti、Simona Cannas、Monica Battini、Silvana Mattiello及米兰大学团队。参考：Ludovico et al., CatMeows: A Publicly-Available Dataset of Cat Vocalizations, MMM2021, LNCS12573, pp230–243；Ntalampiras et al., Automatic Classification of Cat Vocalizations Emitted in Different Contexts, Animals9(8),543(2019)。

所有I陌生环境独处素材排除；所有B梳毛素材未采用，不把梳毛默认当舒服。F仅说明熟悉环境等饭，不证明快乐、无痛苦或人话语义。旧3条组合与曾提取的未采用候选仅为研究历史，不进App。

## 验证边界

模型音频输入不支持，未实际听审，不能确认12段听感差异、无人声音乐或完全排除恐惧疼痛攻击。素材只依据作者真实录音描述与独立文件/情境、正常PCM电平筛选。给用户按按钮1–12顺序的试听合辑，0.5秒间隔，和App音频一致，供其结合自家猫反应选用；主人短句不科学翻译猫语。
