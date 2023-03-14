Scriptname zzzSpellHolderScript extends ObjectReference  

Spell Property BaseSpell Auto
Spell Property MySpell Auto

Float Property Magnitude Auto
Float Property Duration Auto
String Property Name Auto

Sound Property zzzSpellLearned Auto

GlobalVariable Property zzzCapCoefficient Auto
GlobalVariable Property zzzCapExponent Auto



Function Refresh()
	Actor p = Game.GetPlayer()
	
	If !BaseSpell
		p.RemoveSpell(mySpell)
		Return
	EndIf

	Spell[] baseSpellList = new Spell[1]
	baseSpellList[0] = BaseSpell

	_SE_SpellExtender.CombineSpells(MySpell, baseSpellList, Name)

	Int i
	i = mySpell.GetNumEffects()
	While i
		i -= 1
		PO3_SKSEFunctions.RemoveEffectItemFromSpell(mySpell, mySpell, i)
	EndWhile

	float costScale = Game.GetGameSettingFloat("fMagicCostScale")

	i = 0
	float totalCost = 0
	While i < BaseSpell.GetNumEffects()
		MagicEffect mgef = BaseSpell.GetNthEffectMagicEffect(i)

		float newMagnitude = BaseSpell.GetNthEffectMagnitude(i) * Magnitude
		float newDuration = BaseSpell.GetNthEffectDuration(i) * Duration
		float baseCost = BaseSpell.GetNthEffectMagicEffect(i).GetBaseCost()
		float costDuration = newDuration / 10
		float costMagnitude = newMagnitude
		If costDuration < 1
			costDuration = 1
		EndIf
		If costMagnitude < 1
			costMagnitude = 1
		EndIf
		
		float cost = baseCost * Math.Pow(costMagnitude * costDuration, costScale)
		totalCost += cost
		PO3_SKSEFunctions.AddEffectItemToSpell(MySpell, BaseSpell, i, cost)
		MySpell.SetNthEffectMagnitude(i, newMagnitude)
		MySpell.SetNthEffectDuration(i, newDuration as int)

		i += 1
	EndWhile
	
	_SE_SpellExtender.SetSpellCost(MySpell, totalCost as int)
	
EndFunction

String Function GetSpellName()
	If BaseSpell
		Return MySpell.GetName()
	EndIf
	Return "Empty"
EndFunction

String Function GetSchool(Spell s)
	int numEffects = s.GetNumEffects()
	If !numEffects
		return None
	EndIf
	Return s.GetNthEffectMagicEffect(s.GetCostliestEffectIndex()).GetAssociatedSkill()
EndFunction

Bool Function HasMagnitude(Spell s)
	int numEffects = s.GetNumEffects()
	If !numEffects
		return False
	EndIf
	Return !s.GetNthEffectMagicEffect(s.GetCostliestEffectIndex()).IsEffectFlagSet(0x00000400)
EndFunction

Bool Function HasDuration(Spell s)
	int numEffects = s.GetNumEffects()
	If !numEffects
		return False
	EndIf
	int i = s.GetCostliestEffectIndex()
	Return !s.GetNthEffectMagicEffect(i).IsEffectFlagSet(0x00000200) && s.GetNthEffectDuration(i) > 1
EndFunction

Function MakeSpell(Book b)
	Spell s = b.GetSpell()
	If !s
		Return
	EndIf
	If MakeSpellFromBase(s)
		Actor p = Game.GetPlayer()
		p.RemoveItem(b, 1, True)
	EndIf
EndFunction

bool Function MakeSpellFromBase(Spell s, String newName = "")
	UILib_1 uilib = (self as form) as UILib_1

	If !newName
		newName = uilib.ShowTextInput("Spell Name", "Custom " + s.GetName())
	EndIf
	If !newName
		Return false
	EndIf

	string school = GetSchool(s)
	If !school
		Return false
	EndIf

	Actor p = Game.GetPlayer()
	float skill = p.GetActorValue(school)
	float maxMagicka = Math.Pow(skill, zzzCapExponent.GetValue()) * zzzCapCoefficient.GetValue()
	float cap = maxMagicka / s.GetMagickaCost()

	If cap <= 1
		Debug.MessageBox("Your " + school + " skill is not high enough to craft " + newName)
		p.RemoveSpell(MySpell)
		Return false
	EndIf

	float newMagnitude = 0
	If HasMagnitude(s)
		While newMagnitude > cap || newMagnitude <= 0
			string output = uilib.ShowTextInput(newName + " Spell Magnitude Multiplier (current max: " + cap + ")", cap as string)
			If output == ""
				Return false
			EndIf
			newMagnitude = output as float
		EndWhile
	Else
		newMagnitude = 1
	EndIf

	cap = cap / newMagnitude

	float newDuration = 0
	If HasDuration(s) && cap > 1
		While newDuration > cap || newDuration <= 0
			string output = uilib.ShowTextInput(newName + " Spell Duration Multiplier (current max: " + cap + ")", cap as string)
			If output == ""
				Return false
			EndIf
			newDuration = output as float
		EndWhile
	Else
		newDuration = 1
	EndIf

	If newDuration == 1 && newMagnitude == 1
		Debug.MessageBox("This spell is the same as the base spell")
		Return false
	EndIf

	BaseSpell = s
	Magnitude = newMagnitude
	Duration = newDuration
	Name = newName
	zzzSpellLearned.Play(p)

	Refresh()
	p.AddSpell(mySpell)
	Debug.MessageBox(mySpell.GetName() + " crafted.")
	Return false
EndFunction
