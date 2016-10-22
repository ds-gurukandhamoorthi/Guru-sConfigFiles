import XMonad hiding ( (|||) )
import XMonad.Layout.LayoutCombinators
import XMonad.Util.EZConfig
import XMonad.Util.CustomKeys
import XMonad.Util.XSelection
import XMonad.Actions.GroupNavigation
import qualified Data.Map as M
import qualified XMonad.StackSet as W
import Data.Bits ((.|.))
import XMonad.Actions.Submap
import XMonad.Actions.Commands
--import XMonad.Layout.MultiToggle
--import XMonad.Layout.MultiToggle.Instances
import XMonad.Layout.ToggleLayouts
import XMonad.Layout.NoBorders
import XMonad.ManageHook
import XMonad.Hooks.SetWMName
import XMonad.Hooks.EwmhDesktops
import XMonad.Util.Scratchpad
import XMonad.Actions.WindowBringer
import XMonad.Layout.WindowNavigation

--TODO: understand Scratchpad, and then search engines prompt

super :: KeyMask
super = mod4Mask

alt :: KeyMask
alt = mod1Mask

ratpoisonEscape = (0, xK_less)



--layout = noBorders Full ||| tiled ||| Mirror tiled
--layout = smartBorders $  configurableNavigation (navigateColor "#0000FF") $ Mirror tiled ||| Full ||| tiled
layout = smartBorders $  windowNavigation $ Mirror tiled ||| Full ||| tiled
	where
		tiled = Tall nMaster delta ratio
		nMaster = 2
		ratio = 936/1600
		delta = 1/300

myWorkspaces=["1","2","3","4","5","6","7","8","9"]


commands :: X [(String, X ())]
commands = do
	return $ myListCommands

--myListCommands :: [(String, X())]
myListCommands = [
	("random-wallpaper",randomWallpaper)
	, ("one-above-another",oneAboveAnother)
	, ("book", spawn "zathura /home/guru/Downloads/book")
	
	]

-- use <+> ...
myManageHook =  manageHook defaultConfig <+>  manageScratchPad

manageScratchPad :: ManageHook
manageScratchPad = scratchpadManageHook(W.RationalRect l t w h)
	where 
		h = 0.1
		w = 1
		t = 1-h
		l = 1-w

main = xmonad $ defaultConfig
	{ modMask = super
	, logHook = historyHook
	, manageHook =  myManageHook
	, workspaces = myWorkspaces
	, layoutHook = layout
	, startupHook = welcomeMessage >> ewmhDesktopsStartup >> setWMName "LG3D" >> randomWallpaper
	} 
	 `additionalKeys`
	[((0 , xK_Print), randomWallpaper)
	,((super , xK_e), commands >>= runCommand)
	,((0 , xK_F13), rpOther)
	,((0 , xK_F12),scratchpadSpawnActionTerminal "urxvt")
	,((0 , xK_Menu),scratchpadSpawnActionTerminal "urxvt")
	,((controlMask .|. alt, xK_k), halt)

	, (ratpoisonEscape, submap . M.fromList $ ratpoisonBindings )

	]

	
	--`additionalKeysP`
	--[("C-t C-t", commands >>= runCommand)]
	


-- some ratpoison actions
rpOther, rpPrevious, rpNext :: X()
rpOther = nextMatch History (return True)
rpNext = windows W.focusUp
rpPrevious = windows W.focusDown

rpOnly =  sendMessage $ JumpToLayout "Full"
--rpOnly = setLayout $ XMonad.layoutHook conf


--some actions
browser, launcher,console, speedConsole, batStatus, randomWallpaper, halt, executePrompt, internalCommandsPrompt :: X()
browser = spawn "firefox"
launcher = spawn "dmenu_run"
console = spawn "lxterminal"
--speedConsole = spawn "Eterm"
speedConsole = scratchpadSpawnActionTerminal "urxvt"
batStatus = spawn "/home/guru/bin/batStatus.sh" -- battery status
randomWallpaper = spawn "feh --randomize --recursive --bg-scale ~/wp"
halt = spawn "sudo shutdown now"
executePrompt = launcher -- to be modified to have the same functionality as in ratpoison
internalCommandsPrompt = defaultCommands >>= runCommand


oneAboveAnother, welcomeMessage, showDateTime :: X()
oneAboveAnother = spawn "/home/guru/bin/oneAboveAnother.sh" -- battery status
welcomeMessage = spawn "echo 'Guru never fails' | dzen2 -p 1 -fn 'Dejavu Sans:size=20'"
showDateTime = spawn "date +'%a %d/%m/%Y   %T' | dzen2 -p 1 -fn 'Dejavu Sans:size=20'"




ratpoisonBindings =
	[
	--launching and killing programs
	((0, xK_c), console)
	,((shiftMask, xK_c), speedConsole)
	,((0, xK_k),  kill)
	,((0, xK_period), launcher)
	,((0, xK_f), browser)
	,((0, xK_w), gotoMenuArgs ["-l", "25"])
	,((0 , xK_Right), sendMessage $ Go R)
	,((0 , xK_Left), sendMessage $ Go L)
	,((0 , xK_Up), sendMessage $ Go U)
	,((0 , xK_Down), sendMessage $ Go D)
	,((controlMask , xK_Right), sendMessage $ Swap R)
	,((controlMask , xK_Left), sendMessage $ Swap L)
	,((controlMask , xK_Up), sendMessage $ Swap U)
	,((controlMask , xK_Down), sendMessage $ Swap D)


	-- execute ...
	,((shiftMask, xK_1), scratchpadSpawnActionTerminal "urxvt")


	-- move window "stack"
	, (ratpoisonEscape, rpOther)
	,((0, xK_n), rpNext)
	,((0, xK_p), rpPrevious)
	,((0, xK_q), rpOnly)
	,((0, xK_space), rpNext)
	,((shiftMask, xK_space), rpPrevious)
	,((0, xK_a), showDateTime)


	-- resizing
	, ((controlMask, xK_r), submap . M.fromList $ resizingBindings)

	,((super, xK_F12),  batStatus)

	-- show useful information
	,((super, xK_F1),  batStatus)

	]


resizingBindings= 
	[
	((0, xK_p), console)
	]


--TO DO
-- implement cnext cprev cother ...
--help ... echo guru |xmessage -timeout 20 -buttons "exit:0" -default exit -file -
