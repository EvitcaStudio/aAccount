#DEFINE MAX_PASSWORD_LENGTH 25
#DEFINE MIN_PASSWORD_LENGTH 5
#DEFINE MAX_USERNAME_LENGTH 15
#DEFINE MIN_USERNAME_LENGTH 5
#DEFINE MAX_BACKUP_CODE_LENGTH 6

#DEFINE USERNAME_SHOW 0
#DEFINE USERNAME_HIDE 1

#DEFINE PASSWORD_SHOW 2
#DEFINE PASSWORD_HIDE 3

#DEFINE R_USERNAME_SHOW 4
#DEFINE R_USERNAME_HIDE 5

#DEFINE R_PASSWORD_SHOW 6
#DEFINE R_PASSWORD_HIDE 7

#DEFINE R_RPASSWORD_SHOW 8
#DEFINE R_RPASSWORD_HIDE 9

#DEFINE R_BACKUP_SHOW 10
#DEFINE R_BACKUP_HIDE 11

#DEFINE R_PASSWORD_SHOW_ONLY 12
#DEFINE R_RPASSWORD_SHOW_ONLY 13

#DEFINE LOGIN_ALL 14
#DEFINE REGISTER_ALL 15

#ENABLE LOCALCLIENTCODE
#BEGIN CLIENTCODE

function isUsernameFormatted(pString)
	if (!pString)
		return false

	if (pString.match(Util.regExp('[^A-Za-z0-9_-]', 'g')))
		return false
		
	return true

function checkCapsRegistration(pEvent)
	if (pEvent.getModifierState('CapsLock'))
		Client.getInterfaceElement('register_interface', 'capsindicator').text = '<span style="pointer-events: none; font-family: Arial; font-size: 12px; color: #ffc800;">Caps lock is on</span>'
		return
	Client.getInterfaceElement('register_interface', 'capsindicator').text = ''

Interface
	RegistrationInterface
		atlasName = 'register_atlas'
		plane = 1
		layer = HUD_LAYER + 3
		mouseOpacity = 0
		touchOpacity = 0
			
		RegistrationBackground
			iconName = 'registration_background'
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
					
			SignUpLabel
				width = 150
				height = 30
				text = '<span style="pointer-events: none; color: #ffffff; font-size: 15px; font-family: Sylfaen;" class="center">Sign up</span>'

			UsernameWarningLabel
				iconName = 'warning_message_background'
				plane = 2
				layer = HUD_LAYER + 7
				warningLabel = true
				text = '<span style="pointer-events: none; color: #ffffff; font-size: 12px; font-family: Sylfaen;" class="center"></span>'

			PasswordWarningLabel
				iconName = 'warning_message_background'
				plane = 2
				layer = HUD_LAYER + 7
				warningLabel = true
				text = '<span style="pointer-events: none; color: #ffffff; font-size: 12px; font-family: Sylfaen;" class="center"></span>'

			RepeatPasswordLabel
				iconName = 'warning_message_background'
				plane = 2
				layer = HUD_LAYER + 7
				warningLabel = true
				text = '<span style="pointer-events: none; color: #ffffff; font-size: 12px; font-family: Sylfaen;" class="center"></span>'

			BackupInputLabel
				iconName = 'warning_message_background_backup'
				width = 55
				height = 27
				plane = 2
				layer = HUD_LAYER + 7
				warningLabel = true
				text = '<span style="pointer-events: none; color: #ffffff; font-size: 12px; font-family: Sylfaen;" class="center"></span>'
			
		Bars
			iconName = 'register_input'
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
						element.placeholder = '*Username'
						element.spellcheck = false
						element.required = true
						element.maxLength = MAX_USERNAME_LENGTH
						element.onkeydown = checkCapsRegistration

				onFocus(pClient)
					pClient.getInterfaceElement('register_interface', 'usernamewarninglabel').hide()

				onUnfocus(pClient)
					if (this.text)
						if (!isUsernameFormatted(this.text))
							pClient.validateInputs(R_USERNAME_SHOW, 'Invalid Format')

						else if (this.text.length < MIN_PASSWORD_LENGTH)
							pClient.validateInputs(R_USERNAME_SHOW, 'Too short')
					else
						pClient.validateInputs(R_USERNAME_SHOW, 'Required')
					
			PasswordInput
				interfaceType = 'PassInput'

				function validateInput()
					var repeatPasswordInput = Client.getInterfaceElement('register_interface', 'repeatpasswordinput')
					var passwordLabel = Client.getInterfaceElement('register_interface','passwordwarninglabel')
					
					if (this.text)
						if (this.text.length < MIN_PASSWORD_LENGTH)
							Client.validateInputs(R_PASSWORD_SHOW_ONLY, 'Too short')
							if (repeatPasswordInput.text)
								if (repeatPasswordInput.text !== this.text)
									Client.validateInputs(R_RPASSWORD_SHOW_ONLY, 'Don\'t match')

						else if (this.text.length > MAX_PASSWORD_LENGTH)
							Client.validateInputs(R_PASSWORD_SHOW_ONLY, 'Too long')
							if (repeatPasswordInput.text)
								if (repeatPasswordInput.text !== this.text)
									Client.validateInputs(R_RPASSWORD_SHOW_ONLY, 'Don\'t match')

						else if (this.text !== repeatPasswordInput.text)
							Client.validateInputs(R_PASSWORD_SHOW, 'Don\'t match')

						else
							if (this.text === repeatPasswordInput.text)
								Client.validateInputs(R_PASSWORD_HIDE)
					else
						Client.validateInputs(R_PASSWORD_SHOW_ONLY, 'Required')

					if (repeatPasswordInput.text)
						if (repeatPasswordInput.text !== this.text)
							Client.validateInputs(R_RPASSWORD_SHOW_ONLY, 'Don\'t match')
					else
						Client.validateInputs(R_RPASSWORD_SHOW_ONLY, 'Required')

				onShow()
					if (this.getDOM())
						var element = this.getDOM().innerBox
						element.placeholder = '*Password'
						element.spellcheck = false
						element.required = true
						element.maxLength = MAX_PASSWORD_LENGTH
						element.onkeydown = checkCapsRegistration

				onFocus(pClient)
					pClient.getInterfaceElement('register_interface', 'passwordwarninglabel').hide()

				onUnfocus(pClient)
					this.validateInput()
							
			RepeatPasswordInput
				interfaceType = 'PassInput'

				function validateInput()
					var passwordInput = Client.getInterfaceElement('register_interface','passwordinput')
					var repeatPasswordLabel = Client.getInterfaceElement('register_interface','repeatpasswordlabel')
					
					if (this.text)
						if (this.text !== passwordInput.text)
							Client.validateInputs(R_RPASSWORD_SHOW_ONLY, 'Don\'t match')

						else
							if (this.text === passwordInput.text && passwordInput.text.length >= MIN_PASSWORD_LENGTH && passwordInput.text.length <= MAX_PASSWORD_LENGTH)
								Client.validateInputs(R_RPASSWORD_HIDE)
					else
						Client.validateInputs(R_RPASSWORD_SHOW_ONLY, 'Required')

					if (passwordInput.text)
						if (passwordInput.text !== this.text)
							Client.validateInputs(R_PASSWORD_SHOW_ONLY, 'Don\'t match')
					else
						Client.validateInputs(R_PASSWORD_SHOW_ONLY, 'Required')

				onShow()
					if (this.getDOM())
						var element = this.getDOM().innerBox
						element.placeholder = '*Repeat Password'
						element.spellcheck = false
						element.required = true
						element.maxLength = MAX_PASSWORD_LENGTH
						element.onkeydown = checkCapsRegistration

				onFocus(pClient)
					pClient.getInterfaceElement('register_interface', 'repeatpasswordlabel').hide()

				onUnfocus(pClient)
					this.validateInput()

			BackupInput
				iconName = 'backup_input'
				width = 108
				height = 29
				interfaceType = 'TextInput'

				onShow()
					if (this.getDOM())
						var element = this.getDOM().innerBox
						element.maxLength = MAX_BACKUP_CODE_LENGTH
						element.placeholder = '*6 Char Code'
						element.required = true

				onFocus(pClient)
					pClient.getInterfaceElement('register_interface', 'backupinputlabel').hide()

				onUnfocus(pClient)
					if (this.text)
						if (this.text.length !== MAX_BACKUP_CODE_LENGTH)
							pClient.validateInputs(R_BACKUP_SHOW, 'Too short')
					else
						pClient.validateInputs(R_BACKUP_SHOW, 'Required')
		
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
			
			Register
				iconName = 'complete_registration_button'
				width = 173
				height = 25
				text = '<div class="center register_button">Complete Registration</div>'
					
				onMouseClick(pClient, pX, pY, pButton)
					if (pButton === 1)
						if (this.isMousedDown())
							pClient.callCommand('registerCommand')
			
			BackButton
				iconName = 'back_button'
				witdh = 25
				height = 25

				onMouseClick(pClient, pX, pY, pButton)
					if (pButton === 1)
						if (this.isMousedDown())
							pClient.closeRegistration()

			InfoUsernameButton
				iconName = 'info'
				width = 13
				height = 13
				layer = HUD_LAYER + 8

			InfoPasswordButton
				iconName = 'info'
				width = 13
				height = 13
				layer = HUD_LAYER + 8

			InfoBackupInputButton
				iconName = 'info'
				width = 13
				height = 13
				layer = HUD_LAYER + 8

			ViewPasswordButton
				iconName = 'view_password'
				width = 16
				height = 16
				layer = HUD_LAYER + 8
				var passwordShown = false
				var viewEye = true

				function toggle()
					var passInput = Client.getInterfaceElement('register_interface','passwordinput')
					var element = passInput.getDOM().innerBox
					var passwordLabel = Client.getInterfaceElement('register_interface','passwordwarninglabel')
					this.passwordShown = this.passwordShown ? false : true
					this.iconName = this.passwordShown ? 'view_password_hide' : 'view_password'
					element.type = element.type === 'password' ? 'text' : 'password'
					Client.validateInputs(R_PASSWORD_HIDE)
					if (!this.passwordShown)
						Client.getInterfaceElement('register_interface','passwordinput').validateInput()

				onMouseClick(pClient, pX, pY, pButton)
					if (pButton === 1)
						if (this.isMousedDown())
							this.toggle()

			ViewRepeatPasswordButton
				iconName = 'view_password'
				width = 16
				height = 16
				layer = HUD_LAYER + 8
				var passwordShown = false
				var viewEye = true

				function toggle()
					var repeatPassInput = Client.getInterfaceElement('register_interface','repeatpasswordinput')
					var element = repeatPassInput.getDOM().innerBox
					var repeatPasswordLabel = Client.getInterfaceElement('register_interface','repeatpasswordlabel')
					this.passwordShown = this.passwordShown ? false : true
					this.iconName = this.passwordShown ? 'view_password_hide' : 'view_password'
					element.type = element.type === 'password' ? 'text' : 'password'
					Client.validateInputs(R_RPASSWORD_HIDE)
					if (!this.passwordShown)
						Client.getInterfaceElement('register_interface','repeatpasswordinput').validateInput()

				onMouseClick(pClient, pX, pY, pButton)
					if (pButton === 1)
						if (this.isMousedDown())
							this.toggle()

Client
	function openRegistration()
		this.showInterface('register_interface')
		foreach (var el in this.getInterfaceElements('login_interface'))
			if (el.iconState)
				el.iconState = ''

			if (el.interfaceType === 'TextInput' || el.interfaceType === 'PassInput')
				el.text = ''

			if (el.warningLabel)
				el.hide()

			if (el.viewEye)
				if (el.passwordShown)
					el.toggle()

		this.setMacroAtlas('register_macro')
			
	function closeRegistration()
		foreach (var el in this.getInterfaceElements('register_interface'))
			if (el.iconState)
				el.iconState = ''

			if (el.interfaceType === 'TextInput' || el.interfaceType === 'PassInput')
				el.text = ''

			if (el.warningLabel)
				el.hide()

			if (el.viewEye)
				if (el.passwordShown)
					el.toggle()

		this.setMacroAtlas('login_macro')
		this.hideInterface('register_interface')

	function validateInputs(pInputCode, pLabelText) // a function that will server to simplify the current setup that runs under `onUnfocus` and elsewhere
		var usernameInput = this.getInterfaceElement('login_interface','usernameinput')
		var passwordInput = this.getInterfaceElement('login_interface','passwordinput')
		var usernameLabel = this.getInterfaceElement('login_interface','usernamewarninglabel')
		var passwordLabel = this.getInterfaceElement('login_interface','passwordwarninglabel')
// ------------------------------------------------------------------------------------------------
		var r_usernameInput = this.getInterfaceElement('register_interface','usernameinput')
		var r_passwordInput = this.getInterfaceElement('register_interface','passwordinput')
		var r_repeatPasswordInput = this.getInterfaceElement('register_interface','repeatpasswordinput')
		var r_backupInput = this.getInterfaceElement('register_interface','backupinput')
		var r_usernameLabel = this.getInterfaceElement('register_interface','usernamewarninglabel')
		var r_passwordLabel = this.getInterfaceElement('register_interface','passwordwarninglabel')
		var r_repeatPasswordLabel = this.getInterfaceElement('register_interface','repeatpasswordlabel')
		var r_backupInputLabel = this.getInterfaceElement('register_interface','backupinputlabel')

		var text = ''

		if (pInputCode || pInputCode === 0)
			if (pLabelText)
				text = '<div style="padding-top: 6px; color: #ffffff; font-size: 12px; font-family: Sylfaen;" class="center">' + pLabelText + '</div>'
				var iconState = 'warning_background'
				
			switch (pInputCode)
				case LOGIN_ALL:
					usernameLabel.show()
					usernameLabel.text = text
					usernameInput.setTransition()
					usernameInput.alpha = 1
					usernameInput.iconState = iconState
					// ---
					passwordLabel.show()
					passwordLabel.text = text
					passwordInput.setTransition()
					passwordInput.alpha = 1
					passwordInput.iconState = iconState
					break

				case USERNAME_SHOW:
					usernameLabel.show()
					usernameLabel.text = text
					usernameInput.setTransition()
					usernameInput.alpha = 1
					usernameInput.iconState = iconState
					break

				case USERNAME_HIDE:
					usernameLabel.hide()
					usernameInput.iconState = ''
					usernameInput.setTransition()
					usernameInput.alpha = 0.8
					break

				case PASSWORD_SHOW:
					passwordLabel.show()
					passwordLabel.text = text
					passwordInput.setTransition()
					passwordInput.alpha = 1
					passwordInput.iconState = iconState
					break

				case PASSWORD_HIDE:
					passwordLabel.hide()
					passwordInput.iconState = ''
					passwordInput.setTransition()
					passwordInput.alpha = 0.8
					break

				case REGISTER_ALL:
					r_usernameLabel.show()
					r_usernameLabel.text = text
					r_usernameInput.setTransition()
					r_usernameInput.alpha = 1
					r_usernameInput.iconState = iconState
					// ---
					r_passwordLabel.show()
					r_repeatPasswordLabel.show()
					r_passwordLabel.text = text
					r_repeatPasswordLabel.text = text
					r_passwordInput.setTransition()
					r_passwordInput.alpha = 1
					r_passwordInput.iconState = iconState
					r_repeatPasswordInput.setTransition()
					r_repeatPasswordInput.alpha = 1
					r_repeatPasswordInput.iconState = iconState
					// ---
					r_backupInputLabel.show()
					r_backupInputLabel.text = text
					r_backupInput.setTransition()
					r_backupInput.alpha = 1
					r_backupInput.iconState = iconState
					break

				case R_USERNAME_SHOW:
					r_usernameLabel.show()
					r_usernameLabel.text = text
					r_usernameInput.setTransition()
					r_usernameInput.alpha = 1
					r_usernameInput.iconState = iconState
					break

				case R_USERNAME_HIDE:
					r_usernameLabel.hide()
					r_usernameInput.setTransition()
					r_usernameInput.alpha = 0.8
					r_usernameInput.iconState = ''
					break

				case R_PASSWORD_SHOW:
				case R_RPASSWORD_SHOW:
					r_passwordLabel.show()
					r_passwordLabel.text = text
					r_passwordInput.setTransition()
					r_passwordInput.alpha = 1
					r_passwordInput.iconState = iconState
					// ---
					r_repeatPasswordLabel.show()
					r_repeatPasswordLabel.text = text
					r_repeatPasswordInput.setTransition()
					r_repeatPasswordInput.alpha = 1
					r_repeatPasswordInput.iconState = iconState
					break

				case R_PASSWORD_SHOW_ONLY:
					r_passwordLabel.show()
					r_passwordLabel.text = text
					r_passwordInput.setTransition()
					r_passwordInput.alpha = 1
					r_passwordInput.iconState = iconState
					break


				case R_RPASSWORD_SHOW_ONLY:
					r_repeatPasswordLabel.show()
					r_repeatPasswordLabel.text = text
					r_repeatPasswordInput.setTransition()
					r_repeatPasswordInput.alpha = 1
					r_repeatPasswordInput.iconState = iconState
					break

				case R_PASSWORD_HIDE:
				case R_RPASSWORD_HIDE:
					r_passwordLabel.hide()
					r_passwordInput.setTransition()
					r_passwordInput.alpha = 0.8
					r_passwordInput.iconState = ''
					// ---
					r_repeatPasswordLabel.hide()
					r_repeatPasswordInput.setTransition()
					r_repeatPasswordInput.alpha = 0.8
					r_repeatPasswordInput.iconState = ''
					break

				case R_BACKUP_SHOW:
					r_backupInputLabel.show()
					r_backupInputLabel.text = text
					r_backupInput.setTransition()
					r_backupInput.alpha = 1
					r_backupInput.iconState = iconState
					break

				case R_BACKUP_HIDE:
					r_backupInputLabel.hide()
					r_backupInput.setTransition()
					r_backupInput.alpha = 0.8
					r_backupInput.iconState = ''
					break

	command registerCommand()
		var usernameInput = this.getInterfaceElement('register_interface','usernameinput')
		var passwordInput = this.getInterfaceElement('register_interface','passwordinput')
		var repeatPasswordInput = this.getInterfaceElement('register_interface','repeatpasswordinput')
		var backupInput = this.getInterfaceElement('register_interface','backupinput')

		var usernameLabel = this.getInterfaceElement('register_interface','usernamewarninglabel')
		var passwordLabel = this.getInterfaceElement('register_interface','passwordwarninglabel')
		var repeatPasswordLabel = this.getInterfaceElement('register_interface','repeatpasswordlabel')
		var backupInputLabel = this.getInterfaceElement('register_interface','backupinputlabel')

		usernameInput.setTransition()
		passwordInput.setTransition()
		repeatPasswordInput.setTransition()
		backupInput.setTransition()
		
		if (!usernameInput.text && this.getFocus() !== usernameInput)
			this.validateInputs(R_USERNAME_SHOW, 'Required')
			
		if (!passwordInput.text && this.getFocus() !== passwordInput)
			this.validateInputs(R_PASSWORD_SHOW_ONLY, 'Required')
			
		if (!repeatPasswordInput.text && this.getFocus() !== repeatPasswordInput)
			this.validateInputs(R_RPASSWORD_SHOW_ONLY, 'Required')

		if (!backupInput.text && this.getFocus() !== backupInput)
			this.validateInputs(R_BACKUP_SHOW, 'Required')

		if (passwordInput.text.length > MAX_PASSWORD_LENGTH && this.getFocus() !== passwordInput)
			this.validateInputs(R_PASSWORD_SHOW_ONLY, 'Too long')
			if (repeatPasswordInput.text)
				if (repeatPasswordInput.text !== passwordInput.text)
					this.validateInputs(R_PASSWORD_SHOW_ONLY, 'Don\'t match')
			return

		else if (passwordInput.text.length && passwordInput.text.length < MIN_PASSWORD_LENGTH && this.getFocus() !== passwordInput)
			this.validateInputs(R_PASSWORD_SHOW_ONLY, 'Too short')
			if (repeatPasswordInput.text)
				if (repeatPasswordInput.text !== passwordInput.text)
					this.validateInputs(R_PASSWORD_SHOW_ONLY, 'Don\'t match')
			return

		if (backupInput.text.length && backupInput.text.length < MAX_BACKUP_CODE_LENGTH && this.getFocus() !== backupInput)
			this.validateInputs(R_BACKUP_SHOW, 'Too short')
		
		if (usernameInput.text && passwordInput.text && repeatPasswordInput.text === passwordInput.text && passwordInput.text.length <= MAX_PASSWORD_LENGTH && passwordInput.text.length >= MIN_PASSWORD_LENGTH && usernameInput.text.length <= MAX_USERNAME_LENGTH && usernameInput.text.length >= MIN_USERNAME_LENGTH && backupInput.text.length === MAX_BACKUP_CODE_LENGTH) // check
			this.sendPacket(aNetwork.S_CREATE_ACCOUNT_PACKET, [usernameInput.text, passwordInput.text, repeatPasswordInput.text, backupInput.text])
			return

	command cycleRegisterInputs()
		var usernameInput = this.getInterfaceElement('register_interface', 'usernameinput')
		var passwordInput = this.getInterfaceElement('register_interface', 'passwordinput')
		var repeatPasswordInput = this.getInterfaceElement('register_interface', 'repeatpasswordinput')
		var backupInput = this.getInterfaceElement('register_interface', 'backupinput')

		if (this.getFocus() === usernameInput)
			this.setFocus(passwordInput)

		else if (this.getFocus() === passwordInput)
			this.setFocus(repeatPasswordInput)

		else if (this.getFocus() === repeatPasswordInput)
			this.setFocus(backupInput)

		else
			this.setFocus(usernameInput)

#END CLIENTCODE

#BEGIN WEBSTYLE

.register_button {
	font-family: 'Mukta';
	color: #ffffff;
	font-family: Sylfaen;
	font-size: 12px;
	text-shadow: rgb(34, 34, 34) 2px 0px 0px, rgb(34, 34, 34) 1.75517px 0.958851px 0px, rgb(34, 34, 34) 1.0806px 1.68294px 0px, rgb(34, 34, 34) 0.141474px 1.99499px 0px, rgb(34, 34, 34) -0.832294px 1.81859px 0px, rgb(34, 34, 34) -1.60229px 1.19694px 0px, rgb(34, 34, 34) -1.97998px 0.28224px 0px, rgb(34, 34, 34) -1.87291px -0.701566px 0px, rgb(34, 34, 34) -1.30729px -1.5136px 0px, rgb(34, 34, 34) -0.421592px -1.95506px 0px, rgb(34, 34, 34) 0.567324px -1.91785px 0px, rgb(34, 34, 34) 1.41734px -1.41108px 0px, rgb(34, 34, 34) 1.92034px -0.558831px 0px;
}

/* Chrome, Safari, Edge, Opera */
input::-webkit-outer-spin-button,
input::-webkit-inner-spin-button {
	-webkit-appearance: none;
	margin: 0;
}

/* Firefox */
input[type=number] {
	-moz-appearance: textfield;
}

#END WEBSTYLE