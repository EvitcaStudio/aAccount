#ENABLE LOCALCLIENTCODE
#BEGIN CLIENTCODE

function checkCapsRecover(pEvent)
	if (pEvent.getModifierState('CapsLock'))
		Client.getInterfaceElement('recover_password_interface', 'capsindicator').text = '<span style="pointer-events: none; font-family: Arial; font-size: 12px; color: #ffc800;">Caps lock is on</span>'
		return
	Client.getInterfaceElement('recover_password_interface', 'capsindicator').text = ''

Client
	command recoverAccount()
		var usernameInput = this.getInterfaceElement('recover_password_interface','usernameinput')
		var backupInput = this.getInterfaceElement('recover_password_interface','backupinput')

		var usernameLabel = this.getInterfaceElement('recover_password_interface','usernamewarninglabel')
		var backupInputLabel = this.getInterfaceElement('recover_password_interface','backupinputwarninglabel')

		usernameInput.setTransition()
		backupInput.setTransition()
		// packet with info

	command openRecoverMenu()
		//...
		this.showInterface('recover_password_interface')
		this.setMacroAtlas('recover_password_macro')

	command closeRecoverMenu()
		this.hideInterface('recover_password_interface')
		this.setMacroAtlas('login_macro')		

	command cycleRecoverInputs()
		var userInput = this.getInterfaceElement('recover_password_interface', 'usernameinput')
		var backupInput = this.getInterfaceElement('recover_password_interface', 'backupinput')

		if (this.getFocus() === userInput)
			this.setFocus(backupInput)
		else
			this.setFocus(userInput)
			
Interface
	RecoverInterface
		atlasName = 'recover_password_atlas'
		plane = 1
		layer = HUD_LAYER + 3
		mouseOpacity = 0
		touchOpacity = 0
			
		RecoverBackground
			iconName = 'recover_background'
			interfaceType = 'WebBox'
			alpha = 0.9
			width = 268
			height = 384
			mouseOpacity = 2
			touchOpacity = 1

		TextLabels
			interfaceType = 'WebBox'
			layer = HUD_LAYER + 5
			width = 100
			height = 27
			var warningLabel
					
			RecoverLabel
				width = 150
				height = 30
				text = '<span style="pointer-events: none; color: #ffffff; font-size: 15px; font-family: Arial;" class="center">Recover Account</span>'

			UsernameWarningLabel
				iconName = 'warning_message_background'
				plane = 2
				layer = HUD_LAYER + 7
				warningLabel = true
				text = '<span style="pointer-events: none; color: #ffffff; font-size: 12px; font-family: Arial;" class="center"></span>'

			BackupInputWarningLabel
				iconName = 'warning_message_background'
				plane = 2
				layer = HUD_LAYER + 7
				warningLabel = true
				text = '<span style="pointer-events: none; color: #ffffff; font-size: 12px; font-family: Arial;" class="center"></span>'

		Bars
			iconName = 'recover_input'
			width = 214
			height = 29
			mouseOpacity = 2
			touchOpacity = 1
			layer = HUD_LAYER + 6
			alpha = 0.8
			textStyle = { 'fill': '#fff', 'fontSize': 12, 'hPadding': 5, 'fontFamily': 'Arial' }

			onMouseEnter(pClient, pX, pY)
				if (!this.iconState)
					this.setTransition({ 'alpha': 1 }, 5, 30)
			
			onMouseExit(pClient, pX, pY)
				if (!this.iconState && pClient.getFocus() !== this)
					this.setTransition({ 'alpha': 0.8 }, 5, 20)

			onFocus()
				this.iconState = ''
				this.setTransition()
				this.alpha = 1

			UsernameInput
				interfaceType = 'TextInput'
				onShow()
					if (this.getDOM())
						var element = this.getDOM().innerBox
						element.placeholder = '*Enter Username'
						element.spellcheck = false
						element.required = true
						element.maxLength = MAX_USERNAME_LENGTH
						element.onkeydown = checkCapsRecover

			BackupInput
				interfaceType = 'TextInput'
				onShow()
					if (this.getDOM())
						var element = this.getDOM().innerBox
						element.placeholder = '*Enter backup code'
						element.spellcheck = false
						element.required = true
						element.maxLength = MAX_USERNAME_LENGTH
						element.onkeydown = checkCapsRecover

		Buttons
			interfaceType = 'WebBox'
			textStyle = { 'vPadding': 4 }
			plane = 2
			layer = HUD_LAYER + 7
			mouseOpacity = 2
			touchOpacity = 1
			alpha = 0.8

			onMouseEnter(pClient, pX, pY)
				pClient.setMouseCursor('pointer')
				this.setTransition({ 'alpha': 1 }, 5, 30)
			
			onMouseExit(pClient, pX, pY)
				pClient.setMouseCursor('')
				this.setTransition({ 'alpha': 0.8 }, 5, 20)
			
			Recover
				iconName = 'complete_recover_button'
				width = 173
				height = 25
				text = '<div class="center register_button">Recover</div>'
					
				onMouseClick(pClient, pX, pY, pButton)
					if (pButton === 1)
						if (this.isMousedDown())
							pClient.callCommand('recoverAccount')
			BackButton
				iconName = 'back_button'
				witdh = 25
				height = 25

				onMouseClick(pClient, pX, pY, pButton)
					if (pButton === 1)
						if (this.isMousedDown())
							pClient.callCommand('closeRecoverMenu')

#END CLIENTCODE

