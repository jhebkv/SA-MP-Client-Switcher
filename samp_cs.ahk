SetWorkingDir %A_ScriptDir%
#NoEnv
#SingleInstance Force
#Notrayicon
#Include json.ahk
#Include dnsquery.ahk
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
msget(a){
	MouseGetPos,x,y
	if a="x"
		return x
	if a="y"
		return y
}
gui(a="",b=""){
	global gui
	if ec(a){
		gui:=a
		gui,%a%:default
	}
	if (gui!=1){
		if ec(b)
			gui,-alwaysontop
		else
			gui,+alwaysontop
	}
	return 1
}
lvupd(s=""){
	global cnfig,shn,sgm,sln,sid,spr,spl,smp,ser,sip,gui
	c:=svupd()
	lv_delete()
	loop,parse,c,`|
	{
		a:=A_LoopField
		if ec(a){
			svchk(a)
			if (ec(shn) && ec(a))
				lv_add("",ser,shn,spl "/" smp,sgm,sln,sip)
		}
	}
	lv_modifycol(1,"autohdr")
	lv_modifycol(2,"autohdr")
	lv_modifycol(3,"autohdr")
	lv_modifycol(4,"autohdr")
	lv_modifycol(5,"autohdr")
	lv_modifycol(6,"autohdr")
	if !ec(s)
		iniread,s,%cnfig%,main,crsip
	svsip(s)
}
brcli(){
	global gui,gtdir
	gui("",1)
	fileselectfile,x,M 1,%gtdir%,Select,SAMP Files (samp*.*; rcon*.exe; mouse*.png; bass*.dll; gtaweap3*.ttf; samp*)
	stringsplit,x,x,`n
	splitpath,x2,,,,a
	if ec(x1) {
		IfNotExist,%x1%\samp*.exe
			z:="exe"
		IfNotExist,%x1%\samp*.dll
			z:="dll"
		if ec(z) {
			GuiControl,disable,omn11
			GuiControl,disable,omn1
			st("SAMP Client not found [samp." z "].","BRCLI",75)
		}
		loop %x0% {
			if (a_index<2)
				c="%x2%"
			if (a_index>2)
				c.="`,""" x%a_index% """"
		}
		GuiControl,,omn12,%c%
		GuiControl,enable,omn11
		GuiControl,enable,omn1
		a:=x1 "\" a
	}
	gui()
	return a
}
svinf(a,b){
	global cnfig
	c:=dnsquery(a,bc,nc)
	if !nc {
		bc:=a
		c:=a
		a:=bc
	}
	if !ec(c)
		return 0
	d:="http://monitor.sacnr.com/api/?IP=" c "&Port=" b "&Action=info&Format=json"
	urldownloadtofile,%d%,server.json
	fileread,e,server.json
	ifexist,server.json
		filedelete,server.json
	if ec(e) && (e!="Unknown Server ID")
		e:=json.load(e)
	iniwrite,% c,%cnfig%,%a%,sip
	iniwrite,% a,%cnfig%,%c%,svn
	iniwrite,% b,%cnfig%,%c%,spr
	iniwrite,% c,%cnfig%,%c%,sip
	iniwrite,% e.version,%cnfig%,%c%,ser
	iniwrite,% e.players,%cnfig%,%c%,spl
	iniwrite,% e.hostname,%cnfig%,%c%,shn
	iniwrite,% e.gamemode,%cnfig%,%c%,sgm
	iniwrite,% e.language,%cnfig%,%c%,sln
	iniwrite,% e.serverid,%cnfig%,%c%,sid
	iniwrite,% e.maxplayers,%cnfig%,%c%,smp
	return c
}
svupd(a="",x=""){
	global cnfig
	iniread,b,%cnfig%,main,slist
	if !a && !b
		return 0
	if ec(x){
		stringreplace,b,b,%a%,,all
		a:=0
	}
	stringleft,bc,b,1
	if (bc="|")
		stringtrimleft,b,b,1
	stringright,bc,b,1
	if (bc="|")
		stringtrimright,b,b,1
	stringreplace,b,b,`|`|,`|,all
	if !a
		d:=b
	else if a {
		loop,parse,b,`|
			if (A_LoopField=a)
				return 0
		if !ec(b)
			d:=a
		else if ec(b)
			d:=b "|" a
	}
	iniwrite,%d%,%cnfig%,main,slist
	return d
}
svsip(a=""){
	global cnfig,shn,sln,sgm,ser,svn,shn
	svchk(a)
	s:=svupd()
	loop,parse,s,`|
		x.=svchk(A_LoopField,"svn") "|"
	GuiControl,,ddl1,|%x%
	GuiControl,,ddl2,% "|" cc(ser)
	if ec(a){
		menu,svrmenu,enable,Remove Server
		menu,svrmenu,enable,Change Server Version
		GuiControl,enable,mmb1
		iniwrite,%a%,%cnfig%,main,crsip
	}
	else {
		svn:="",ser:="",shn:="",sln:="",sgm:=""
		menu,svrmenu,disable,Remove Server
		menu,svrmenu,disable,Change Server Version
		GuiControl,disable,mmb1
	}
	GuiControl,choose,ddl1,% svn
	GuiControl,choose,ddl2,% ser
	GuiControl,,hosts,% shn
	GuiControl,,langs,% sln
	GuiControl,,modes,% sgm
	GuiControl,smn2:,smn2,% shn
	GuiControl,smn2:,aser,% ser
	GuiControl,smn2:choose,aser,% ser
	st("t",1)
	return a
}
svchk(a,b=""){
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
		if !shn
			shn=Unknown Server [%svn%:%spr%]
		if !ser
			ser:="N/A"
		if !sgm
			sgm:="N/A"
		if !sln
			sln:="N/A"
		if !spl
			spl:=0
		if !smp
			smp:=999
		return 1
	}
	else if ec(b){
		iniread,x,%cnfig%,%a%,%b%
		if !x {
			x:="N/A"
			if (b="shn")
				x:="Unknown Server [" svchk(a,"svn") ":" svchk(a,"spr") "]"
		}
		return x
	}
}
fr(b=""){
	global bcdir,gtdir
	if !prkil("gta_sa.exe|samp.exe")
		return 0
	if !ec(b)
		c:="\"
	else {
		di(gtdir "\" b)
		c:="\" b "\"
	}
	loop,%bcdir%%c%*.backup {
		x:=a_loopfilename
		st("Restoring GTA SA files",c x)
		stringtrimright,a,x,7
		filecopy,%bcdir%%c%%x%,%gtdir%%c%%a%,1
	}
}
fb(a="",b=""){
	global bcdir,gtdir
	di(bcdir)
	if !ec(b)
		b:=0
	if !ec(a)
		d:="\"
	else {
		di(bcdir "\" a)
		d:="\" a "\"
	}
	loop,%gtdir%%d%*.* {
		c:=a_loopfilename
		st("Backup GTA SA files",d c)
		filecopy,%gtdir%%d%%c%,%bcdir%%d%%c%.backup,%b%
	}
}
st(a="",b="",z=""){
	global gui,shn,svn,spr,psnme,psver,sip,usrnm,crcli
	gui,1:default
	c:=psnme " " psver
	if (a="t") && ec(b){
		if ec(svn){
			a:=shn
			b:=sip ":" spr
		}
		else {
			a:=usrnm
			b:="Client : " crcli
		}
		sleep, %b%
	}
	if ec(z) {
		c:="Error : " z
		b:="Label : " b
	}
	sb_settext(c,2)
	sb_settext(a,3)
	sb_settext(b,4)
	gui,%gui%:default
	if ec(z)
		exit
}
di(a){
	IfNotExist,%a%
		filecreatedir,%a%
	if !ec(a)
		return 0
	return a
}
ccins(a,b,c){
	global srdir_smp
	di(srdir_smp "\" c)
	stringreplace,a,a,`",,all
	loop,parse,a,`,
	{
		st("Copying files to client list",A_LoopField)
		filecopy,% b "\" A_LoopField,% srdir_smp "\" c "\" A_LoopField,1
	}
	return 1
}
cccpy(a,z=""){
	global cnfig,srdir_smp,gtdir,gui,crcli
	c:=gtdir,d:=srdir_smp,e:=cnfig
	if !ec(a) || !prkil("samp.exe|gta_sa.exe")
		return 0
	b:=d "\" a
	IfNotExist,%b% 
		return 0
	if !ec(z)
		aschk()
	if (z=1)
		aschk(1)
	loop,%b%\* {
		x:=a_loopfilename
		fb(x)
		st("Copying SA-MP files",x)
		filecopy,%b%\%x%,%c%\%x%,1
	}
	loop,%b%\SAMP\* {
		x:=a_loopfilename
		fb("SAMP\" x)
		st("Copying SA-MP files","SAMP\" x)
		filecopy,%b%\SAMP\%x%,%c%\SAMP\%x%,1
	}
	crcli:=a
	iniwrite,%crcli%,%e%,main,crcli
	GuiControl,omn1:choose,ccli,%crcli%
	GuiControl,choose,ccli,%crcli%
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
		loop parse,x,`|
			if (A_LoopField=z){
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
aschk(a=""){
	global cnfig,gtdir
	ifexist %gtdir%\samp.asi
	{
		if !ec(a)
			b:=0
		else
			b:=1
	}
	else {
		if (a=1)
			b:=1
		else
			b:=0
	}
	if !b {
		GuiControl,disable,mmb3
		ifexist,%gtdir%\samp.asi
			filedelete,%gtdir%\samp.asi
	} else {
		GuiControl,enable,mmb3
		filecopy,%gtdir%\samp.dll,%gtdir%\samp.asi,1
	}
	iniwrite,%b%,%cnfig%,main,mmb3
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
prchk(a){
	Process,Exist,%a%
	return Errorlevel
}
prkil(a){
	global gui
	loop,parse,a,`|
	{
		b:=A_LoopField
		if prchk(b){
			gui("",1)
			msgbox,8244,Warning 401 [PRKIL],GTA / SAMP Process is currently running [%b%].`nWould you like to terminate the process to continue ?
			ifmsgbox no
				return 0
			gui()
			st("Terminating process",b)
			run, %comspec% /c taskkill.exe /im %b% /f,,hide,c
			while prchk(c)
				sleep 100
			st("t",1)
		}
	}
	return 1
}
pvers:="1.0.1.1-b_test"
psver:="1.1"
pname:="SAMP Client Switcher"
psnme:="SAMPCS"
cnfig:="Settings.ini"
srdir:="Source"
srdir_smp:="Source\SAMP"
srdir_asi:="Source\ASI"
bcdir:="Backup"
smreg:="Software\SAMP"
gsmn1:="Add Server"
gsmn2:="Change Server Version"
gomn1:="Client Setting"
gomn2:="Launcher Setting"
gui(1)
gui,add,statusbar
gui,show,h400 w530,%pname% - v%pvers%
st("Please wait, Loading settings")
menu,flemenu,add,E&xit,GuiClose
menu,svrmenu,add,Add Server,smn1
menu,svrmenu,add,Change Server Version,smn2
menu,svrmenu,disable,Change Server Version
menu,svrmenu,add,Remove Server,smn3
menu,svrmenu,disable,Remove Server
menu,optmenu,add,Client Settings,omn1
menu,optmenu,add,Launcher Settings,omn2
menu,hlpmenu,add,Help,hmn1
menu,hlpmenu,add,About,hmn2
menu,menum,add,File, :flemenu
menu,menum,add,Servers, :svrmenu
menu,menum,add,Option, :optmenu
menu,menum,add,Help, :hlpmenu
gui,menu,menum
st("Loading User Interface","GUI")
gui,+resize -maximizebox
gui,add,listview,altsubmit vlchk glchk w510 h200,Version|Hostname|Players|Mode|Language|Server IP
gui,add,text,w50 xm+10 y+20,Server :
gui,add,dropdownlist,vddl1 w100 x+p r5 gddl1
gui,add,text,w60 x+m,Hostname :
gui,add,edit,w260 h20 disabled x+p vhosts
gui,add,text,w50 xm+10,Client :
gui,add,dropdownlist,w100 x+p vddl2 r3 gddl2
gui,add,text,w60 x+m,Mode :
gui,add,edit,w95 h20 disabled x+p vmodes
gui,add,text,w60 x+m,Language :
gui,add,edit,w95 h20 disabled x+p vlangs
gui,add,text,xm+10 y++35 w80,Username :
gui,add,edit,w120 x+p vusrnm h20
gui,add,button,x+m w100 gmmb1 vmmb1 disabled default,Play
gui,add,text,x+m w60,Client Ver :
gui,add,dropdownlist,x+p w100 h20 r3 gomn12 vccli
gui,add,text,disabled xm+10 y+m w80,Use Rcon ? 
gui,add,edit,disabled w120 x+p h20
gui,add,button,x+m w100 gmmb2 vmmb2,Refresh Server
gui,add,text,x+m w60
gui,add,button,x+p gmmb3 w100 vmmb3,Delete Samp.asi
gui,add,groupbox,xm ym+200 w510 h75 vgbset,Server Info
gui,add,groupbox,w510 h80 vgbuet,User Setting
gui("smn1")
gui,add,text,xm ym w150,Enter new samp server%a_tab%:`n(Hostname : Port)
gui,add,edit,w100 x+p ym gsmn1 vasvn
gui,add,edit,w100 x+m ym vaspr number,7777
gui,add,button,gsmn11 w100 xm+150 y+m +default,Add Server
gui,add,button,gsmn1GuiClose w100 x+m,Cancel
gui("smn2")
gui,add,text,w70,Server :
gui,add,edit,readonly x+m w300 h20 vsmn2
gui,add,text,w70 xm,Version :
gui,add,combobox,x+m w145 gsmn2 vaser
gui,add,button,x+m w145 default gsmn21,Change Server Version
gui("omn1")
gui,add,text,w120,Add Samp Client :
gui,add,edit,x+p w150 readonly gomn1 vomn12
gui,add,button,w100 x+m gomn10,Browse
gui,add,combobox,x130 w150 disabled gomn1 vomn1,0.3.7-R2|0.3.8-RC3|0.3.8-RC4|0.3.8-RC5
gui,add,button,w100 x+m disabled gomn11 vomn11,Add Client
gui,add,text,y+m xm
gui,add,text,y+m xm w120,Switch Samp Client :
gui,add,dropdownlist,x+p w150 gomn1 vccli
gui,add,button,w100 x+m gomn12,OK
gui("omn2")
gui,add,text,,GTA SA Directory :
gui,add,edit,y+m vgtdir h20 w260 readonly
gui,add,button,x+m w100 vomn21 gomn21 default,Browse
gui,add,text,xm,GTA Backup Directory :
gui,add,checkbox,x+m gomn22 vrexit,Delete samp.asi on exit.
gui,add,edit,y+m xm w260 h20 readonly vbcdir
gui,add,button,x+m w100 vomn23 gomn23,Backup Now
gui,add,text,vbckstats xm w260
gui,add,button,x+m w100 vomn24 gomn24,Restore GTA
gui(1)
st("Loading Source","SA-MP")
di(bcdir)
a:=di(srdir_smp "\0.3.7-R2")
c:=di(srdir_smp "\0.3.8-RC4")
b:=di(srdir_asi "\scripts")
IfNotExist,%a%\samp.dll
	fileinstall,samp_0.3.7-r2.dll,%a%\samp.dll
IfNotExist,%a%\samp.exe
	fileinstall,samp_0.3.7-r2.exe,%a%\samp.exe
IfNotExist,%a%\samp-license.txt
	fileinstall,samp-license.txt,%a%\samp-license.txt
IfNotExist,%c%\samp.dll
	fileinstall,samp_0.3.8-rc4.dll,%c%\samp.dll
IfNotExist,%c%\samp.exe
	fileinstall,samp_0.3.8-rc4.exe,%c%\samp.exe
IfNotExist,%c%\samp-license.txt
	fileinstall,samp-license.txt,%c%\samp-license.txt
IfNotExist,%srdir_asi%\vorbisfile.dll
	fileinstall,vorbisfile.dll,%srdir_asi%\vorbisfile.dll
IfNotExist,%srdir_asi%\vorbishooked.dll
	fileinstall,vorbishooked.dll,%srdir_asi%\vorbishooked.dll
IfNotExist,%srdir_asi%\asi-license.txt
	fileinstall,asi-license.txt,%srdir_asi%\asi-license.txt
IfNotExist,%b%\global.ini
	fileinstall,global.ini,%b%\global.ini
a:="",b:="",c:=""
st("Loading Configuration","Settings.ini")
iniread,gtexe,%cnfig%,main,gtexe
iniread,gtdir,%cnfig%,main,gtdir
iniread,usrnm,%cnfig%,main,usrnm
iniread,clist,%cnfig%,main,clist
iniread,slist,%cnfig%,main,slist
iniread,rexit,%cnfig%,main,rexit
iniread,bfile,%cnfig%,main,bfile
iniread,afile,%cnfig%,main,afile
iniread,crsip,%cnfig%,main,crsip
iniread,crcli,%cnfig%,main,crcli
st("Checking settings")
if !ec(gtexe){
	regread,gtexe,hkcu,%smreg%,gta_sa_exe
	if !ec(gtexe)
		gtexe:="C:\Program Files\Rockstar Games\GTA San Andreas\gta_sa.exe"
	splitPath,gtexe,,gtdir
	iniwrite,%gtdir%,%cnfig%,main,gtdir
	iniwrite,%gtexe%,%cnfig%,main,gtexe
}
if !ec(bfile){
	gosub,omn23
	iniwrite,1,%cnfig%,main,bfile
}
if !ec(usrnm){
	regread,usrnm,hkcu,%smreg%,PlayerName
	if !ec(usrnm)
		usrnm:="Username"
	iniwrite,%usrnm%,%cnfig%,main,usrnm
}
if !ec(clist)
	clist:=cc()
if !ec(slist)
	slist:=svupd()
if !ec(rexit)
	iniwrite,0,%cnfig%,main,rexit
if !ec(crcli)
	crcli:=""
aschk("c")
lvupd(crsip)
GuiControl,omn2:,gtdir,%gtdir%
GuiControl,omn2:,rexit,%rexit%
GuiControl,omn2:,bcdir,% a_workingdir "\" bcdir
GuiControl,,usrnm,%usrnm%
GuiControl,,ccli,%clist%
GuiControl,choose,ccli,%crcli%
GuiControl,omn1:,ccli,%clist%
GuiControl,omn1:choose,ccli,%crcli%
return
lchk:
if (A_GuiControl!="lchk") || (A_GuiEvent="ColClick")
	return
if (A_GuiEvent="I") && InStr(ErrorLevel,"S",true) {
	LV_GetText(sip,A_EventInfo,6)
	crsip:=sip
	svsip(sip)
}
if (A_GuiEvent="RightClick")
	menu,svrmenu,show,% msget(x),% msget(y)
return
smn1:
smn2:
omn1:
omn2:
gui,submit,nohide
if (gui!=a_thislabel) {
	gui(a_thislabel)
	gui,show,,% pname " - " g%a_thislabel%
	gui,1:+disabled
}
if (gui="smn1")
	st("Server Setting... | Add Server to list",asvn ":" aspr)
if (gui="smn2")
	st("Server Setting... | Changing " svn " version",aser)
if (gui="omn1")
	st("Client setting... | Add Client " omn1 "... | Change to " ccli,"Current Ver : "crcli)
if (gui="omn2")
	st("SAMP Client Switcher Setting")
return
SMN11:
gui,submit,nohide
if !ec(asvn)||!ec(aspr)
	st("Server Add - Invalid Input HostName : Port [" asvn ":" aspr "].",a_thislabel,611)
gosub,smn1guiclose
iniread,crsip,%cnfig%,main,crsip
svchk(svinf(asvn,aspr))
svupd(sip)
if !ec(crsip)
	crsip:=sip
lvupd(crsip)
return
smn21:
gui,submit,nohide
st("Change Server Version")
iniwrite,%aser%,%cnfig%,%sip%,ser
gosub,smn2guiclose
lvupd(sip)
return
SMN3:
gui,submit,nohide
if (shn="Hostname") || !ec(shn)
	st("Couldn't get server hostname [" shn "].",a_thislabel,630)
sb_settext("Remove Server from list... [" svn ":" spr "].")
msgbox,8244,%pname% - Remove Server,You're about to remove server from the list`n- Hostname : %shn%`n- Server : %svn%:%spr%`nAre you sure?
IfMsgBox Yes
{
	slist:=svupd(sip,1)
	iniwrite,%slist%,%cnfig%,main,slist
	iniwrite,% "",%cnfig%,main,crsip
	lvupd()
	svsip()
}
return
ddl1:
gui,submit,nohide
sip:=ddl1
sip:=svchk(sip,"sip")
svsip(sip)
return
ddl2:
gui,submit,nohide
iniwrite,%ddl2%,%cnfig%,%sip%,ser
lvupd(sip)
return
omn10:
gui,submit,nohide
a:=brcli()
return
OMN11:
gui,submit,nohide
if !ec(omn1)
	st("Client Add - Invalid Client Version e.g. [0.3.8-RC5]",a_thislabel,660)
ifexist,%srdir_smp%\%omn1%\samp.dll
{
	gui("",1)
	Msgbox,8244,Warning 666 [%a_thislabel%],Current version of samp is already exist in your list [%omn1%].`nWould you like to overwrite them ?
	gui()
	ifmsgbox no
		return
}
splitpath,a,b,c
ccins(omn12,c,omn1)
if (b="samp"){
	filecopy,%a%.exe,%srdir_smp%\%omn1%\samp.exe,1
	filecopy,%a%.dll,%srdir_smp%\%omn1%\samp.dll,1
}
else {
	filecopy,%c%\%b%.exe,%srdir_smp%\%omn1%\samp.exe,1
	filecopy,%c%\%b%.dll,%srdir_smp%\%omn1%\samp.dll,1
}
clist:=cc(omn1)
cccpy(omn1)
GuiControl,,omn1,`n
GuiControl,,omn12,`n
GuiControl,disable,omn11
GuiControl,disable,omn1
GuiControl,1:,ccli,|%clist%
GuiControl,1:choose,ccli,%omn1%
GuiControl,omn1:,ccli,|%clist%
GuiControl,omn1:choose,ccli,%omn1%
gui("",1)
msgbox,8256,%pname% - Client Added [%omn1%],SAMP v%omn1% added to client list.`nClient directory: %srdir_smp%\%omn1%`nPlease rename to correct version if you think wrongly type the version.
gosub,omn1guiclose
return
omn12:
gui,submit,nohide
iniread,a,%cnfig%,main,crcli
if (a=ccli) || !prkil("samp.exe|gta_sa.exe")
	return
st("Changing SA-MP Client",ccli)
ifexist %srdir_smp%\%ccli%
	cccpy(ccli,0)
GuiControl,omn1:choose,ccli,%ccli%
GuiControl,1:choose,ccli,%ccli%
gosub,omn1guiclose
return
OMN21:
gui,submit,nohide
gui("",1)
fileselectfolder,gtdirc,*%gtdir%,0
ifexist,%gtdirc%\gta_sa.exe
{
	gtdir:=gtdirc
	gtexe:=gtdir "\gta_sa.exe"
	iniwrite,%gtdir%,%cnfig%,main,gtdir
	iniwrite,%gtexe%,%cnfig%,main,gtexe
	regwrite,reg_sz,hkcu,%smreg%,gta_sa_exe,%gtexe%
	GuiControl,,gtdir,%gtdir%
	ifexist,%gtdir%\samp.exe
	{
		sampexe:=gtdir "\samp.exe"
		iniwrite,%sampexe%,%cnfig%,main,sampexe
	}
	GuiControl,disable,omn21
	GuiControl,,omn21,Done.
}
else
	st("GTA San Andreas not found [gta_sa.exe]",a_thislabel,728)
gui()
return
omn22:
gui,submit,nohide
iniwrite,%rexit%,%cnfig%,main,rexit
return
OMN23:
st("Backup GTA San Andreas")
GuiControl,disable,omn23
loop,%bcdir%\*
	a:=a_index
if ec(a){
	gui("",1)
	msgbox,8244,Warning 742 [%a_thislabel%],You are about to backup GTA files...`n | Backup directory : %bcdir%`nWould you like to overwrite backed files (if any) ?
	ifmsgbox Yes
		a:=1
	gui()
}
fb("",a)
fb("samp",a)
fb("cleo",a)
fb("scripts",a)
st("Backup GTA SA files","Success")
st("t",100)
GuiControl,,omn23,Backed up.
GuiControl,enable,omn24
return
OMN24:
st("Restore GTA San Andreas")
if !prkil("gta_sa.exe|samp.exe")
	st("Restore canceled due to process running gta_sa.exe / samp.exe",a_thislabel,759)
GuiControl,disable,omn24
fr()
fr("samp")
fr("cleo")
fr("scripts")
st("Restoring GTA SA files","Success")
st("t",100)
GuiControl,,omn24,Restored.
GuiControl,enable,omn23
return
MMB1:
gui,submit,nohide
st("Play GTA San Andreas")
iniread,a,%cnfig%,main,usrnm
iniread,spr,%cnfig%,%sip%,spr
iniread,ser,%cnfig%,%sip%,ser
iniread,b,%cnfig%,main,crcli
st("Checking username",usrnm)
if !ec(usrnm)
	st("Invalid Username. Please insert your username. [" usrnm "].",a_thislabel,779)
if (a!=usrnm){
	iniwrite,%usrnm%,%cnfig%,main,usrnm
	regwrite,reg_sz,hkcu,%smreg%,PlayerName,%usrnm%
}
a:=
st("Checking gta_sa.exe program file",gtexe)
IfNotExist,%gtexe%
	st("Checking Error. gta_sa.exe not found. [" gtexe "].",a_thislabel,787)
st("Checking Server Address",sip ":" spr)
if !ec(sip)||!ec(spr)
	st("Server Address Error. Could not find server address. [" svn ":" spr "].",a_thislabel,790)
st("Checking Server Version",ser)
if !ec(ser)||(ser="N/A"){
	msgbox,8224,Error 793 [%a_thislabel%],You didn't set the Server Version yet`nServer Version : %ser%.`nChange Server Version now ?
	ifmsgbox yes
		gosub,smn2
	return
}
if prchk("samp.exe")||prchk("gta_sa.exe"){
	prkil("samp.exe|gta_sa.exe")
	return
}
st("Checking asi files")
if as()=1 {
	st("Checking Client list")
	if (b!=ser){
		if ec(clist:=cc())
			c:=1
		loop,parse,clist,`|
		{
			if (A_LoopField!=ser)
				c:=0
			else if (A_LoopField=ser) {
				c:=1
				break
			}
		}
		if ec(c)
			cccpy(ser,1)
		if !ec(c){
			msgbox,8224,Error 820 [%a_thislabel%],Couldn't find Server Version on your samp client list.`nServer Version : %ser%,`nSAMP Client : %clist%.`nAdd samp client now ?
			ifmsgbox yes
				gosub,omn1
			return
		}
	}
	else if (b=ser)
		aschk(1)
	a:=
	b:=
	c:=
}
run,%gtexe% -c -n %usrnm% -h %sip% -p %spr%,%gtdir%
gosub,gtrun
return
gtrun:
settimer,gtrun,100
if !prchk("gta_sa.exe"){
	settimer,gtrun,off
	st("t",1)
	return
}
st("GTA San Andreas is currently running")
return
mmb2:
st("Refresh Server List")
gui,submit,nohide
GuiControl,disable,mmb2
iniread,crsip,%cnfig%,main,crsip
slist:=svupd()
loop,parse,slist,`|
	svupd(svchk(svinf(svchk(A_LoopField,"svn"),svchk(A_LoopField,"spr")),"sip"))
lvupd(crsip)
GuiControl,enable,mmb2
return
mmb3:
st("Remove samp.asi file")
gui,submit,nohide
aschk()
return
hmn1:
gui,submit,nohide
hmn1=
(
%pname% (%psnme%)

Servers :
 | Add Server ; add samp server to launcher.
 | SAMPL will automatically detect server version.
 | Change Server Version ; change selected samp server version.
 | If SAMPL doesn't detect server version, use this.
 | Remove Server ; remove samp server from launcher list.
 
Option :
 | Although this program contain samp 0.3.7 and 0.3.8,
 | You can add different version to client list.
 | Go to Client Setting ; add samp client to your launcher list.
 | Click Browse and select samp.dll/samp.exe
 | Fill the empty box with current samp version e.g. 0.3.9-RC1
 | Click Add Client.
 | (optional) Install another version of samp and repeat no 1-3.
 
Switch Client :
 | a) Switch Client
 | Click client dropdownlist on main window (on v1.0.1.1) then select version.
 | b) Play SA-MP Server
 | Just select server and play with the launcher, client will automatically detect and change the version.
 
Backup and Restore :
 | SAMP Client Switcher will automatically backup GTA Files to "Launcher Folder > Backup" on first time setup.
 | Any files in Cleo, Scripts, SAMP folder and GTA San Andreas directory are included for backup, but NOT other gta subfolder.
 | To Restore GTA / SA-MP files, Go to Option Click on Restore GTA.

Note ; Feel free to contact me / report on forum if you have any issue / suggestion(s) about the program.
)
msgbox,8256,%pname% - Readme,%hmn1%
return
hmn2:
gui,submit,nohide
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
 | ASI loader (silent / zdanio95)
 | AHK (autohotkey.com)
)
msgbox,8256,About %pname%,%hmn2%
return
guisize:
If ErrorLevel in 0,2
	If (A_GuiHeight <> 400){
		GuiControl,move,lchk,h200
		GuiControl,move,gbset,h75
		GuiControl,move,gbuet,h80
		gui,show,h400
		return
	}
If ErrorLevel in 0,2
	If (A_GuiWidth < 530){
		GuiControl,move,lchk,w510 h200
		GuiControl,move,gbset,w510 h75
		GuiControl,move,gbuet,w510 h80
		SB_SetParts(5,80,280,160,5)
		gui,show,h400 w530
		return
	}
If (A_GuiWidth > 530){
	sb:=a_guiwidth-250
	nw:=a_guiwidth-20
	nh:=a_guiheight-200
	GuiControl,move,lchk,w%nw%
	GuiControl,move,lchk,h%nh%
	GuiControl,move,gbset,% "y"nh+6 "w"nw
	GuiControl,move,gbuet,% "y"nh+87 "w"nw
	SB_SetParts(5,80,sb,160,5)
}
return
GuiClose:
if ec(rexit)
	gosub,mmb3
exitapp
smn1GuiEscape:
smn2GuiEscape:
omn1GuiEscape:
omn2GuiEscape:
smn1GuiClose:
smn2GuiClose:
omn1GuiClose:
omn2GuiClose:
gui,1:-disabled
if gui!=1
	gui,hide
st("t",100)
gui(1)
return
