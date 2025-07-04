#DEFINE HUD_LAYER 10
#ENABLE LOCALCLIENTCODE
#BEGIN CLIENTCODE

function extractNumberOutOfString(pString)
	return Util.toNumber(pString.replace(Util.regExp('[^0-9]', 'g'), ''))

Client
	function showLoadScreen(pCharacters, pCharacterInfoObject)
		if (!pCharacters)
			foreach (var e in this.getInterfaceElements('load_interface'))
				if (e.name === 'slots_background' || e.type === 'Interface/Load_Interface/Delete' || e.name === 'character_creation_label')
					continue

				e.text = '<div class="char_slot">Empty slot</div>'
				e.charName = ''
		else
			if (pCharacterInfoObject)
				var slot = 0
				var name
				var level
				var mapName
				foreach (var el in this.getInterfaceElements('load_interface'))
					if (el.type === 'Interface/Load_Interface/Slot')
						if (slot > (pCharacters - 1)) // 0 = 1, and so on, array index format so everything is off one
							el.text = '<div class="char_slot">Empty slot</div>'
							el.charName = ''
							slot++
							continue

						name = pCharacterInfoObject[slot][0]
						// level = pCharacterInfoObject[slot][1]
						// mapName = pCharacterInfoObject[slot][2]

						if (!name/* && !level && !mapName*/)
							el.text = '<div class="char_slot">Empty slot</div>'
							el.charName = ''
							slot++
							continue

						el.text = '<div class="char_slot">Name: ' + name + /*'<br>Level: ' + level + '<br>Map: ' + mapName + */'</div>'
						el.charName = name
						slot++
						if (slot > aAccount.maxCharacterSlots - 1)
							break

Interface
	Load_Interface
		atlasName = 'load_atlas'
		mouseOpacity = 0
		touchOpacity = 0
		layer = HUD_LAYER

		Slots_Background
			iconName = 'slots_background'

		Character_Creation_Label
			width = 267
			height = 40
			interfaceType = 'WebBox'
			text = '<div class="info-text big center" style="pointer-events: none;">Load Character</div>'

		Slot
			interfaceType = 'WebBox'
			textStyle = { 'fill': '#fff' }
			width = 267
			height = 79
			iconName = 'slot'
			mouseOpacity = 2
			touchOpacity = 1

			onMouseEnter(pClient, pX, pY)
				this.iconState = 'slot_highlighted'

			onMouseExit(pClient, pX, pY)
				this.iconState = ''
			
			onMouseClick(pClient, pX, pY, pButton)
				if (pButton === 1)
					if (this.isMousedDown())
						if (!pClient.deletingCharacter)
							pClient.sendPacket(aNetwork.S_AACCOUNT_PACKETS.S_LOAD_PLAYER_PACKET, [extractNumberOutOfString(this.name)])

		Delete
			iconName = 'trash'
			width = 16
			height = 16
			mouseOpacity = 2
			touchOpacity = 1

			onMouseEnter(pClient, pX, pY)
				if (!pClient._dragging.element)
					pClient.setMouseCursor('pointer')

			onMouseExit(pClient, pX, pY)
				pClient.setMouseCursor('')

			onMouseClick(pClient, pX, pY, pButton)
				if (!pClient.deletingCharacter)
					var slotNumber = extractNumberOutOfString(this.name)
					if (Util.toNumber(slotNumber))
						if (pButton === 1)
							if (this.isMousedDown())
								var charName = pClient.getInterfaceElement('load_interface', 'slot' + slotNumber).charName
								if (charName)
									if (!pClient.checkInterfaceShown('load_confirm_interface'))
										var label = pClient.getInterfaceElement('load_confirm_interface', 'confirmlabel')
										label.text = '<div class="info-text center">Are you sure you want to delete ' + charName + '?</div>'
										pClient.showInterface('load_confirm_interface')
										pClient.deletingCharacter = Util.toNumber(slotNumber)

			onMouseEnter(pClient, pX, pY)
				this.iconState = 'trash_highlighted'

			onMouseExit(pClient, pX, pY)
				this.iconState = ''

		LoadDeleteConfirm
			atlasName = ''
			plane = 999999
			layer = HUD_LAYER + 10
			
			onShow(pClient)
				this.setPos(this.defaultPos.x, this.defaultPos.y)
			
			ConfirmLabel
				width = 185
				height = 35
				interfaceType = 'WebBox'
				text = '<div class="info-text center"></div>'
				parentElement = 'confirmbackground'

				onHide(pClient)
					if (this.name === 'confirmlabel') // we use this type elsewhere
						this.text = '<div class="info-text center"></div>'
						pClient.deletingCharacter = null

			ConfirmBackground
				atlasName = ''
				width = 225
				height = 100
				color = { 'tint': 0x212121 }
				layer = HUD_LAYER + 10
				interfaceType = 'WebBox'
				mouseOpacity = 2
				touchOpacity = 1
				dragOptions = { 'draggable': true, 'parent': true }

			ConfirmYesButton
				width = 75
				height = 18
				mouseOpacity = 2
				touchOpacity = 1
				interfaceType = 'WebBox'
				layer = HUD_LAYER + 20
				color = { 'tint': 0x303030 }
				text = '<div class="info-text center button-padding-top">Yes</div>'
				parentElement = 'confirmbackground'

				onMouseEnter(pClient, pX, pY)
					if (!pClient._dragging.element)
						this.color = { 'tint': 0x5c5c5c }
						pClient.setMouseCursor('pointer')

				onMouseExit(pClient, pX, pY)
					this.color = { 'tint': 0x303030 }
					pClient.setMouseCursor('')

				onMouseClick(pClient, pX, pY, pButton)
					if (pButton === 1)
						if (this.isMousedDown())
							if (pClient.deletingCharacter)
								for (var i = 1; i <= aAccount.maxCharacterSlots; i++)
									pClient.getInterfaceElement('load_interface', 'slot' + i).charName = null
								pClient.sendPacket(aNetwork.S_AACCOUNT_PACKETS.S_DELETE_SLOT_PACKET, [pClient.deletingCharacter])
								pClient.hideInterface('load_confirm_interface')
								pClient.deletingCharacter = null

			ConfirmNoButton
				width = 75
				height = 18
				mouseOpacity = 2
				touchOpacity = 1
				interfaceType = 'WebBox'
				color = { 'tint': 0x303030 }
				layer = HUD_LAYER + 20
				text = '<div class="info-text center button-padding-top">No</div>'
				parentElement = 'confirmbackground'

				onMouseEnter(pClient, pX, pY)
					if (!pClient._dragging.element)
						this.color = { 'tint': 0x5c5c5c }
						pClient.setMouseCursor('pointer')

				onMouseExit(pClient, pX, pY)
					this.color = { 'tint': 0x303030 }
					pClient.setMouseCursor('')

				onMouseClick(pClient, pX, pY, pButton)
					if (pButton === 1)
						if (this.isMousedDown())
							pClient.hideInterface('load_confirm_interface')
							pClient.deletingCharacter = null

#END CLIENTCODE