Scriptname zzzSpellMakingThreadScript extends Quest  

Event OnInit()
	Done = false
	int i = SpellHolders.Length
	While i
		i -= 1
		SpellHolders[i].Refresh()
	EndWhile
	Done = true
	Stop()
	Reset()
EndEvent

zzzSpellHolderScript[] Property SpellHolders Auto
bool Property Done Auto
