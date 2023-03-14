Scriptname zzzSpellMakingQuestScript extends Quest  

zzzSpellHolderScript[] Property SpellHolders Auto

GlobalVariable Property zzzCapCoefficient Auto
GlobalVariable Property zzzCapExponent Auto

zzzSpellMakingThreadScript Property zzzSpellMakingThreadsQuest01 Auto
zzzSpellMakingThreadScript Property zzzSpellMakingThreadsQuest02 Auto
zzzSpellMakingThreadScript Property zzzSpellMakingThreadsQuest03 Auto
zzzSpellMakingThreadScript Property zzzSpellMakingThreadsQuest04 Auto
zzzSpellMakingThreadScript Property zzzSpellMakingThreadsQuest05 Auto
zzzSpellMakingThreadScript Property zzzSpellMakingThreadsQuest06 Auto
zzzSpellMakingThreadScript Property zzzSpellMakingThreadsQuest07 Auto
zzzSpellMakingThreadScript Property zzzSpellMakingThreadsQuest08 Auto
zzzSpellMakingThreadScript Property zzzSpellMakingThreadsQuest09 Auto
zzzSpellMakingThreadScript Property zzzSpellMakingThreadsQuest10 Auto

int spellsLearned

int lastVersion = 0

Event OnInit()
	lastVersion = 1
	Refresh()
EndEvent

Function Refresh()
	If HandleUpdate()
		Return
	EndIf

	bool abMenu = Game.IsMenuControlsEnabled()

	Game.DisablePlayerControls(\
		abMovement = false,\
		abFighting = false,\
		abCamSwitch = false,\
  		abLooking = false,\
		abSneaking = false,\
		abMenu = true,\
		abActivate = false,\
		abJournalTabs = false\
	)

	int i = SpellHolders.Length
	
	zzzSpellMakingThreadsQuest01.Start()
	zzzSpellMakingThreadsQuest02.Start()
	zzzSpellMakingThreadsQuest03.Start()
	zzzSpellMakingThreadsQuest04.Start()
	zzzSpellMakingThreadsQuest05.Start()
	zzzSpellMakingThreadsQuest06.Start()
	zzzSpellMakingThreadsQuest07.Start()
	zzzSpellMakingThreadsQuest08.Start()
	zzzSpellMakingThreadsQuest09.Start()
	zzzSpellMakingThreadsQuest10.Start()

	Utility.Wait(0.5)

	While !zzzSpellMakingThreadsQuest01.Done || \
		!zzzSpellMakingThreadsQuest02.Done || \
		!zzzSpellMakingThreadsQuest03.Done || \
		!zzzSpellMakingThreadsQuest04.Done || \
		!zzzSpellMakingThreadsQuest05.Done || \
		!zzzSpellMakingThreadsQuest06.Done || \
		!zzzSpellMakingThreadsQuest07.Done || \
		!zzzSpellMakingThreadsQuest08.Done || \
		!zzzSpellMakingThreadsQuest09.Done || \
		!zzzSpellMakingThreadsQuest10.Done
		Utility.Wait(0.5)
	EndWhile

	spellsLearned = Game.QueryStat("Spells Learned")
	Debug.Notification("Spellcrafting: custom spells loaded")

	Game.EnablePlayerControls(\
		abMovement = false,\
		abFighting = false,\
		abCamSwitch = false,\
  		abLooking = false,\
		abSneaking = false,\
		abMenu = abMenu,\
		abActivate = false,\
		abJournalTabs = false\
	)
EndFunction

bool Function HandleUpdate()
	If lastVersion < 1
		bool abMenu = Game.IsMenuControlsEnabled()

		Game.DisablePlayerControls(\
			abMovement = false,\
			abFighting = false,\
			abCamSwitch = false,\
  			abLooking = false,\
			abSneaking = false,\
			abMenu = true,\
			abActivate = false,\
			abJournalTabs = false\
		)

		Debug.MessageBox("The spell multiplier cap formula has changed. It is now based on total Magicka cost and caps magnitude x duration as a whole instead of individually.")
		Utility.Wait(0.1)
		UILib_1 uilib = (self as form) as UILib_1
		Actor p = Game.GetPlayer()
		float newCoefficient = 0
		While !newCoefficient
			newCoefficient = uilib.ShowTextInput("Please update the spell cap coefficient. Recommended value: 0.025", "0.025") as float
		EndWhile
		zzzCapCoefficient.SetValue(newCoefficient)
		int i = SpellHolders.Length
		While i
			i -= 1
			zzzSpellHolderScript spellHolder = SpellHolders[i]
			If p.HasSpell(spellHolder.MySpell)
				spellHolder.MakeSpellFromBase(spellHolder.BaseSpell, spellHolder.Name)
				Utility.Wait(0.1)
			EndIf
		EndWhile
		lastVersion = 1

		Game.EnablePlayerControls(\
			abMovement = false,\
			abFighting = false,\
			abCamSwitch = false,\
  			abLooking = false,\
			abSneaking = false,\
			abMenu = abMenu,\
			abActivate = false,\
			abJournalTabs = false\
		)

		Return true
	Else
		Return false
	EndIf
EndFunction

Function MakeSpell(Book b)
	int newSpellsLearned = Game.QueryStat("Spells Learned")
	If newSpellsLearned <= spellsLearned
		zzzSpellHolderScript holder = GetHolder()
		holder.MakeSpell(b)
	EndIf
	spellsLearned = Game.QueryStat("Spells Learned")
EndFunction

zzzSpellHolderScript Function GetHolder()
	int count = SpellHolders.Length
	string[] options = Utility.CreateStringArray(count + 2)
	options[count] = "Cancel"
	options[count+1] = "Configure"
	int i = count
	While i
		i -= 1
		options[i] = "Slot " + (i + 1) + ": " + SpellHolders[i].GetSpellName()
	EndWhile
	UILib_1 uilib = (self as form) as UILib_1
	int choice = uilib.ShowList("Choose spell slot", options, 0, 0)
	If choice == count
		return None
	ElseIf choice == count + 1
		Configure()
		return GetHolder()
	EndIf
	Return SpellHolders[choice]
EndFunction

Function Configure()
	UILib_1 uilib = (self as form) as UILib_1
	float newExponent = ShowTextInputWithValidation("Spell cap exponent", zzzCapExponent.GetValue())
	If !newExponent
		Return
	EndIf
	float newCoefficient = uilib.ShowTextInput("Spell cap coefficient", zzzCapCoefficient.GetValue() as string) as float
	If !newCoefficient
		Return
	EndIf
	zzzCapExponent.SetValue(newExponent)
	zzzCapCoefficient.SetValue(newCoefficient)
EndFunction

float Function ShowTextInputWithValidation(string title, float default)
	UILib_1 uilib = (self as form) as UILib_1
	float value = 0
	While value <= 0
		string stringValue = uilib.ShowTextInput(title, default as string) 
		If !stringValue
			Return 0
		EndIf
		value = stringValue as float
	EndWhile
	Return value
EndFunction
