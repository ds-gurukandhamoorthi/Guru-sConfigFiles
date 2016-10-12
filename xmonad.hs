import XMonad
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

super :: KeyMask
super = mod4Mask

alt :: KeyMask
alt = mod1Mask

ratpoisonEscape = (0, xK_less)



--layout = noBorders Full ||| tiled ||| Mirror tiled
layout = smartBorders $  Mirror tiled ||| Full ||| tiled
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

main = xmonad $ defaultConfig
	{ modMask = super
	, logHook = historyHook
	, workspaces = myWorkspaces
	, layoutHook = layout
	, startupHook = welcomeMessage >> ewmhDesktopsStartup >> setWMName "LG3D" >> randomWallpaper
	} 
	 `additionalKeys`
	[((0 , xK_Print), randomWallpaper)
	,((super , xK_e), commands >>= runCommand)
	,((0 , xK_F13), rpOther)
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

rpOnly = windows W.focusDown
--rpOnly = setLayout $ XMonad.layoutHook conf


--some actions
browser, launcher,console, speedConsole, batStatus, randomWallpaper, halt, executePrompt, internalCommandsPrompt :: X()
browser = spawn "firefox"
launcher = spawn "dmenu_run"
console = spawn "lxterminal"
speedConsole = spawn "Eterm"
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

	-- execute ...
	,((shiftMask, xK_1), executePrompt)


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
