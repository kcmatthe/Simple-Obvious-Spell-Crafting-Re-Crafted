Scriptname zzzSpellMakingPlayerAliasScript extends ReferenceAlias

zzzSpellMakingQuestScript Property zzzSpellMakingQuest Auto

;Event OnPlayerLoadGame()
;	zzzSpellMakingQuest.Refresh()
;EndEvent

Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
	Book b = akBaseObject as Book
	If b && b.GetSpell()
		zzzSpellMakingQuest.MakeSpell(b)
	EndIf
EndEvent