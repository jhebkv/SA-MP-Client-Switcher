#NoEnv
#SingleInstance Force
#Include json.ahk
#Notrayicon
SetWorkingDir %A_ScriptDir%
if not (A_IsAdmin or RegExMatch(full_command_line," /restart(?!\S)")){
	try
	{
		if A_IsCompiled
			Run *RunAs "%A_ScriptFullPath%" /restart
		else
			Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
	}
	ExitApp
}
pvers:="1.0.1.1"
pname:="SAMP Launcher"
psnme:="SAMPL"
cnfig:="Settings.ini"
srdir:="Source"
srdir_smp:="Source\SAMP"
srdir_asi:="Source\ASI"
bcdir:="Backup"
smreg:="Software\SAMP"
di(bcdir)
a:=di(srdir_smp "\0.3.7-R2")
c:=di(srdir_smp "\0.3.8-RC4")
b:=di(srdir_asi "\scripts")
ifnotexist,%a%\samp.dll
	fileinstall,samp_0.3.7-r2.dll,%a%\samp.dll
ifnotexist,%a%\samp.exe
	fileinstall,samp_0.3.7-r2.exe,%a%\samp.exe
ifnotexist,%a%\samp-license.txt
	fileinstall,samp-license.txt,%a%\samp-license.txt
ifnotexist,%c%\samp.dll
	fileinstall,samp_0.3.8-rc4.dll,%c%\samp.dll
ifnotexist,%c%\samp.exe
	fileinstall,samp_0.3.8-rc4.exe,%c%\samp.exe
ifnotexist,%c%\samp-license.txt
	fileinstall,samp-license.txt,%c%\samp-license.txt
ifnotexist,%srdir_asi%\vorbisfile.dll
	fileinstall,vorbisfile.dll,%srdir_asi%\vorbisfile.dll
ifnotexist,%srdir_asi%\vorbishooked.dll
	fileinstall,vorbishooked.dll,%srdir_asi%\vorbishooked.dll
ifnotexist,%srdir_asi%\asi-license.txt
	fileinstall,asi-license.txt,%srdir_asi%\asi-license.txt
ifnotexist,%b%\global.ini
	fileinstall,scripts\global.ini,%b%\global.ini
a:=
b:=
c:=
gui(1)
gosub,iread
gosub,ichck
gosub,gload
gosub,gchck
sleep 2000
return
iread:
iniread,gtexe,%cnfig%,main,gtexe
iniread,gtdir,%cnfig%,main,gtdir
iniread,usrnm,%cnfig%,main,usrnm
iniread,clist,%cnfig%,main,clist
iniread,slist,%cnfig%,main,slist
iniread,rexit,%cnfig%,main,rexit
iniread,bfile,%cnfig%,main,bfile
iniread,afile,%cnfig%,main,afile
iniread,ovasi,%cnfig%,main,ovasi
iniread,crsip,%cnfig%,main,crsip
iniread,crcli,%cnfig%,main,crcli
return
ichck:
if !ec(gtexe){
	regread,gtexe,hkcu,%smreg%,gta_sa_exe
	if !ec(gtexe)
		gtexe:="C:\Program Files\Rockstar Games\GTA San Andreas\gta_sa.exe"
	splitPath,gtexe,,gtdir
	iniwrite,%gtdir%,%cnfig%,main,gtdir
	iniwrite,%gtexe%,%cnfig%,main,gtexe
}
if !ec(usrnm){
	regread,usrnm,hkcu,%smreg%,PlayerName
	if !ec(usrnm)
		usrnm:="user"
	iniwrite,%usrnm%,%cnfig%,main,usrnm
}
if !ec(clist)
	clist:=cc()
if !ec(slist)
	slist:=""
return
gload:
gui,show,h400 w530,%pname% - v%pvers%
menu,flemenu,add,E&xit,exit
menu,svrmenu,add,Add Server,smn1
menu,svrmenu,add,Change Server Version,smn2
menu,svrmenu,disable,Change Server Version
menu,svrmenu,add,Remove Server,smn3
menu,svrmenu,disable,Remove Server
menu,optmenu,add,Client Settings,omn1
menu,optmenu,add,Option,omn2
menu,hlpmenu,add,Help,hmn1
menu,hlpmenu,add,About,hmn2
menu,menum,add,File, :flemenu
menu,menum,add,Servers, :svrmenu
menu,menum,add,Option, :optmenu
menu,menum,add,Help, :hlpmenu
gui,menu,menum
gui,+resize -maximizebox
gui,add,listview,altsubmit vlclk glclk w510 h200,Version|Hostname|Players|Mode|Language|Server IP
gui,add,text,w50 xm+10 y+20,Server :
gui,add,dropdownlist,vdsst w100 x+p r5 gdsst,%slist%
gui,add,text,w60 x+m,Hostname :
gui,add,edit,w260 h20 disabled x+p vhosts
gui,add,text,w50 xm+10,Client :
gui,add,dropdownlist,w100 x+p vdsvt r3 gdsvt,%clist%
gui,add,text,w60 x+m,Mode :
gui,add,edit,w95 h20 disabled x+p vmodes
gui,add,text,w60 x+m,Language :
gui,add,edit,w95 h20 disabled x+p vlangs
gui,add,text,xm+10 y++35 w80,Username :
gui,add,edit,w120 x+p vusrnm h20,%usrnm%
gui,add,button,x+m w60 gplynw vplynw disabled default,Play
gui,add,text,x+m w100,Change Client :
gui,add,dropdownlist,x+p w100 h20 r3 gomn12 vccli,% cc(crcli)
gui,add,text,disabled xm+10 y+m w80,Use Rcon ? :
gui,add,edit,disabled w120 x+p h20
gui,add,text,x+80 y+-17 w100,Delete Samp.asi :
gui,add,button,x+p govasi vovasi w100,Delete
gui,add,statusbar,vsbar
gui,add,groupbox,xm ym+200 w510 h75 vgbset,Server Info
gui,add,groupbox,w510 h80 vgbuet,User Setting
return
gchck:
if ec(ovasi)
	guicontrol,,ovasi,1
else
	iniwrite,0,%cnfig%,main,ovasi
if ec(rexit)
	guicontrol,,rexit,1
else
	iniwrite,0,%cnfig%,main,rexit
if !ec(bfile){
	gosub,omn23
	iniwrite,1,%cnfig%,main,bfile
}
if ec(crcli)
	guicontrol,choose,ccli,%crcli%
lv_upd(crsip)
settimer,rtips,1000
return
lclk:
gui,submit,nohide
if !ec(ow){
	if ec(a_eventinfo) && (a_guievent!="ColClick"){
		lv_gettext(sip,a_eventInfo,6)
		crsip:=sip
		lv_sip(sip)
	}
	if (a_guievent="R")
		menu,svrmenu,show,% ms_get(x),% ms_get(y)
}
return
smn1:
gui,submit,nohide
if !ec(ow){
	ow:=1
	gui(2)
	gui,+alwaysontop
	gui,add,text,xm ym w150,Enter new samp server%a_tab%:`n(Hostname : Port)
	gui,add,edit,w100 x+p ym gsmn1 vasvn
	gui,add,edit,w100 x+m ym vaspr number,7777
	gui,add,button,gsmn11 w100 xm+150 y+m +default,Add Server
	gui,add,button,g2guiclose w100 x+m,Cancel
	gui,show,,%pname% - Add Server
	gui,submit,nohide
}
if (gui=2)
	st("Add Server to list",asvn ":" aspr)
return
smn11:
gui,submit
if (!ec(asvn) || !ec(aspr)){
	gui,-alwaysontop
	Msgbox,,Error 101 [Server Add],Invalid Input [HostName : Port].`nHostname : %asvn%, Port : %aspr%.
	gui,+alwaysontop
	return
}
if (sv_chk(asvn,"sip")=asvn){
	aspr:=sv_chk(asvn,"spr")
	asip:=sv_chk(asvn,"sip")
	gosub,smn11_n2
	return
}
else
	gosub,smn11_n1
return
smn11_n1:
st("Checking Server IP by ping",asvn)
asip:=sv_cip(asvn)
if !ec(asip){
	gosub,2guiclose
	msgbox,,Error 102 [Server Ping],Couldn't connect to Server / SAMP Server not found.`nPing request could not find host %asvn%, Please check the name and try again.`nServer IP : %asip%.
	return
}
else
	gosub,smn11_n2
return
smn11_n2:
st("Checking Server Info from monitor.sacnr.com",asip ":" aspr)
if !ec(sv_inf(asip,aspr)){
	gosub,2guiclose
	Msgbox,52,Error 103 [Unknown Server],Unknown Server ID / Server %asvn% not found on monitor.sacnr API.`nWould you like to add it by server ip [%asip%:%aspr%]?
	ifmsgbox yes
	{
		gui(2)
		sip:=asip
		svn:=asvn
		spr:=aspr
		shn=Unknown Server ID [%asip%:%aspr%]
		sgm:="N/A"
		sln:="N/A"
		sid:="N/A"
		spl:=0
		smp:=0
		ser:="N/A"
		gosub,smn11_n3
		return
	}
	return
}
else
{
	sip:=asip
	spr:=aspr
	svn:=asvn
	gosub,smn11_n3
}
return
smn11_n3:
iniwrite,%sip%,%cnfig%,%svn%,sip
iniwrite,%svn%,%cnfig%,%sip%,svn
iniwrite,%sip%,%cnfig%,%sip%,sip
iniwrite,%shn%,%cnfig%,%sip%,shn
iniwrite,%sgm%,%cnfig%,%sip%,sgm
iniwrite,%sln%,%cnfig%,%sip%,sln
iniwrite,%sid%,%cnfig%,%sip%,sid
iniwrite,%spl%,%cnfig%,%sip%,spl
iniwrite,%smp%,%cnfig%,%sip%,smp
iniwrite,%ser%,%cnfig%,%sip%,ser
iniwrite,%spr%,%cnfig%,%sip%,spr
sv_add(sip)
gosub,2guiclose
return
smn2:
gui,submit,nohide
if !ec(ow){
	ow:=1
	gui(4)
	gui,+alwaysontop
	gui,add,text,w70,Server :
	gui,add,edit,readonly x+m w300 h20,% sv_chk(sip,"shn")
	gui,add,text,w70 xm,svrver :
	gui,add,combobox,x+m w145 gsmn2 vaser,% cc(ser)
	gui,add,button,x+m w145 default gsmn21,Change Server Version
	gui,show,,%pname% - Edit Server 
	guicontrol,choose,aser,%ser%
	gui,submit,nohide
}
if (gui=4)
	st("Chaning Server [" svn "] version",aser)
return
smn21:
gui,submit
iniwrite,%aser%,%cnfig%,%sip%,ser
lv_upd(sip)
gosub,4guiclose
return
smn3:
gui,submit,nohide
if !ec(ow){
	if (shn="Hostname")
		return
	sb_settext("Remove Server from list... [" svn ":" spr "].")
	msgbox,52,%pname% - Remove Server, You're about to remove server from the list`n- Hostname : %shn%`n- Server : %svn%:%spr%`nAre you sure?
	IfMsgBox Yes
	{
		stringreplace,slist,slist,%sip%,,all
		iniwrite,%slist%,%cnfig%,main,slist
		lv_upd()
	}
	settimer,rtips,100
}
return
dsst:
gui,submit,nohide
if !ec(ow){
	sip:=%a_thislabel%
	sip:=sv_chk(sip,"sip")
	lv_sip(sip)
}
return
dsvt:
gui,submit,nohide
if !ec(ow){
	iniwrite,% %a_thislabel%,%cnfig%,%sip%,ser
	lv_upd(sip)
}
return
omn1:
gui,submit,nohide
if !ec(ow){
	ow:=1
	gui(3)
	gui,+alwaysontop
	gui,add,text,w120,Add Samp Client :
	gui,add,edit,x+p w150 readonly gomn1 vomn12
	gui,add,button,w100 x+m gomn10,Browse
	gui,add,combobox,x130 w150 disabled gomn1 vomn1,0.3.7-R2|0.3.8-RC3|0.3.8-RC4|0.3.8-RC5
	gui,add,button,w100 x+m disabled gomn11 vomn11,Add Client
	gui,add,text,y+m xm
	gui,add,text,y+m xm w120,Switch Samp Client :
	gui,add,dropdownlist,x+p w150 gomn13 vccli,% cc(crcli)
	gui,add,button,w100 x+m gomn12,OK
	gui,show,,%pname% - Client Settings
	guicontrol,choose,ccli,%crcli%
}
if (gui=3)
	st("Add (" omn12 ") or Change to (" ccli ") SA-MP client",crcli)
return
omn10:
gui,submit,nohide
a:=br_cli()
return
omn11:
gui,submit
if !ec(omn1){
	msgbox,,Error 201 [Add Client],Please fill the empty box with selected Client Version.`n| e.g. [0.3.8-RZ9]
	gui,show
	return
}
ifexist,%srdir_smp%\%omn1%\samp.dll
{
	Msgbox,52,Warning,Current version of samp is already exist in your list [%omn1%].`nWould you like to overwrite them ?
	ifmsgbox no
	{
		gui,show
		return
	}
}
di(srdir_smp "\" omn1)
splitpath,a,b,c
cc_ins(omn12,c,omn1)
if (b="samp"){
	filecopy,%a%.exe,%srdir_smp%\%omn1%\samp.exe,1
	filecopy,%a%.dll,%srdir_smp%\%omn1%\samp.dll,1
}
else {
	filecopy,%c%\samp.exe,%srdir_smp%\%omn1%\samp.exe,1
	filecopy,%c%\samp.dll,%srdir_smp%\%omn1%\samp.dll,1
}
cc(omn1)
cc_cpy(omn1)
guicontrol,,omn1,`n
guicontrol,,omn12,`n
guicontrol,disable,omn11
guicontrol,disable,omn1
msgbox,,%pname% - Client Added [%omn1%],SAMP v[%omn1%] added to client list.`nClient directory: %srdir_smp%\%omn1%`nPlease rename to correct version if you think wrongly type the version.
gosub,3guiclose
guicontrol,,ccli,%omn1%
guicontrol,choose,ccli,%omn1%
return
omn12:
gui,submit,nohide
iniread,a,%cnfig%,main,crcli
if (a=ccli){
	a:=
	if (gui=3)
		gosub,3guiclose
	return
}
if !ec(ccli){
	st("SA-MP Client not found on your list, Please add one","N/A")
	settimer,rtips,1000
	return
}
st("Changing SA-MP Client",ccli)
ifexist %srdir_smp%\%ccli%
	if cc_cpy(ccli,0)
		if (gui=3)
			gosub,3guiclose
guicontrol,choose,ccli,%ccli%
settimer,rtips,500
return
omn13:
gui,submit,nohide
return
omn2:
gui,submit,nohide
if !ec(ow){
	ow:=1
	gui(5)
	gui,+alwaysontop
	gui,add,text,,GTA SA Directory :
	gui,add,edit,y+m vgtdir h20 w260 readonly,%gtdir%
	gui,add,button,x+m w100 vomn21 gomn21 default,Browse
	gui,add,text,xm,GTA Backup Directory :
	gui,add,checkbox,x+m gomn22 vrexit,Delete samp.asi on exit.
	gui,add,edit,y+m xm w260 h20 readonly,%a_workingdir%\%bcdir%
	gui,add,button,x+m w100 vomn23 gomn23,Backup Now
	gui,add,text,vbckstats xm w260
	gui,add,button,x+m w100 vomn24 gomn24,Restore GTA
	gui,show,,%pname% - Option
	if ec(rexit)
		guicontrol,,rexit,1
}
if (gui=5)
	st("Setting SAMP Launcher")
return
omn21:
gui,submit,nohide
gui,-alwaysontop
fileselectfolder,gtdirc,*%gtdir%,0
ifexist,%gtdirc%\gta_sa.exe
{
	gtdir:=gtdirc
	gtexe:=gtdir "\gta_sa.exe"
	iniwrite,%gtdir%,%cnfig%,main,gtdir
	iniwrite,%gtexe%,%cnfig%,main,gtexe
	regwrite,reg_sz,hkcu,%smreg%,gta_sa_exe,%gtexe%
	guicontrol,,gtdir,%gtdir%
	ifexist,%gtdir%\samp.exe
	{
		sampexe:=gtdir "\samp.exe"
		iniwrite,%sampexe%,%cnfig%,main,sampexe
	}
}
guicontrol,disable,omn21
guicontrol,,omn21,Done.
gui,+alwaysontop
return
omn22:
gui,submit,nohide
iniwrite,%rexit%,%cnfig%,main,rexit
return
omn23:
gui,submit,nohide
gui,-alwaysontop
ow:=1
loop,%bcdir%\*
	a:=a_index
if ec(a){
	msgbox,52,Warning 505 [Backup],You are about to backup GTA files...`n | Backup directory : %bcdir%`nWould you like to overwrite backed files (if any) ?
	ifmsgbox Yes
	{
		a:=
		loop,%gtdir%\* {
			fb(a_loopfilename,1)
			sleep,100
		}
		loop,%gtdir%\cleo\* {
			fb("cleo\" a_loopfilename,1)
			sleep,100
		}
		loop,%gtdir%\samp\* {
			fb("samp\" a_loopfilename,1)
			sleep,100
		}
		loop,%gtdir%\scripts\* {
			fb("scripts\" a_loopfilename,1)
			sleep,100
		}
		gosub,omn231
		return
	}
}
loop,%gtdir%\* {
	fb(a_loopfilename)
	sleep,100
}
loop,%gtdir%\cleo\* {
	fb("cleo\" a_loopfilename)
	sleep,100
}
loop,%gtdir%\samp\* {
	fb("samp\" a_loopfilename)
	sleep,100
}
loop,%gtdir%\scripts\* {
	fb("scripts\" a_loopfilename)
	sleep,100
}
omn231:
guicontrol,disable,omn23
guicontrol,,omn23,Backed up.
if (gui=5)
	gui,+alwaysontop
ow:=0
return
omn24:
fr()
fr("samp")
fr("cleo")
fr("scripts")
guicontrol,disable,omn24
guicontrol,,omn24,Restored.
st("Restoring GTA SA files","Success")
return
plynw:
gui,submit,nohide
if !ec(ow)
	gosub,plchk
st()
return
plchk:
gui,submit,nohide
iniread,a,%cnfig%,main,usrnm
iniread,spr,%cnfig%,%sip%,spr
iniread,ser,%cnfig%,%sip%,ser
iniread,b,%cnfig%,main,crcli
st("Checking username",usrnm)
if !ec(usrnm){
	msgbox,,Error 301 [Username],Please insert your username / nickname.`nUsername : %usrnm%.
	return
}
if (a!=usrnm){
	iniwrite,%usrnm%,%cnfig%,main,usrnm
	regwrite,reg_sz,hkcu,%smreg%,PlayerName,%usrnm%
}
a:=
st("Checking gta_sa.exe program file",gtexe)
ifnotexist,%gtexe%
{
	msgbox,,Error 302 [GTA],gta_sa.exe not found.`nGta_sa.exe : %gtexe%.
	return
}
st("Checking Server Address",sip ":" spr)
if !ec(sip)||!ec(spr){
	msgbox,,Error 304 [Server Address],Could not find server address. [%svn%:%spr%]
	return
}
st("Checking Server Version",ser)
if !ec(ser)||(ser="N/A"){
	msgbox,52,Error 305 [Server Version],You didn't set the Server Version yet`nServer Version : %ser%.`nChange Server Version now ?
	ifmsgbox yes
		gosub,smn2
	return
}
st("Checking asi files")
if as()=1 {
	st("Checking Client list")
	if (b!=ser){
		if ec(clist:=cc())
			c:=1
		stringsplit,a,clist,`|
		loop %a0% {
			if (a%a_index%!=ser)
				c:=0
			else if (a%a_index%=ser) {
				c:=1
				break
			}
		}
		if ec(c)
			cc_cpy(ser,1)
		if !ec(c){
			msgbox,52,Error 306 [Client],Couldn't find Server Version on your samp client list.`nServer Version : %ser%,`nSAMP Client : %clist%.`nAdd samp client now ?
			ifmsgbox yes
				gosub,omn1
			return
		}
	}
	else if (b=ser)
		filecopy,%srdir_smp%\%ser%\samp.dll,%gtdir%\samp.asi,1
	a:=
	b:=
	c:=
}
if pr_chk("gta_sa.exe"){
	msgbox,52,Error 203 [gta_sa.exe],GTA San Andreas is currently running.`nTerminate gta_sa.exe ?
	ifmsgbox yes
		pr_kil("gta_sa.exe")
	return
}
run,%gtexe% -c -n %usrnm% -h %sip% -p %spr%,%gtdir%
st("GTA San Andreas is currently running")
return
ovasi:
gui,submit,nohide
filedelete,%gtdir%\samp.asi
return
hmn1:
gui,submit,nohide
if !ec(ow){
	ow:=1
	hmn1=
(
%pname% (%psnme%)
Automatically change your samp Client Version to Server Version.

Servers :
 Add Server ; add samp server to launcher, SAMPL will automatically detect Server Version.
 Change Server Version ; change selected samp Server Version, If SAMPL doesn't detect Server Version, use this.
 Remove Server ; remove samp server from launcher list.
 
Option : 
 Although this program contain samp 0.3.7 and 0.3.8, You can add different svrver to client list.
  Client Setting ; add samp client to your launcher list.
   1. Click Browse and select samp.dll/samp.exe
   2. Fill the empty box with current samp svrver e.g. 0.3.9-RC1
   3. Click Add Client.
   4. (optional) Install another version of samp and repeat no 1-3.
	 
Note ; If you already have the Client Version on launcher list but SAMPL read it as different version, go to "%srdir_smp%" then rename the version to match with the server.
	)
	msgbox,64,%pname% - Readme,%hmn1%
	ow:=0
}
return
hmn2:
gui,submit,nohide
if !ec(ow){
	ow:=1
	hmn2=
(
%pname% (%psnme%) by jheb
Version: %pvers%
http://www.fb.com/jhebkv

Content:
 | SAMP 0.3.7-R2
 | SAMP 0.3.8-RC4
 | ASI Loader
 
Credits:
 | %pname% (jheb)
 | SA-MP (samp.com)
 | Server List API (monitor.sacnr.com)
 | ASI loader (silent/zdanio95)
 | AHK (autohotkey.com)
)
	msgbox,64,About %pname%,%hmn2%
	ow:=0
}
return
guisize:
gui_sze()
return
2guiclose:
3guiclose:
4guiclose:
5guiclose:
ow:=0
settimer,rtips,500
if (gui!=1)
	gui,destroy
gui(1)
return
rtips:
settimer,rtips,off
st()
return
guiclose:
exit:
if ec(rexit)
	gosub,ovasi
exitapp
ms_get(a){
	mousegetpos,x,y
	if (a="x")
		return x
	if (a="y")
		return y
}
gui_sze(){
	If ErrorLevel in 0,2
		If (A_GuiHeight <> 400){
			guicontrol,move,lclk,h200
			guicontrol,move,gbset,h75
			guicontrol,move,gbuet,h80
			gui,show,h400
			return
		}
	If ErrorLevel in 0,2
		If (A_GuiWidth < 530){
			guicontrol,move,lclk,w510 h200
			guicontrol,move,gbset,w510 h75
			guicontrol,move,gbuet,w510 h80
			gui,show,h400 w530
			return
		}
	If (A_GuiWidth > 530){
		nw:=a_guiwidth-20
		nh:=a_guiheight-200
		guicontrol,move,lclk,w%nw%
		guicontrol,move,lclk,h%nh%
		guicontrol,move,gbset,% "y"nh+6 "w"nw
		guicontrol,move,gbuet,% "y"nh+87 "w"nw
	}
}
gui(a){
	global gui
	gui:=a
	gui,%a%:default
}
lv_upd(s=""){
	global cnfig,shn,sgm,sln,sid,spr,spl,smp,ser,sip,gui
	gui,1:default
	iniread,c,%cnfig%,main,slist
	if !ec(c)
		return 0
	stringleft,cc,c,1
	if (cc="|")
		stringtrimleft,c,c,1
	stringright,cc,c,1
	if (cc="|")
		stringtrimright,c,c,1
	stringreplace,c,c,`|`|,`|,all
	iniwrite,%c%,%cnfig%,main,slist
	lv_delete()
	loop,parse,c,`|
	{
		a:=a_loopfield
		if ec(a){
			sv_chk(a)
			if (ec(shn) && ec(a))
				lv_add("",ser,shn,spl "/" smp,sgm,sln,a)
		}
	}
	lv_modifycol(1,"autohdr")
	lv_modifycol(2,"autohdr")
	lv_modifycol(3,"autohdr")
	lv_modifycol(4,"autohdr")
	lv_modifycol(5,"autohdr")
	lv_modifycol(6,"autohdr")
	if ec(s)
		lv_sip(s)
	else if !ec(s)
		lv_sip(a)
	if (gui!=1)
		gui(gui)
}
lv_sip(a){
	global cnfig
	if !ec(a)
		return 0
	sv_chk(a)
	sv_cvr(a)
	menu,svrmenu,enable,Remove Server
	menu,svrmenu,enable,Change Server Version
	guicontrol,,hosts,% sv_chk(a,"shn")
	guicontrol,,langs,% sv_chk(a,"sln")
	guicontrol,,modes,% sv_chk(a,"sgm")
	guicontrol,enable,plynw
	iniwrite,%a%,%cnfig%,main,crsip
	gosub,rtips
	return 1
}
br_cli(){
	global gui,gtdir
	gui,-alwaysontop
	fileselectfile,x,M 1,%gtdir%,Select,SAMP Files (samp*.*; rcon*.exe; mouse*.png; bass*.dll; gtaweap3*.ttf; samp*)
	stringsplit,x,x,`n
	splitpath,x2,,,,a
	if ec(x1) {
		ifnotexist,%x1%\samp*.dll
		{
			msgbox,,Error 501 [SAMP.dll], SAMP client not found [samp.dll]`nSamp.dll : %x1%\%a%.dll
			gui,+alwaysontop
			guicontrol,disable,omn11
			guicontrol,disable,omn1
			return
		}
		ifnotexist,%x1%\samp*.exe
		{
			msgbox,,Error 502 [SAMP.exe], SAMP client not found [samp.exe]`nSamp.exe : %x1%\%a%.exe
			gui,+alwaysontop
			guicontrol,disable,omn11
			guicontrol,disable,omn1
			return
		}
		loop %x0% {
			if (a_index<2)
				c="%x2%"
			if (a_index>2)
				c:=c "`,""" x%a_index% """"
		}
		guicontrol,,omn12,%c%
		guicontrol,enable,omn11
		guicontrol,enable,omn1
		a:=x1 "\" a
	}
	gui,+alwaysontop
	return a
}
sv_cvr(a){
	global cnfig
	c:=sv_chk(a,"ser")
	b:=cc(c)
	iniread,s,%cnfig%,main,slist
	stringsplit,s,s,`|
	loop %s0%
		x:=sv_chk(s%a_index%,"svn") "|" x
	z:=sv_chk(a,"svn")
	if ec(s){
		guicontrol,,dsst,|%x%
		guicontrol,choose,dsst,%z%
	}
	guicontrol,,dsvt,|%b%
	guicontrol,choose,dsvt,%c%
	return c
}
sv_inf(a,b){
	global shn,sgm,sln,sid,spr,spl,smp,ser,sip
	svc:="http://monitor.sacnr.com/api/?IP=" a "&Port=" b "&Action=info&Format=json"
	urldownloadtofile,%svc%,server.json
	fileread,c,server.json
	filedelete,server.json
	if (c="Unknown Server ID")||!ec(c)
		return 0
	s := JSON.Load(c)
	shn:=s.hostname
	sgm:=s.gamemode
	sln:=s.language
	sid:=s.serverid
	spr:=s.port
	spl:=s.players
	smp:=s.maxplayers
	ser:=s.version
	sip:=a
	spr:=b
	return 1
}
sv_cip(a){
	run,%comspec% /c ping.exe %a% -n 1 `> "server.txt",,hide,d
	while pr_chk(d)
		sleep 100
	fileread,x,server.txt
	filedelete,server.txt
	loop,parse,x,`n
	{
		z:=a_loopfield
		if z contains Ping statistics for
		{
			stringsplit,z,z,%a_space%,all
			stringtrimright,z,z%z0%,2
			return z
			break
		}
	}
	return 0
}
sv_chk(a,b=""){
	global cnfig
	if !ec(b){
		global svn,sip,ser,shn,sgm,sln,spl,smp,spr,sid
		iniread,a,%cnfig%,%a%,sip
		iniread,svn,%cnfig%,%a%,svn
		iniread,sip,%cnfig%,%svn%,sip
		iniread,shn,%cnfig%,%a%,shn
		iniread,sgm,%cnfig%,%a%,sgm
		iniread,sln,%cnfig%,%a%,sln
		iniread,spl,%cnfig%,%a%,spl
		iniread,smp,%cnfig%,%a%,smp
		iniread,ser,%cnfig%,%a%,ser
		iniread,spr,%cnfig%,%a%,spr
		iniread,sid,%cnfig%,%a%,sid
		return 1
	}
	else if ec(b){
		iniread,x,%cnfig%,%a%,%b%
		return x
	}
}
sv_add(a){
	global cnfig
	iniread,b,%cnfig%,main,slist
	stringsplit,b,b,`|
	loop %b0% {
		if (b%a_index%=a){
			gosub,2guiclose
			st("Updating Server",svn)
			lv_upd(a)
			settimer,rtips,500
			return 0
		}
	}
	if !ec(b)
		iniwrite,%a%,%cnfig%,main,slist
	else if ec(b)
		iniwrite,%b%|%a%,%cnfig%,main,slist
	lv_upd(a)
	return 1
}
fr(b=""){
	global bcdir,gtdir
	if !ec(b){
		loop,%bcdir%\*.backup {
			st("Restoring GTA SA files",a_loopfilename)
			stringtrimright,a,a_loopfilename,7
			filecopy,%bcdir%\%a_loopfilename%,%gtdir%\%a%,1
		}
	}
	else if ec(b){
		loop,%bcdir%\%b%\*.backup {
			st("Restoring GTA SA files",b "\" a_loopfilename)
			stringtrimright,a,a_loopfilename,7
			filecopy,%bcdir%\%b%\%a_loopfilename%,%gtdir%\%b%\%a%,1
		}
	}
	settimer,rtips,500
}
fb(a="",x=""){
	st("Backup GTA / SA-MP files",a)
	global bcdir,gtdir
	splitpath,a,b,c,d
	s:=gtdir "\" a
	d:=bcdir "\" a ".backup"
	splitpath,a,b,c
	if ec(c){
		ifnotexist %bcdir%\%c%
			filecreatedir,%bcdir%\%c%
		d:=bcdir "\" c "\" b ".backup"
	}
	if (x!=1)
		filecopy,%s%,%d%
	else if (x=1)
		filecopy,%s%,%d%,1

	settimer,rtips,500
}
st(a="",b=""){
	global gui,pname,pvers,shn,svn,spr,psnme,sip,usrnm
	gui,1:default
	c=| %a%... | [%b%].
	if !ec(b)
		c=| %a%...
	if !ec(a){
		if ec(svn)
			c=| %psnme% | Hostname : %shn% | Address : %sip%:%spr%
		else
			c=| %pname% - %pvers% | Username : %usrnm%
	}
	sb_settext(c)
	if (gui!=1)
		gui(gui)
}
di(a){
	ifnotexist,%a%
		filecreatedir,%a%
	return a
}
cc_ins(a,b,c){
	global srdir_smp
	stringreplace,a,a,`",,all
	stringsplit,a,a,`,
	loop %a0% {
		st("Copying files to launcher list",a%a_index%)
		d:=b "\" a%a_index%
		e:=srdir_smp "\" c "\" a%a_index%
		filecopy,%d%,%e%,1
		settimer,rtips,500
	}
}
cc_cpy(a,z=""){
	global cnfig,srdir_smp,gtdir,gui,crcli
	c:=gtdir,d:=srdir_smp,e:=cnfig
	if !ec(a)
		return 0
	b:=d "\" a
	ifnotexist %b% 
	{
		gui,-alwaysontop
		msgbox,,Error 503 [Client Source],Source directory not found on %pname%.`nSource Directory : %b%.
		if (gui!=1)
			gui,+alwaysontop
		return 0
	}
	st("Changing SA-MP client to",a)
	pr_kil("samp.exe")
	if ec(z){
		st("Copying SA-MP ASI files","samp.asi")
		filecopy,%b%\samp.dll,%c%\samp.asi,1
	}
	if (z=0){
		st("Deleting SA-MP ASI files","samp.asi")
		filedelete,%c%\samp.asi
	}
	loop,%b%\* {
		fb(a_loopfilename)
		st("Copying SA-MP files",a_loopfilename)
		filecopy,%b%\%A_LoopFileName%,%c%\%A_LoopFileName%,1
	}
	loop,%b%\SAMP\* {
		fb("SAMP\" a_loopfilename)
		st("Copying SA-MP files","SAMP\" a_loopfilename)
		filecopy,%b%\SAMP\%A_LoopFileName%,%c%\SAMP\%A_LoopFileName%,1
	}
	st("Changing SA-MP client to " a,"Complete")
	iniwrite,%a%,%e%,main,crcli
	crcli:=a
	guicontrol,choose,ccli,%crcli%
	settimer,rtips,500
	return 1
}
cc(z=""){
	global srdir_smp,cnfig
	a:=srdir_smp,b:=cnfig,x:=""
	loop,%a%\*,2,0
		x:=x "|" a_loopfilename
	stringleft,xc,x,1
	if (xc="|")
		stringtrimleft,x,x,1
	stringupper,x,x
	iniwrite,%x%,%b%,main,clist
	if ec(z){
		stringsplit,x,x,`|
		loop %x0%
			if (x%a_index%=z){
				m:=1
				break
			}
		if !ec(m)
			x:=x "|" z
	}
	return x
}
ec(a){
if ((a="error")||!a||(a=0))
	return 0
else
	return 1
}
as(a=""){
	global gtdir,srdir_asi
	di(gtdir "\scripts")
	filecopy,%srdir_asi%\vorbishooked.dll,%gtdir%\vorbishooked.dll,1
	filecopy,%srdir_asi%\vorbisfile.dll,%gtdir%\vorbisfile.dll,1
	filecopy,%srdir_asi%\asi-license.txt,%gtdir%\asi-license.txt
	filecopy,%srdir_asi%\scripts\global.ini,%gtdir%\scripts\global.ini
	return 1
}
pr_chk(a){
	Process,Exist,%a%
	return Errorlevel
}
pr_kil(a){
	stringsplit,a,a,`|
	loop, %a0% {
		b:=a%a_index%
		if pr_chk(b)
			run, %comspec% /c taskkill.exe /im %b% /f,,hide
	}
}
